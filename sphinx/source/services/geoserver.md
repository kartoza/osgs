# GeoServer

GeoServer is a Java-based server, built on [GeoTools](https://geotools.org/),  that allows users to view and edit geospatial data, using the open standards set forth by the [Open Geospatial Consortium (OGC)](http://www.opengeospatial.org/). By implementing the [Web Map Service (WMS)](https://www.ogc.org/standards/wms) standard, GeoServer can create maps in a variety of output formats. GeoServer also conforms to the [Web Feature Service (WFS)](https://www.ogc.org/standards/wfs) standard, and [Web Coverage Service (WCS)](https://www.ogc.org/standards/wcs) standard which permits the sharing and editing of the data that is used to generate the maps. GeoServer also uses the [Web Map Tile Service](https://www.ogc.org/standards/wmts) standard to split your published maps into tiles for ease of use by web mapping and mobile applications.  [OpenLayers](https://openlayers.org/), a free mapping library, is integrated into GeoServer, making map generation quick and easy. GeoServer is a modular application with additional functionality added via extensions.[[1]](#1)

**Service name:** geoserver

**Project Website:** [GeoServer](http://geoserver.org/)

**Project Source Repository:** [geoserver / geoserver](https://github.com/geoserver/geoserver)

**Project Technical Documentation:** [GeoServer Documentation](https://docs.geoserver.org/)

**Docker Repository:** [kartoza/geoserver](https://hub.docker.com/r/kartoza/geoserver)

**Docker Source Repository:** [kartoza / docker-geoserver](https://github.com/kartoza/docker-geoserver)

## Configuration

```
make configure-geoserver-passwd
```

## Deployment

```
make deploy-geoserver
```
## Enabling

```
make enable-geoserver
```

## Disabling

```
make disable-geoserver
```

## Starting

```
make start-geoserver
```

## Logs

```
make geoserver-logs
```

## Accessing the running services

The services can be accessed on /geoserver/ e.g. https://localhost/geoserver.

Look in the .env file for the administrator password.


## Additional Notes

After configuring, you should remember to set the master password as per
https://docs.geoserver.geo-solutions.it/edu/en/security/security_overview.html#the-master-password
(which is different to the admin password).

## References

<a id="1">[1]</a> Open Source Geospatial Foundation. (n.d.). About - GeoServer. GeoServer. Retrieved August 21, 2021, from http://geoserver.org/about/
