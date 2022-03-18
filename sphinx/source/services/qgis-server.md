# QGIS Server - PR ![PR](https://img.shields.io/badge/pr-green?style=for-the-badge)

With the QGIS Server service you can publish one or more QGIS projects including: 

1. Projects stored in a PostgreSQL database.
2. Projects stored in the file system.

For the QGIS Server, we have chosen the OpenQuake build of QGIS Server because it has a few interesting characteristics. One, is that you can deploy QGIS server-side extensions easily with it and two, it supports things like the QGIS Authentication System. The QGIS Authentication System is an authentication database that provides more advanced security options, provides pg_service support, and provides some special features for URL rerouting so that your project paths are hidden away from the user (which is both a security and a convenience concern).

OSGS also provides a couple of sample plugins like a demonstrater plugin and a plugin for handling atlas reports. The demonstrater plugin is a modified version of the GetFeatureInfo handler and will return some HTML back and in a nicely formatted table. The plugin for handling atlas reports, written by Lizmap extends the QGIS getPrint support to allow you to request a specific page from an atlas print. This is pretty handy if you, for example, click on a feature and you want to get from an atlas report the one page for that feature in the atlas.

Another feature that Docker provides for applications such as QGIS Server is the ability to horizontally scale them. Our platform has some key configuration examples showing you how you can, for example, scale up the QGIS Server instance to have ten concurrently running instances. This is useful for handling increased or high load on the server. Scaling will create a round robin request handler, so that as the requests come in, it will pass each successive request over to the next running instance, and those requests will be handled by that instance, passed back and then that instance will stand by and wait for the next request to come in.

The QGIS Server works in orchestration with many of the other containers, including the PostGIS container. It also works pretty well in conjunction with the File Browser container which allows the users of the OSGS architecture to easily move data from their local machine onto the server, via the upload feature.

**Service name:** qgis-server

**Project Website:** [qgis.org](https://qgis.org/)

**Project Source Repository:** [qgis/QGIS](hhttps://github.com/qgis/QGIS)

**Project Project Technical Documentation:** [QGIS Server Guide/Manual](https://docs.qgis.org/3.16/en/docs/server_manual/index.html#)

**Docker Repository:** [openquake/qgis-server](https://hub.docker.com/r/openquake/qgis-server)

**Docker Source Repository:** [gem/oq-qgis-server](https://github.com/gem/oq-qgis-server/)

## Deployment

```
make deploy-qgis-server
```

## Enabling

```
make enable-qgis-server
```

## Starting

```
make start-qgis-server
```

## Stopping

```
make stop-qgis-server
```

## Disabling

```
make disable-qgis-server
```

## Restarting

```
make restart-qgis-server
```

## Logs

```
make qgis-server-logs
```

## Shell

```
make qgis-server-shell
```

## Accessing the running services

QGIS projects published by uploading the project in File Browser are available at `/ogc/project_name` which makes it very simple to discover where the projects are deployed on the server.

QGIS projects published through the Postgres connection service file for authentication or using the Postgres connection service file and the QGIS authentication database for authentication  are available at `/ogc-pg/project_URI`.

## Additional Notes

### Further Reading

You should read the [QGIS Server documentation](https://docs.qgis.org/3.16/en/docs/server_manual/getting_started.html#) on qgis.org. It is well written and covers a lot of background explanation which is not provided here. You should also familiarise yourself with the [Environment Variables](https://docs.qgis.org/3.16/en/docs/server_manual/config.html#environment-variables).

Alesandro Passoti has made a number of great resources available for QGIS Server. See his [workshop slide deck](http://www.itopen.it/bulk/FOSS4G-IT-2020/#/presentation-title) and his [server side plugin examples](https://github.com/elpaso/qgis3-server-vagrant/tree/master/resources/web/plugins), and [more examples here](https://github.com/elpaso/qgis-helloserver).

### QGIS Server Atlas Print Plugin

See the [project documentation](https://github.com/3liz/qgis-atlasprint/blob/master/atlasprint/README.md#api) for supported request parameters for QGIS Atlas prints.

### QGIS Server Scaling

If your server has the needed resources, you can dramatically improve response times for concurrent
QGIS server requests by scaling the QGIS server:

```
docker-compose --profile=qgis-server up -d --scale qgis-server=10 --remove-orphans

```

To take advantage of this, the locations/upstreams/qgis-server.conf should have one
server reference per instance e.g.

```
    upstream qgis-fcgi {
        # When not using 'host' network these must reflect the number
        # of containers spawned by docker-compose and must also have
        # names generated by it (including the name of the stack)
        server osgisstack_qgis-server_1:9993;
        server osgisstack_qgis-server_2:9993;
        server osgisstack_qgis-server_3:9993;
        server osgisstack_qgis-server_4:9993;
        server osgisstack_qgis-server_5:9993;
        server osgisstack_qgis-server_6:9993;
        server osgisstack_qgis-server_7:9993;
        server osgisstack_qgis-server_8:9993;
        server osgisstack_qgis-server_9:9993;
        server osgisstack_qgis-server_10:9993;
    }
```

<div class="admonition note">
Scaling to 10 instances is the default if you launch the QGIS server instance via the Make command `make deploy-qgis-server`.
</div>

Then restart Nginx too:

```
make restart-nginx
```

Note that if you do `docker-compose nginx up` it may bring down your scaled QGIS containers, so take care.

Finally check the logs of Nginx to make sure things are running right:

```
make nginx-logs
```
