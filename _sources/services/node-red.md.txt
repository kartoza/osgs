# Node RED - PR ![PR](https://img.shields.io/badge/pr-green?style=for-the-badge)

Node RED is a flow-based low-code programming tool for creating event-driven applications. It provides a wide range of nodes in the browser-based flow editor  palette that make wiring together flows very easy. 

**Service name:** node-red

**Project Website:** [nodered.org](https://nodered.org/)

**Project Source Repository:** [node-red/node-red](https://github.com/node-red/node-red)

**Project Technical Documentation:** [Node-RED Documentation](https://nodered.org/docs/)

**Docker Repository:** [nodered/node-red-docker
](https://hub.docker.com/r/nodered/node-red-docker)

**Docker Source Repository:** [node-red/node-red-docker](https://github.com/node-red/node-red-docker)

## Deployment 

```
make deploy-node-red
```

## Enabling

```
make enable-node-red
```

## Configuration 

```
make configure-node-red
```

## Starting

```
make start-node-red
```

## Stopping

```
make stop-node-red
```

## Disabling

```
make disable-node-red
```

## Restarting

```
make restart-node-red
```

## Logs

```
make node-red-logs
```

## Shell 

```
make node-red-root-shell
```

## Backing up

```
make backup-node-red
```

## Restoring 

```
make restore-node-red
```

## Getting example data 

```
make add-node-red-example-data
```

## Accessing the running service

After deploying the service, the node-red service is now accessible on `/node-red/` e.g. https://localhost/node-red/.
