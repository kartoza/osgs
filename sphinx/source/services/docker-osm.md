# Docker OSM mirror - PR ![PR](https://img.shields.io/badge/pr-green?style=for-the-badge)

OpenStreetMap (OSM) is a digital map database of the world built through crowdsourced/volunteered geographic information. The data from OSM is freely available for visualization, querying, downloading, and modification under [open licenses](https://www.openstreetmap.org/copyright). [<sup>[1]</sup>](#1) OSM can also be described as a free, editable map of the whole world [<sup>[2]</sup>](#2).

The Docker OSM mirror service is a docker compose project to setup an OSM PostGIS database with automatic updates from OSM periodically. The only files you need are a PBF file, geojson (if you intend to restrict data download to a smaller extent than the one specified by the PBF) to run the docker compose project.[<sup>[3]</sup>](#3)

The Docker OSM mirror service is composed of Docker ImpOSM3, Docker OSM Update and Docker OSM enrich. Docker ImpOSM3 takes the PBF file and imports it into the PostGIS OSM database. It will also apply any new diff file that arrives to the database. Docker OSM update runs every few minutes and regularly fetches any new diff file for all the changes that have happened over the update interval from OpenStreetMap and applies any new features to your existing PostGIS OSM database. OSM enrich goes to the OSM API and gets the username and last change timestamp for each feature.[<sup>[3]</sup>](#3)

<img align="middle" src="https://raw.githubusercontent.com/kartoza/docker-osm/develop/docs/architecture.png" alt="OSM mirror Service " width="500">

**Service name:** osm-mirror

**Project Website:** [openstreetmap.org](https://www.openstreetmap.org/)

**Project Source Repository:** [openstreetmap/openstreetmap-website](https://github.com/openstreetmap/openstreetmap-website)

**Project Technical Documentation:** [OpenStreetMap Getting Help](https://openstreetmap.org/help)

**Docker Repository:** [kartoza/docker-osm](https://hub.docker.com/r/kartoza/docker-osm)

**Docker Source Repository:** [kartoza/docker-osm](https://github.com/kartoza/docker-osm)

## Deployment

```
make deploy-osm-mirror
```

## Enabling

```
make enable-osm-mirror
```

## Configuration

```
make configure-osm-mirror
```

## Starting

```
make start-osm-mirror
```

## Adding elevation data to the database

To add the SRTM 30m DEM and the derived contours for the OSM clip region to the database, use:

```
make add-db-osm-mirror-elevation
```

## Adding the OSM Mirror QGIS project

To add the Kartoza OSM Mirror QGIS project to the database, use: 

```
make add-db-osm-mirror-qgis-project
```

## Stopping

```
make stop-osm-mirror
```

## Disabling

```
make disable-osm-mirror
```

## Restarting

```
make resart-osm-mirror
```

## Creating a vector tiles store from the docker osm schema

```
make osm-to-mbtiles
```

## Logs

```
make osm-mirror-logs
```

## Shell

To create a shell in the osmupdate container, use:

```
make osm-mirror-osmupdate-shell
```

To create a shell in the imposm container, use: 

```
make osm-mirror-imposm-shell
```

## Accessing the running services

Once the service is deployed, the OSM Mirror layers are stored in the Postgres `gis` database. See the [Creating an Open Street Map mirror into your database workflow](https://kartoza.github.io/osgs/workflows/create-osm-mirror-in-database.html) on how to deploy the Docker OSM Mirror service and access the OSM Mirror data.

## Additional Notes

### OSM Attribution

Note that whenever you publish a map containing OSM data, be careful to adhere to the license and credit the OSM Project as per:

https://www.openstreetmap.org/copyright

## References

<a id="1">[1]</a> Quinn, S., & Dutton, J. A. (n.d.). OpenStreetMap and its use as open data | GEOG 585: Web Mapping. GEOG 585 Open Web Mapping. Retrieved August 30, 2021, from https://www.e-education.psu.edu/geog585/node/738

<a id="2">[2]</a> About OpenStreetMap - OpenStreetMap Wiki. (n.d.). OpenStreetMap Wiki. Retrieved August 30, 2021, from https://wiki.openstreetmap.org/wiki/About_OpenStreetMap

<a id="3">[3]</a> Kartoza. (n.d.). GitHub - kartoza/docker-osm: A docker compose project to setup an OSM PostGIS database with automatic updates from OSM periodically. GitHub. Retrieved August 30, 2021, from https://github.com/kartoza/docker-osm#readme
