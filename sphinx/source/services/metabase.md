# Metabase - PR ![PR](https://img.shields.io/badge/pr-green?style=for-the-badge)

Metabase is an open source business intelligence tool. You can connect your databases to Metabase and it will let you ask questions about your data, and display answers in formats that make sense on dashboards [<sup>[1]</sup>](#1).

**Service name:** metabase

**Project Website:** [metabase.com](https://www.metabase.com/)

**Project Source Repository:** [metabase/metabase](https://github.com/metabase/metabase)

**Project Technical Documentation:** [Metabase Documentation](https://www.metabase.com/docs/latest/)

**Docker Repository:** [metabase/metabase](https://hub.docker.com/r/metabase/metabase)

**Docker Source Repository:** [metabase/metabase](https://github.com/metabase/metabase)


## Deployment 

```
make deploy-metabase
```

## Enabling

```
make enable-metabase
```

## Configuration 

```
make configure-metabase
```

## Starting

```
make start-metabase
```

## Get Metabase Token

```
make metabase-token
```

## Stopping

```
make stop-metabase
```

## Disabling

```
make disable-metabase
```

## Restarting

```
make restart-metabase
```

## Logs

```
make metabase-logs
```

## Shell

Create a bash shell in the metabase container using:

```
make metabase-shell
```

Create a root bash shell in the metabase container using: 

```
make metabase-root-shell
```

## Backing up

```
make backup-metabase
```

## Restoring 

```
make restore-metabase
```

## Accessing the running service

After deploying the service, the metabase service is now accessible on `/metabase/` e.g. https://localhost/metabase/.

## References

<a id="1">[1]</a> “01 What Is Metabase.” Metabase | Business Intelligence, Dashboards, and Data Visualization, https://www.metabase.com/docs/latest/users-guide/01-what-is-metabase.html. Accessed 25 Mar. 2022.