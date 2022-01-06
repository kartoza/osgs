# Mergin-db-sync - PR ![PR](https://img.shields.io/badge/pr-green?style=for-the-badge)

<div class="admonition warning">
Note - this service only supports one synchronised Mergin project.
</div>

There are two modalities in which you can work with Mergin projects:

1. **[mergin-db-sync](mergin-db-sync.md) (covered here)**: A Mergin project which is synchronised into a PostgreSQL database and supports bidirectional syncing and editing.
2. **[mergin-client](mergin-client.md):** A folder containing multiple mergin projects (all of the projects shared with a mergin user). These projects are synchronised into the filesystem and published via QGIS Server as web mapping services.

**Service name:** mergin-sync

**Project Website:** [Mergin](https://public.cloudmergin.com/)

**Project Source Repository:** [lutraconsulting / mergin-db-sync](https://github.com/lutraconsulting/mergin-db-sync)

**Project Technical Documentation:** [DB Sync Script](https://github.com/lutraconsulting/mergin-db-sync#readme)

**Docker Repository:** [lutraconsulting/mergin-db-sync](https://hub.docker.com/r/lutraconsulting/mergin-db-sync)

**Docker Source Repository:** [lutraconsulting / mergin-db-sync](https://github.com/lutraconsulting/mergin-db-sync)

## Configuration

## Deployment

## Enabling

## Disabling

## Accessing the running services

## Additional Notes

In the .env file you should specify these options:

- **MERGIN_USER:** This is the user account that will be used to log in and
  pull/push updates to the Mergin project.
- **MERGIN_PASSWORD:** This is the user password for the above account.
- **MERGIN_PROJECT_NAME:** Specified in the form of `user/project` this is the
  Mergin project that will be synchronised into the database.
- **MERGIN_SYNC_FILE:** This is the name of a GeoPackage `yourgeopackage.gpkg`
  in the Mergin project whose schema will be replicated into a PostGIS schema
  as described below.
- **DB_SCHEMA_MODIFIED:** This is a PostgreSQL schema (schemas can be thought
  of as 'folders' within your database within which tables are found) that will
  contain the synchronised data form mergin. The content of the tables are
  editable via INSERT/UPDATE/DELETE operations, bit the structure of these
  tables (via ALTER commands) should not be attempted. Note that the replication
  is bidrectional, so changes made in the database are synchronised to all
  mergin clients and changes made in the distributed clients will make their
  way back into your database.
- **DB_SCHEMA_BASE:** This is a 'hands off' copy of the content in the
  MERGIN_SYNC_FILE that is stored in PostgreSQL to act as a reference when
  mergin calculates the changeset between the MODIFIED schema content and
  the remote copies of the data. DO NOT USE THIS and definately DO NOT
  EDIT THIS..
- **MERGIN_URL:** This is the public server where your mergin project is
  hosted. By default it would be "https://public.cloudmergin.com" unless
  you are self hosting the Mergin backend, or using an alternative hosted
  instance.

Note that in the docker-compose file, the assumption is made that the database
being used for Mergin syncing is called 'gis' and the hostname (in the private
docker network) is called 'db'. The username and password are taken from the
following keys in the .env file:

- POSTGRES_USER
- POSTGRES_PASSWORD
