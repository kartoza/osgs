# Postgres and PostGIS

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

