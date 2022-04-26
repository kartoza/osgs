# File Browser - PR ![PR](https://img.shields.io/badge/pr-green?style=for-the-badge)

File Browser is a web-based file browser/file manager. File Browser is used as the backend for managing the content that appears on the OSGS static website.

**Service name**: file-browser

**Project Website**: [filebrowser.org](https://filebrowser.org/)

**Project Source Repository**: [filebrowser/filebrowser](https://github.com/filebrowser/filebrowser)

**Project Technical Documentation**: [File Browser's official documentation](https://filebrowser.org/) 

**Docker Repository**: [filebrowser/filebrowser](https://hub.docker.com/r/filebrowser/filebrowser)

**Docker Source Repository**: [filebrowser/filebrowser](https://github.com/filebrowser/filebrowser)

## Deployment

```
make deploy-file-browser
```

## Enabling

```
make enable-file-browser
```

## Configuration

```
make configure-file-browser
```

## Starting

```
make start-file-browser
```

## Stopping

```
make stop-file-browser
```

## Disabling

```
make disable-file-browser
```

## Restarting

```
make restart-file-browser
```

## Logs

```
make file-browser-logs
```

## Shell

```
make file-browser-shell
```

## Accessing the running services

After deploying File Browser, the service can be accessed on /files/ e.g. https://localhost/files. Sign in to the File Browser service using the  username `<FILEBROWSER_USER>` and password `<FILEBROWSER_PASSWORD>` specified in the `.env` file.