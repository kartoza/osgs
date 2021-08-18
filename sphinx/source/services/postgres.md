# Postgres and PostGIS

Short description

**Project Website:** [PostgreSQL](https://postgresql.org) and [PostGIS](https://postgis.net/)

**Project Source Repository:**

**Project Project Technical Documentation:**

**Docker Repository:**

**Docker Source Repository:**


## Configuration

## Deployment

## Enabling

## Disabling

## Accessing the running services

## Additional Notes

The heart of any stack like this would be PostGIS and PostgreSQL. This is because many 
of the other tools provided in the OSGS stack, for example Goeserver, QGIS Server and 
Mergin, all rely or can make use of PostGIS as a data storage platform and in some cases 
as a data anlysis platform. The OSGS stack provides  PostgreSQL version 13 along with 
PostGIS which are provided by the the Kartoza PostGIS Docker container. There are a few 
considerations that were made when deploying this container. One, which is actually a 
general design consideration of the OSGS stack, is to try and make everything as secure 
as possible out of the box, rather than leaving security as an afterthought. To fulfill 
this consideration, what the OSGS stack does, is it spins up a PostgreSQL instance with 
PostGIS deployed in it and creates a separate user account for connecting to this instance. 
It also enables SSL encription by default, as required to the PostgreSQL database. This 
is so that if you choose to open the port as a public service, firstly, we are not using 
some well documented default password and username combination and secondly, all the traffic 
between your client application and the server is encrypted.



## Overview

We use the Kartoza PostGIS docker image available here:
https://hub.docker.com/r/kartoza/postgis/ 

The project home page is here: https://github.com/kartoza/docker-postgis

The project includes detailed documentation so this section only contains
details relevant to the Open Source GIS Stack configuration.

## Configuration

### Database password:
Generate a strong password:

``pwgen 20  1``

Replace the default docker password for the postgres user with the strong
password:

```
rpl “POSTGRES_PASSWORD=docker” “POSTGRES_PASSWORD=<strong password>” .env
```

### Service file configuration:

Service files entries serve two scenarios:

1. They are needed for opening QGIS projects stored in postgres with PG
   connection URI because at the project URI you cannot use QGIS authdb. If you
   prefer to store your projects on the file system, you should rather remove
   these lines (whole nginx section) since the authentication from
   pg_conf/pg_service.conf can be done more securely by QGIS authdb.
2. Used by your QGIS Server projects to connect to the database once the
   project is opened from either the file system of the database.  You can
   either specify your password and username in service file or for more advanced
   configuration you can store user / password credentials in a QGIS authdb file.
   Refer to the authdb section and in qgis_conf/qgis-auth.db and the readme in
   that folder.

On your local machine you should create your own service file with the same
service name but connection details that make sense when using the database
from your local machine. When you upload your projects into the stack they will
connect using the settings from the server hosted service file below assuming
you used the same service name.

To carry out the service file configuration, copy, rename then edit the
pg_service file in pg_config as per the example below (note that we also
substitute in the database password created in the steps above).

```
cp pg_conf/pg_service.conf.example \ pg_conf/pg_service.confpassword=docker 
rpl password=<your password> pg_conf/pg_service.conf
```

### Deployment

```
docker-compose --profile=postgres up -d
```

Note that the default configuration opens the postgresql service to all hosts.
This is a potential security hole. If you open the port on the firewall e.g.

```
ufw allow 5432 tcp
```

Then be sure to connect from pg clients like psql or QGIS with SSL enabled so
that passwords and data are not transmitted in clear text.

### Validation

Create a local pg_service.conf file like the example below and save it in
``~/.pg_service.conf`` or similar as appropriate to your operating system (see
https://www.postgresql.org/docs/12/libpq-pgservice.html for details on
configuration options).

```
[os-gis-stack]
dbname=gis
port=5432
host=<hostname of your server>
user=<your password>
password=docker
```

Now pass the server parameter to psql and list the databases as per the example
below:


```
[timlinux@fedora ~]$ psql service=os-gis-stack -l
List of databases
```

   Name    |  Owner   | Encoding | Collate |  Ctype  |   Access privileges   
-----------|---------|----------|---------|---------|-----------------------
 gis       | docker   | UTF8     | C.UTF-8 | C.UTF-8 | 
 postgres  | postgres | UTF8     | C.UTF-8 | C.UTF-8 | 
 template0 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          |
 template1 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          |

``(4 rows)``

Test from QGIS is similar:

XXXXXXXXXXXXXX


Note that there was no need to supply any credentials other than the service file name.

## PostgreSQL Workflows

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

### Direct connection

Direct connection to the server over the standard PostgreSQL port exposed to the public internet is probably the least secure but most convenient approach. We do not recommend this approach, and if you do follow it be sure to use the option to force remote clients to connect using SSL (and expect a performance penalty in the process).

Note also that connecting to a PostgreSQL database using QGIS from a remote host may often be slow and irritating to use on a daily basis, especially if your internet connection is not very fast and your datasets are large.

By default the docker-compose.yaml 


Publishing with QGIS Server

The workflows described in this section apply equally to any database hosted 




Further reading for understanding authentication with PostgreSQL using cert based authentication here:

https://joelonsql.com/2013/04/27/securing-postgresql-using-hostssl-cert-clientcert1/


