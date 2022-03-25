# Jupyter Notebook - PR ![PR](https://img.shields.io/badge/pr-green?style=for-the-badge)

> **Note**: This service does not support multi-user collaboration yet. In the future we will add Jupyter Hub to support this.

The Jupyter Notebook is an open-source web application that allows data scientists to create and share documents that integrate live code, equations, computational output, visualizations, and other multimedia resources, along with explanatory text in a single document [<sup>[1]</sup>](#1).

The OSGS Jupyter Notebook service contains a Python & Jupyter environment with geopandas and moving pandas rolled in. Thanks to Anita Graser for the instructions and code to build a docker container with a Python & Jupyter environment: https://github.com/anitagraser/EDA-protocol-movement-data/blob/main/docker/Dockerfile and https://github.com/anitagraser/EDA-protocol-movement-data/tree/main/docker#docker-instructions.

**Service name:** jupyter

**Project Website:** [jupyter.org](https://jupyter.org/)

**Project Source Repository:** [jupyter/notebook](https://github.com/jupyter/notebook)

**Project Technical Documentation:** [The Jupyter Notebook](https://jupyter-notebook.readthedocs.io/en/latest/)

## Deployment 

```
make deploy-jupyter
```

## Build 

Since the service does not user a published docker repository, you need to ensure a build happens before running the service. 

```
make build-jupyter
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
## Stopping

```
make stop-jupyter
```

## Disabling

```
make disable-jupyter
```

## Restarting

```
make restart-jupyter
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

After deploying the service, the jupyter service is accessible on `/jupyter/lab?` e.g. https://localhostjupyter/lab?. To log in, use the token displayed when you run `make jupyter-token`.

## References

<a id="1">[1]</a> Science, O. D. S. C.- O. D. (2020, July 15). Why you should be using Jupyter Notebooks. Medium. Retrieved March 25, 2022, from https://odsc.medium.com/why-you-should-be-using-jupyter-notebooks-ea2e568c59f2 