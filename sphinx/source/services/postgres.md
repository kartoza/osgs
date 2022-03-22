# Postgres and PostGIS - PR ![PR](https://img.shields.io/badge/pr-green?style=for-the-badge)

PostgreSQL is a powerful, open source object-relational database management system (ORDBMS) that uses and extends the SQL language combined with many features that safely store and scale the most complicated data workloads.[<sup>[1]</sup>](#1)[<sup>[2]</sup>](#2)

PostGIS is a spatial extension for PostgreSQL object-relational database. This allows for GIS (Geographic Information Systems) objects to be stored in the database.[<sup>[3]</sup>](#3)

The heart of any stack like the Open Source GIS Stack (OSGS) would be PostGIS and PostgreSQL. This is because, many of the other tools provided in the OSGS stack, for example, GeoServer, QGIS Server and Mergin, all rely on or can make use of PostGIS as a data storage platform and in some cases as a data analysis platform. OSGS provides PostgreSQL version 13 along with PostGIS, which are provided by the Kartoza PostGIS Docker container. There are a few considerations that were made when deploying this container. One, which is actually a general design consideration of OSGS, is to try and make everything as secure as possible out of the box, rather than leaving security as an afterthought. To fulfill this consideration, what OSGS does is, it spins up a PostgreSQL instance with PostGIS deployed in it and creates a separate user account for connecting to this instance. It also enables SSL encryption by default, as required to the PostgreSQL database. This is so that if you choose to open the port as a public service, firstly, we are not using some well documented default password and username combination and secondly, all the traffic between your client application and the server is encrypted.

**Service name:** db

**Project Website:** [postgresql.org](https://postgresql.org) and [postgis.net](https://postgis.net/)

**Project Source Repository:** [postgres/postgres](https://github.com/postgres/postgres) and [postgis/postgis](https://git.osgeo.org/gitea/postgis/postgis)

**Project Technical Documentation:** [PostgreSQL Documentation](https://www.postgresql.org/docs/current/) and [PostGIS Documentation](https://postgis.net/docs/)

**Docker Repository:** [kartoza/postgis](https://hub.docker.com/r/kartoza/postgis)

**Docker Source Repository:** [kartoza/docker-postgis](https://github.com/kartoza/docker-postgis)

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

## Logs

```
make db-logs
```

## Shell

```
make db-shell
```

## Creating a psql session

```
make db-psql-shell
```

## Restarting

```
make restart-postgres
```

## Backing up

To back up QGIS styles stored in the `gis` database, run:

```
make backup-db-qgis-styles
```

To back up QGIS projects stored in the `gis` database, run:

```
make backup-db-qgis-projects
```

To back up the entire `gis` database, run:

```
make backup-db-gis
```

To back up the mergin base schema from the `gis` database, run:

```
make backup-db-mergin-base-schema
```

To back up all the service's databases, run:

```
make backup-all-databases
```

## Restoring data

To restore the last back up of QGIS styles to the `gis` database, run:

```
restore-db-qgis-styles
``` 

To restore the last back up of QGIS projects to the `gis` database run:

```
restore-db-qgis-projects:
```

To restore the last back up of the `gis` database, run:

```
restore-db-gis
```

To restore the last back up of the mergin base schema to the `gis` database, run 

```
make restore-db-mergin-base-schema
```

To restore the last back up of all the service's databases, run:

```
make restore-all-databases
```

## Accessing the running services

The Postgres service can be accessed by creating a connection using the user `<POSTGRES_USER>` and password `<POSTGRES_PASSWORD>` provided in the `.env` file.

## References

<a id="1">[1]</a> The PostgreSQL Global Development Group. (n.d.). PostgreSQL: About. PostgreSQL: The World’s Most Advanced Open Source Relational Database. Retrieved August 22, 2021, from https://www.postgresql.org/about/

<a id="2">[2]</a> The PostgreSQL Global Development Group. (2021, August 12). 1. What Is PostgreSQL? PostgreSQL Documentation. https://www.postgresql.org/docs/current/intro-whatis.html

<a id="3">[3]</a> The PostGIS Development Group. (2021, August 20). PostGIS 3.1.4dev Manual. PostGIS - Documentation. https://postgis.net/docs/manual-3.1/
