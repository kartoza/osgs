










# Production Stack

## Overview

In this section we will bring up the full production stack, but to do that we
first need to get an SSL certificate issued. To facilitate this, there is a
special, simplified, version of Nginx which has no reverse proxies in place and
not docker dependencies. Here is an overview of the process:

1. Replace the domain name in your letsencrypt init script
2. Replace the email address in your letsencrypt init script
3. Replace the domain name in the certbot init nginx config file
4. Open up ports 80 and 443 on your firewall
5. Run the init script, ensuring it completed successfully
6. Shut down the minimal nginx
7. Replace the domain name in the production nginx config file
8. Generate passwords for geoserver, postgres, postgrest and update .env
9. Copy over the mapproxy template files
10. Run the production profile in docker compose

At the end of the process you should have a fully running production stack with
these services:

IMAGE | PORTS | NAMES
------|-------|-------
kartoza/mapproxy | 8080/tcp |                                   osgisstack_mapproxy_1
nginx | 0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp |  osgisstack_nginx_1
swaggerapi/swagger-ui |        80/tcp, 8080/tcp |                  osgisstack_swagger_1
postgrest/postgrest |          3000/tcp  |   osgisstack_postgrest_1 
kartoza/geoserver:2.18.0  |    8080/tcp, 8443/tcp  |  osgisstack_geoserver_1
openquake/qgis-server:stable | 80/tcp, 9993/tcp | osgisstack_qgis-server_1
kartoza/postgis:13.0 | 0.0.0.0:5432->5432/tcp  | osgisstack_db_1
quay.io/lkiesow/docker-scp |   0.0.0.0:2222->22/tcp | osgisstack_scp_1
certbot/certbot | 80/tcp, 443/tcp | osgisstack_certbot_1

The following ports will be accessible on the host to the docker services. You
can, on a case by case basis, allow these through your firewall using ufw
(uncomplicated firewall) to make them publicly accessible:

1. 80 - http:Only really needed during initial setup of your letsencrypt
   certificate
2. 443 - https: All web based services run through this port so that they are
   encrypted
3. 5432 - postgres: Only expose this publicly if you intend to allow remote
   clients to access the postgres database. 
4. 2222 - scp: The is an scp/sftp upload mechanism to mobilise data and
   resources to the web site

For those services that are not exposed to the host,  they are generally made
available over 443/SSL via reverse proxy in the Nginx configuration.

Some things should still be configured manually and deployed after the initial
deployment:

1.	Mapproxy configuration
2.	setup.sql (especially needed if you are planning to use postgrest)
3.	Hugo content management
4.	Landing page static HTML

And some services are not intended to be used as long running services.
especially the ODM related services.

## Configuration

We have written a make target that automates steps 1-10 described in the
overview above. It will ask you for your domain name, legitimate email address
and then go ahead and copy the templates over, replace placeholder domain names
and email address, generate passwords for postgres etc. and then run the
production stack. Remember you need to have ufw, rpl, make and pwgen installed
before running this command:


```
make configure
```




# Working with the PostgreSQL database

There are a number of different workflows we will explore here: 

* Connecting to the PostgreSQL database from your QGIS Desktop application
* Connecting to the PostgreSQL database from QGIS Server
* Connecting to the PostgreSQL database from GeoServer
* Connecting from other applications

Before we dive into the details here, let us quickly examine some basic use cases:

* You collect data in the field using Input and use the mergin-db-sync workflow to synchronised field collected data into the database, then publish maps for this data in QGIS Server.
* You want to publish a layer in GeoServer, so you connect to the database from your desktop, drag and drop a local file system layer into the database using QGIS, then publish the layer from GeoServer.
* You want to create a project in QGIS desktop that uses PostgreSQL for data storage, then publish that data as a QGIS Project.

There are many other workflows that the Open GIS Stack supports, it is really up to your imagination! What is key to understand are the mechanisms that you can use to connect to the database in different contexts. And so we will focus this section on the different connection modalities.

## Direct connection

Direct connection to the server over the standard PostgreSQL port exposed to the public internet is probably the least secure but most convenient approach. We do not recommend this approach, and if you do follow it be sure to use the option to force remote clients to connect using SSL (and expect a performance penalty in the process).

Note also that connecting to a PostgreSQL database using QGIS from a remote host may often be slow and irritating to use on a daily basis, especially if your internet connection is not very fast and your datasets are large.

By default the docker-compose.yaml 


Publishing with QGIS Server

The workflows described in this section apply equally to any database hosted 




Further reading for understanding authentication with PostgreSQL using cert based authentication here:

https://joelonsql.com/2013/04/27/securing-postgresql-using-hostssl-cert-clientcert1/



# Obtaining free fonts for your projects

There are two great sources of free fonts that you can use for your projects:

http://ftp.gnu.org/gnu/freefont/freefont-ttf-20120503.zip
https://fonts.google.com/

There is a makefile target that can be run with:

```
make get-fonts
```

That will fetch all of these fonts for you. If you also fetch these fonts on your local machine and place them in your ``~/.fonts`` folder then you can use them in your local QGIS projects, know they will also be available to QGIS server if you publish that project as a web map.

**Note:** This and other makefile targets assume that you have not changed the ``COMPOSE_PROJECT_NAME=osgisstack`` environment variable in .env.

**Note:** The above make command fetches a rather large download!




--------------------------------------------
SCRAP

--------------------------------------------

These are legacy notes to be removed or carefully incorporated into the notes above as necessary.


## Generalised Workflow

![Workflow Diagram](diagrams/QGIS-Server-PG-Project-Workflow.png)

## Getting started

## Checkout submodules

```
git submodule update --init --recursive
```

## Define your domain name

This repo contains a worked example of running the stack as described above. 
There are numerous references to the testing domain 'castelo.kartoza.com' in 
various configuration files that should be replaced with your own
preferred domain name before running any of these images. One simple way to
do so is to install the 'rpl' command line tool and then replace all instances 
of the aforementioned domain named e.g.: 

sudo apt install rpl
rpl castelo.kartoza.com your.domain.com *

After doing that make sure you have a valid DNS entry pointing to your host - 
you will need this for the Certbot/Letsencrypt bot to work.

Similarly there is a reference to my email in the letsencrypt init script
which you need to change to your own email address in ``init-letsencrypt.sh``.

## Initialise Certbot

Make sure the steps above have been carried out then run the init script.

``
./init-letsencrypt.sh
``

After successfully running it will terminate wiith a message like this:

```
### Requesting Let's Encrypt certificate for castelo.kartoza.com ...
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator webroot, Installer None
Requesting a certificate for castelo.kartoza.com
Performing the following challenges:
http-01 challenge for castelo.kartoza.com
Using the webroot path /var/www/certbot for all unmatched domains.
Waiting for verification...
Cleaning up challenges

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/castelo.kartoza.com/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/castelo.kartoza.com/privkey.pem
   Your certificate will expire on 2021-05-30. To obtain a new or
   tweaked version of this certificate in the future, simply run
   certbot again. To non-interactively renew *all* of your
   certificates, run "certbot renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le


### Reloading nginx ...
2021/03/01 22:50:52 [notice] 33#33: signal process started
```

If you have any issues checking out the certificate etc. then 
check the nginx logs:

``
docker-compose logs -f nginx
``

## Check Services

After the above steps, a subset of the services will be running. 

``
docker-compose ps
``

Which should show something like this:


```
             Name                           Command                  State                   Ports             
---------------------------------------------------------------------------------------------------------------
maceiramergindbsync_db_1         /bin/sh -c /scripts/docker ...   Up (healthy)   0.0.0.0:15432->5432/tcp       
maceiramergindbsync_geoserver_   /bin/sh /scripts/entrypoint.sh   Up (healthy)   8080/tcp, 8443/tcp            
1                                                                                                              
maceiramergindbsync_mapproxy_1   /start.sh mapproxy-util se ...   Up             8080/tcp                      
maceiramergindbsync_nginx_1      /docker-entrypoint.sh /bin ...   Up             0.0.0.0:443->443/tcp,         
                                                                                 0.0.0.0:80->80/tcp            
maceiramergindbsync_postgrest_   /bin/sh -c exec postgrest  ...   Up             0.0.0.0:32779->3000/tcp       
1                                                                                                              
maceiramergindbsync_qgis-        /bin/sh -c /usr/local/bin/ ...   Up             80/tcp,                       
server_1                                                                         0.0.0.0:32780->9993/tcp       
maceiramergindbsync_swagger_1    /docker-entrypoint.sh sh / ...   Up             80/tcp, 0.0.0.0:3001->8080/tcp
```

Before we bring up the OSM mirror and the Mergin Sync serviice we need to do some additional 
configuration. In the next subsection we will set up the OSM mirror clip region:



## Set Your Clip Region



## Building mergin-db-sync

Mergin db sync is not currently in docker hub, so you need to build the docker image yourself. 
First check out the [mergin-db-source](https://github.com/lutraconsulting/mergin-db-sync).


```
make redeploy-mergin
```

Note: They do now have an image available - need to swap to using that in docker-compose

## Initialise the superset database

The first time you run, you need to configure superset by using the init container:

```
docker-compose up superset-init
```

Doing that will create a user with credentials admin/admin

There is also a config file in ``superset_conf/superset_config.py`` which manages permissions for 
public users. 




You need to also assign the following permissions to the Public role:

![Role Permissions](./docs/img/superset-permissions-role.png)


```
[can csrf token on Superset, can explore json on Superset, can explore on Superset, can dashboard on Superset, datasource access on [smallholding].[vw_vegetation_points](id:4)]
```

I also made a Public user which is linked to the Gamma role:

![User Permissions](./docs/img/superset-permissions-users.png)

That public user needs to be given access to each chart that you want to publicly share in your dashboards:

![User Permissions](./docs/img/superset-permissions-chart.png)

Lastly, that public user also needs to be given access to each dashboard that you want to publicly share:

![User Permissions](./docs/img/superset-permissions-dashboard.png)

Once you have that in place, you should be able to share dashboards that do not need users to log in.


See also https://github.com/apache/superset/issues/7763 and https://superset.apache.org/docs/security .


## Bring up remaining services


```
docker-compose up -d
```

Note that some services are intended to be run once only so you may see errors e.g. for odm which you can ignore.

## Essential Reading

### QGIS Server

You should read the [QGIS Server documentation](https://docs.qgis.org/3.16/en/docs/server_manual/getting_started.html#) on QGIS.org. It is well written and covers a lot of background explanation which is not provided here. Also you should familiarise yourself with the [Environment Variables](https://docs.qgis.org/3.16/en/docs/server_manual/config.html#environment-variables).

Alesandro Passoti has made a number of great resources available for QGIS Server. See his [workshop slide deck](http://www.itopen.it/bulk/FOSS4G-IT-2020/#/presentation-title) and his [server side plugin examples](https://github.com/elpaso/qgis3-server-vagrant/tree/master/resources/web/plugins), and [more examples here](https://github.com/elpaso/qgis-helloserver).

### QGIS Server Atlas Print Plugin

See the [project documentation](https://github.com/3liz/qgis-atlasprint/blob/master/atlasprint/README.md#api) for supported request parameters for QGIS Atlas prints.

### Docker OSM


<<<<<<< HEAD
## Generating Vector Tiles

See https://gis.stackexchange.com/a/292358 on how to export your postgresql data base layers to vector mbtiles and https://gdal.org/drivers/raster/mbtiles.html for the config file format. See also the PG provider docs here: https://gdal.org/drivers/vector/pg.html

For example here we convert our OSM mirror to an mbtiles vector tile store:

ogr2ogr -f MBTILES target.mbtiles PG:"dbname='gis' host='localhost' port='15432' user='docker' password='docker'" -dsco MAXZOOM=10

### RTK GPS in Input

Check out https://twitter.com/complementterre?s=20 Julien Ancelin's work for making a low budget RTK GPS receiver for use with INPUT
=======
## Vector tiles

A great primer on vector tiles, particularly with relevance to QGIS. https://wanderingcartographer.wordpress.com/2021/01/09/qgis-3-and-vector-map-tiles/

>>>>>>> 40760fd9aff5dd3890249977f8837d9899794ca4

### PostgREST

Take special note of the fact that the passing of environment variables to the docker container is 
desribed [here](chttps://postgrest.org/en/v7.0.0/install.html#docker). Especially this line:

> These variables match the options shown in our Configuration section, except they are capitalized, have a PGRST_ prefix, and use underscores. 

So for example ``openapi-server-proxy-ur`` would become ``PGRST_OPENAPI_SERVER_PROXY_URI``.

This latter environment variable is important by the way to present a public url for the api running inside the docker container.

I based some of my Nginx configuration on the excellent example [by Johnny Lambada](https://github.com/johnnylambada/docker-postgrest-swagger-sample).

## Loading Raster Layers

Here is how I loaded raster data into the database:

Flags used:

```
-d Drop table, create new one and populate it with raster(s) 
-t TILE_SIZE Cut raster into tiles to be inserted one per table row. TILE_SIZE
   is expressed as WIDTHxHEIGHT or set to the value "auto" to allow the loader to
   compute an appropriate tile size using the first raster and applied to all
   rasters. 
-F Add a column with the name of the file
-I Create a GiST index on the raster column. 
-s <SRID> Assign output raster with specified SRID. If not provided or is zero,
   raster's metadata will be checked to determine an appropriate SRID. 
-l OVERVIEW_FACTOR Create overview of the raster. For more than one factor,
   separate with comma(,). Overview table name follows the pattern o_overview
   factor_table, where overview factor is a placeholder for numerical overview
   factor and table is replaced with the base table name. Created overview is
   stored in the database and is not affected by -R. Note that your generated sql
   file will contain both the main table and overview tables.
```
(Above copied directly from raster2pgsql help docs)



```
echo "create schema raster;" | psql -h localhost -p 15432 -U docker gis
cd /home/timlinux/gisdata/Maceira/orthophoto
raster2pgsql -s 32629 -t 256x256 -C -l 4,8,16,32,64,128,256,512 -P -F -I odm_orthophoto.tif raster.orthophoto | psql -h localhost -p 15432 -U docker gis
cd /home/timlinux/gisdata/Maceira/elevation
raster2pgsql -s 32629 -t 256x256 -C -l 4,8,16,32,64,128,256,512 -d -P -F -I dtm.tif raster.dtm | psql -h localhost -p 15432 -U docker gis
raster2pgsql -s 32629 -t 256x256 -C -l 4,8,16,32,64,128,256,512 -d -P -F -I dsm.tif raster.dsm | psql -h localhost -p 15432 -U docker gis
cd -
```

*Note* this project includes automation for creating ODM mosaics and 
loading them into Postgresql - see the Makefile odm related tasks.


## Authentication Management

[Some discussion](http://osgeo-org.1560.x6.nabble.com/QGIS-Server-qgis-auth-db-td5408912.html)
suggest to set authdb configuration parameters in Apache/Nginx but I found it
would only work if I set these in the environment of the QGIS Server docker
container.

## Hugo

See this for notes on how to automate publishing from github.

https://humanitec.com/blog/how-to-deploy-hugo-website


## Other Notes

### Fonts

Fonts used in this project are from Google Fonts, checked out using:

```
git clone git@github.com:google/fonts.git
```
