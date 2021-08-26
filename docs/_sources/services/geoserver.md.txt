# GeoServer

**Service name:** geoserver

**Project Website:** [GeoServer](http://geoserver.org/)

**Project Source Repository:** [geoserver / geoserver](https://github.com/geoserver/geoserver)

**Project Technical Documentation:** [GeoServer Documentation](https://docs.geoserver.org/)

**Docker Repository:** [kartoza/geoserver](https://hub.docker.com/r/kartoza/geoserver)

**Docker Source Repository:** [kartoza / docker-geoserver](https://github.com/kartoza/docker-geoserver)

Short description

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


