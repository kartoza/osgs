# Postgres and PostGIS - PR ![PR](https://img.shields.io/badge/pr-green?style=for-the-badge)

PostgreSQL is a powerful, open source object-relational database management system (ORDBMS) that uses and extends the SQL language combined with many features that safely store and scale the most complicated data workloads.[<sup>[1]</sup>](#1)[<sup>[2]</sup>](#2)

PostGIS is a spatial extension to for PostgreSQL object-relational database. This allows for GIS (Geographic Information Systems) objects to be stored in the database.[<sup>[3]</sup>](#3)

The heart of any stack like the OpenSource GIS Stack would be PostGIS and PostgreSQL. This is because many of the other tools provided in the OSGS stack, for example Goeserver, QGIS Server and Mergin, all rely or can make use of PostGIS as a data storage platform and in some cases as a data anlysis platform. The OSGS stack provides PostgreSQL version 13 along with PostGIS which are provided by the the Kartoza PostGIS Docker container. There are a few considerations that were made when deploying this container. One, which is actually a general design consideration of the OSGS stack, is to try and make everything as secure as possible out of the box, rather than leaving security as an afterthought. To fulfill this consideration, what the OSGS stack does, is it spins up a PostgreSQL instance with PostGIS deployed in it and creates a separate user account for connecting to this instance. It also enables SSL encription by default, as required to the PostgreSQL database. This is so that if you choose to open the port as a public service, firstly, we are not using some well documented default password and username combination and secondly, all the traffic between your client application and the server is encrypted.

**Service name:** db

**Project Website:** [PostgreSQL](https://postgresql.org) and [PostGIS](https://postgis.net/)

**Project Source Repository:** [postgres / postgres](https://github.com/postgres/postgres) and [postgis / postgis](https://git.osgeo.org/gitea/postgis/postgis)

**Project Technical Documentation:** [PostgreSQL Documentation](https://www.postgresql.org/docs/current/) and [PostGIS Documentation](https://postgis.net/docs/)

**Docker Repository:** [kartoza/postgis](https://hub.docker.com/r/kartoza/postgis)

**Docker Source Repository:** [kartoza / docker-postgis](https://github.com/kartoza/docker-postgis)

## Configuration

The project includes detailed documentation so this section only contains details relevant to the Open Source GIS Stack configuration.

### Database password:

Generate a strong password:

`pwgen 20 1`

Replace the default docker password for the postgres user with the strong password:

```
rpl “POSTGRES_PASSWORD=docker” “POSTGRES_PASSWORD=<strong password>” .env
```

### Service file configuration:

Service files entries serve two scenarios:

1. They are needed for opening QGIS projects stored in postgres with PG connection URI because at the project URI you cannot use QGIS authdb. If you prefer to store your projects on the file system, you should rather remove these lines (whole nginx section) since the authentication from pg_conf/pg_service.conf can be done more securely by QGIS authdb.
2. Used by your QGIS Server projects to connect to the database once the project is opened from either the file system of the database. You can either specify your password and username in service file or for more advanced configuration you can store user / password credentials in a QGIS authdb file. Refer to the authdb section and in qgis_conf/qgis-auth.db and the readme in
   that folder.

On your local machine you should create your own service file with the same service name but connection details that make sense when using the database from your local machine. When you upload your projects into the stack they will connect using the settings from the server hosted service file below assuming you used the same service name.

To carry out the service file configuration, copy, rename then edit the pg_service file in pg_config as per the example below (note that we also substitute in the database password created in the steps above).

```
cp pg_conf/pg_service.conf.example \ pg_conf/pg_service.confpassword=docker
rpl password=<your password> pg_conf/pg_service.conf
```

### Deployment

```
docker-compose --profile=postgres up -d
```

Note that the default configuration opens the postgresql service to all hosts. This is a potential security hole. If you open the port on the firewall e.g.

```
ufw allow 5432 tcp
```

Then be sure to connect from pg clients like psql or QGIS with SSL enabled so that passwords and data are not transmitted in clear text.

### Validation

Create a local pg_service.conf file like the example below and save it in `~/.pg_service.conf` or similar as appropriate to your operating system (see https://www.postgresql.org/docs/12/libpq-pgservice.html for details on configuration options).

```
[os-gis-stack]
dbname=gis
port=5432
host=<hostname of your server>
user=<your password>
password=docker
```

Now pass the server parameter to psql and list the databases as per the example below:

```
[timlinux@fedora ~]$ psql service=os-gis-stack -l
List of databases
```

| Name      | Owner    | Encoding | Collate | Ctype   | Access privileges |
| --------- | -------- | -------- | ------- | ------- | ----------------- |
| gis       | docker   | UTF8     | C.UTF-8 | C.UTF-8 |
| postgres  | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
| template0 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres       |
| template1 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres       |

`(4 rows)`

Test from QGIS is similar:

XXXXXXXXXXXXXX

Note that there was no need to supply any credentials other than the service file name.

## Deployment

```
make deploy-postgres
```

## Enabling

```
make enable-postgres
```

## Configuration

```
make configure-postgres
```

## Starting

```
make start-postgres
```

## Stopping

```
make stop-postgres
```

## Disabling

```
make  disable-postgres
```

## Polling the service logs

```
make db-logs
```

## Creating the service shell

```
make db-shell
```

## Reinitializing the service

```
make reinitialise-postgres
```

## Backing up data

To back up a QGIS project stored in db, run:

```
make db-qgis-project-backup
```

To back up the entire GIS postgres db, run:

```
make db-backup
```

To back up all postgres databases, run:

```
make db-backupall
```

To back up the mergin base schema from postgres db, run:

```
make db-backup-mergin-base-schema
```

## Restoring data

To restore a previously backed up QGIS project to db, run:

```
make db-qgis-project-restore
```

## Accessing the running services

The Postgres service can be accessed by creating a connection using the Postgres user and password provided in the .env file.

## Additional Notes

## References

<a id="1">[1]</a> The PostgreSQL Global Development Group. (n.d.). PostgreSQL: About. PostgreSQL: The World’s Most Advanced Open Source Relational Database. Retrieved August 22, 2021, from https://www.postgresql.org/about/

<a id="2">[2]</a> The PostgreSQL Global Development Group. (2021, August 12). 1. What Is PostgreSQL? PostgreSQL Documentation. https://www.postgresql.org/docs/current/intro-whatis.html

<a id="3">[3]</a> The PostGIS Development Group. (2021, August 20). PostGIS 3.1.4dev Manual. PostGIS - Documentation. https://postgis.net/docs/manual-3.1/
