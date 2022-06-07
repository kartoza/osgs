# QGIS Desktop - WIP ![WIP](https://img.shields.io/badge/wip-red?style=for-the-badge)

QGIS is a free, open source, cross platform, community-driven geographical information system (GIS) software. The OSGS QGIS Desktop service is a remote desktop application running in a browser.

**Service name:** qgis-desktop

**Project Website:** [qgis.org](https://qgis.org/)

**Project Source Repository:** [qgis/QGIS](https://github.com/qgis/QGIS)

**Project Project Technical Documentation:** [QGIS User Guide](https://docs.qgis.org/3.22/en/docs/user_manual/index.html)

**Docker Repository:** [tswetnam/xpra-qgis](https://hub.docker.com/r/tswetnam/xpra-qgis)

**Docker Source Repository:** [tyson-swetnam/qgis-xpra](https://github.com/tyson-swetnam/qgis-xpra)

## Deployment

```
make deploy-qgis-desktop
```

## Enabling

```
make enable-qgis-desktop
```

## Starting

```
make start-qgis-desktop
```

## Stopping

```
make stop-qgis-desktop
```

## Disabling

```
make disable-qgis-desktop
```

## Restarting

```
make restart-qgis-desktop
```

## Logs

```
make qgis-desktop-logs
```

## Shell

```
make qgis-desktop-shell
```

## Accessing the running services

After deploying the QGIS Desktop service, the service is accessible on /qgis-desktop/ e.g. https://localhost/qgis-desktop/. Log in to the service using the username `<NGINX_AUTH_USER>`     and password `<NGINX_AUTH_PWD>` specified in the `.env` file.