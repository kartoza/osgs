# Mergin Client - WIP ![WIP](https://img.shields.io/badge/wip-red?style=for-the-badge)

>**Note**: This service is under development and not production ready yet.

This tool will synchronise a Mergin cloud project into a PostgreSQL project.

There are two modalities in which you can work with Mergin projects:

1. **[mergin-db-sync](mergin-db-sync.md)**: A Mergin project which is synchronised into a PostgreSQL
   database and supports bidirectional syncing and editing.
2. **[mergin-client](mergin-client.md) (covered here):** A folder containing multiple mergin projects (all of the projects shared with a mergin user). These projects are synchronised into the filesystem and published via QGIS Server as web mapping services.

**Service name:** mergin-client

**Project Website:** [Mergin](https://public.cloudmergin.com/)

**Project Source Repository:** [lutraconsulting
/ mergin-py-client](https://github.com/lutraconsulting/mergin-py-client)

**Project Technical Documentation:** [Mergin Python Client](https://github.com/lutraconsulting/mergin-py-client#readme)

**Docker Repository:** [kartoza/mergin-client](https://hub.docker.com/r/kartoza/mergin-client)

**Docker Source Repository:** [kartoza /mergin-client](https://github.com/kartoza/mergin-client)

## Configuration

```
make configure-mergin-client
```

## Reinitialising

```
make reinitialise-mergin-client
```

## Redeploying

```
make redeploy-mergin-client
```

## Accessing the running services

## Additional Notes

For field data collection and project synchronisation support see the following:

1. The [Mergin](https://public.cloudmergin.com/#) platform for cloud storage of projects
2. The [INPUT](https://inputapp.io/en/) mobile data collection platform

You use the Mergin client to clone one or more Mergin projects to the host running docker-compose and these projects are made available through QGIS Server.

One critical note is that the Project directory and the Project File names must be the same, otherwise QGIS Server will not recognize the project as being valid. For example:

- Valid: `FooProject/FooProject.qgz`
- Not Valid: `FooProject/BarProject.qgz`

Once published in this way, valid projects will be accessible from any OGC compliant
client (e.g. QGIS Desktop, OpenLayers, Leaflet) using the following URL Scheme:

`https://yourhost.com/ogc/yourproject`

For example, here is one we published for a client (domain name changed):

`https://example.org/ogc/Elevation`

You can read more about the mergin-client at the separate git repo [here](https://github.com/kartoza/mergin-client).
