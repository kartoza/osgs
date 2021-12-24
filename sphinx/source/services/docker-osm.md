# Docker OSM mirror - PR

OpenStreetMap (OSM) is a digital map database of the world built through crowdsourced volunteered geographic information. The data from OSM is freely available for visualization, query, download, and modification under [open licenses](https://www.openstreetmap.org/copyright). [[1]](#1) OSM can also be described as a free, editable map of the whole world [[2]](#2).

The Docker OSM mirror service is a docker compose project to setup an OSM PostGIS database with automatic updates from OSM periodically. The only files you need is a PBF file, geojson (if you intend to restrict data download to a smaller extent than the one specified by the PBF) and run the docker compose project.[[3]](#3)

The Docker OSM mirror service is composed of Docker ImpOSM3, Docker OSM Update and Docker OSM enrich. Docker ImpOSM3 takes the PBF file and imports it into the PostGIS OSM database. It will also apply any new diff file that arrives to the database. Docker OSM update runs every few minutes and regualarly fetches any new diff file for all the changes that have happened over the update interval from OpenStreetMap and applies any new features to your existing PostGIS OSM database. OSM enrich goes to the OSM API and gets the username and last change timestamp for each feature.[[3]](#3)

<img align="middle" src="https://raw.githubusercontent.com/kartoza/docker-osm/develop/docs/architecture.png" alt="OSM mirror Service " width="500">


**Service name:** osm-mirror

**Project Website:** [OpenStreetMap](https://www.openstreetmap.org/)

**Project Source Repository:** [openstreetmap / openstreetmap-website](https://github.com/openstreetmap/openstreetmap-website)

**Project Technical Documentation:** [OpenStreetMap Getting Help](openstreetmap.org/help)

**Docker Repository:** [kartoza/docker-osm](https://hub.docker.com/r/kartoza/docker-osm)

**Docker Source Repository:** [kartoza / docker-osm](https://github.com/kartoza/docker-osm)

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

## Stopping

```
make stop-osm-mirror   
```

## Disabling

```
make disable-osm-mirror
```

## Reinitialising 

```
make reinitialise-osm-mirror
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

```
make osm-mirror-osmupdate-shell

make osm-mirror-imposm-shell
```

## Accessing the running services


## Additional Notes

To deploy the Docker osm-mirror service, you need to follow the steps described [here](https://kartoza.github.io/osgs/workflows/create-osm-mirror-in-database.html). 


### OSM Attribution

Note that whenever you publish a map containing OSM data, be careful to adhere to the license and credit the OSM Project as per:

https://www.openstreetmap.org/copyright


## References

<a id="1">[1]</a> Quinn, S., & Dutton, J. A. (n.d.). OpenStreetMap and its use as open data | GEOG 585: Web Mapping. GEOG 585 Open Web Mapping. Retrieved August 30, 2021, from https://www.e-education.psu.edu/geog585/node/738


<a id="2">[2]</a> About OpenStreetMap - OpenStreetMap Wiki. (n.d.). OpenStreetMap Wiki. Retrieved August 30, 2021, from https://wiki.openstreetmap.org/wiki/About_OpenStreetMap

<a id="3">[3]</a> Kartoza. (n.d.). GitHub - kartoza/docker-osm: A docker compose project to setup an OSM PostGIS database with automatic updates from OSM periodically. GitHub. Retrieved August 30, 2021, from https://github.com/kartoza/docker-osm#readme
