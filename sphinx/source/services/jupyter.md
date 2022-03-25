# Jupyter Notebook - PR ![PR](https://img.shields.io/badge/pr-green?style=for-the-badge)

<div class="admonition warning">
Note - this service does not support multi-user collaboration yet. In the future we will add Jupyter Hub to support this.
</div>

**Service name:** 

**Project Website:** 

**Project Source Repository:** 

**Project Technical Documentation:** 

**Docker Repository:** 

**Docker Source Repository:** 

## Deployment 

```
make deploy-jupyter
```

## Enabling

```
make enable-jupyter
```

## Configuration 

```
make configure-jupyter
```

## Starting

```
make start-jupyter
```

## Get Jupyter Token

```
make jupyter-token
```

## Logs

```
make jupyter-logs
```

## Shell

```
make jupyter-shell
```

## Backing up

```
make backup-jupyter
```

## Restoring 

```
make restore-jupyter
```

## Accessing the running service

After deploying the service, the jupyter service is accessible on `jupyter/lab?` e.g. https://localhost/jupyter/lab?. To log in, use the token displayed when you run `make jupyter-token`.