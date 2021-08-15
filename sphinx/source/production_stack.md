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

