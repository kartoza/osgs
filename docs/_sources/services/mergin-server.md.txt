# Mergin Server - WIP

<div class="admonition warning">
Note - this service is under development and not production ready yet.
</div>

Mergin is a web platform for storage and synchronisation of geospatial projects across multiple users and devices (desktop and mobile).The platform is especially useful when you need: 

- **Mobile data collection**. If you need to capture location of assets (and their attributes) or update an existing database.

- **Data sharing**. No complicated setup of access by IT admins to get your data to colleagues or clients. Set up permissions and send invites with few clicks.

- **Offline access**. Work with data with no interruption even without constant Internet connection - sync any changes when you are back online.

- **Collaborative editing**. No more problems dealing with multiple copies of the same dataset in different versions - all changes are automatically consolidated in one place.

- **Audit changes**. Knowing who has changed what and when in a database is often important - Mergin keeps track of the history and allows to go back if needed.

- **No coding required**. Everything can be set up with no knowledge of programming.
[[1]](#1)

**Project Website:** [Mergin](https://public.cloudmergin.com/)

**Project Source Repository:** [lutraconsulting / mergin](https://github.com/lutraconsulting/mergin)

**Project Technical Documentation:** [Mergin Help](https://help.cloudmergin.com/)

**Docker Repository:** [lutraconsulting/mergin](https://hub.docker.com/r/lutraconsulting/mergin)

**Docker Source Repository:** [lutraconsulting / mergin](https://github.com/lutraconsulting/mergin)

## Deployment

```
make deploy-mergin-server
```

## Enabling

```
make enable-mergin-server
```

## Configuration

```
make configure-mergin-server
```

## Starting

```
make start-mergin-server
```

## Stopping 

```
make stop-mergin-server
```

## Disabling

```
make disable-mergin-server
```

## Logs

```
make mergin-server-logs
```

## Shell 

```
make mergin-server-shell
```

## Restoring data

```
make restore-mergin-server-sql
```

## Accessing the running services

## Additional Notes

## References

<a id="1">[1]</a> Lutra Consulting. (n.d.). GitHub - lutraconsulting/mergin: Store and track changes to your geo-data. GitHub. Retrieved August 26, 2021, from https://github.com/lutraconsulting/mergin
