# Mosquitto - PR ![PR](https://img.shields.io/badge/pr-green?style=for-the-badge)

Eclipse Mosquitto is an open source (EPL/EDL licensed) message broker that implements the MQTT protocol versions 5.0, 3.1.1 and 3.1. [<sup>1</sup>][1]

**Service name:** mosquitto

**Project Website:** [mosquitto.org](https://mosquitto.org/)

**Project Source Repository:** [eclipse/mosquitto](https://github.com/eclipse/mosquitto)

**Project Technical Documentation:** [Mosquitto Documentation](https://mosquitto.org/documentation/)

**Docker Repository:** [eclipse-mosquitto](https://hub.docker.com/_/eclipse-mosquitto)

**Docker Source Repository:** [eclipse/mosquitto](https://github.com/eclipse/mosquitto)

## Deployment 

```
make deploy-mosquitto
```

## Enabling

```
make enable-mosquitto
```

## Configuration 

```
make configure-mosquitto
```

## Starting

```
make start-mosquitto
```

## Stopping

```
make stop-mosquitto
```

## Disabling

```
make disable-mosquitto
```

## Restarting

```
make restart-mosquitto
```

## Logs

```
make mosquitto-logs
```

## Shell

```
make mosquitto-shell
```

## Backing up

```
make backup-mosquitto
```

## Restoring 

```
make restore-mosquitto
```


[1]: https://mosquitto.org/ "Eclipse Mosquitto. (2022). Retrieved 25 March 2022, from https://mosquitto.org/"