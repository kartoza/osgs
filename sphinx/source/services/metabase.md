# Metabase - PR ![PR](https://img.shields.io/badge/pr-green?style=for-the-badge)



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

## Logs

```
make metabase-logs
```

## Shell

```
make metabase-shell
```

## Backing up

```
make backup-metabase
```

## Restoring 

```
make restore-metabase``


## Accessing the running service

After deploying the service, the metabase service is now accessible on `/metabase/setup` e.g. https://localhost/metabase/setup. To log in, use the token displayed when you run `make jupyter-token`.
