# Hugo Watcher - PR ![PR](https://img.shields.io/badge/pr-green?style=for-the-badge) ![EEK](https://img.shields.io/badge/eek-F9E79F?style=for-the-badge)

Hugo is a static site generator. Hugo builds pages when you create or update your content. Since websites are viewed far more often than they are edited, Hugo is designed to provide an optimal viewing experience for the website’s end users and an ideal writing experience for website authors. [<sup>[1]</sup>](#1)

The Hugo Watcher service watches for changes in the static content source files of the hugo site and rebuilds the site whenever a source file is changed.

**Service name:** hugo-watcher

**Project Website:** [gohugo.io](https://gohugo.io/)

**Project Source Repository:** [gohugoio/hugo](https://github.com/gohugoio/hugo)

**Project Project Technical Documentation:** [Hugo Documentation](https://gohugo.io/documentation/)

**Docker Repository:** [kartoza/hugo-watcher](https://hub.docker.com/r/kartoza/hugo-watcher)

**Docker Source Repository:** [kartoza/hugo-watcher](https://github.com/kartoza/hugo-watcher)

## Deployment

```
make deploy-hugo
```

## Enabling

```
make enable-hugo
```

## Configuration 

```
make site-config
```

## Starting

```
make start-hugo
```

## Stopping

```
make stop-hugo
```

## Disabling

```
make disable-hugo
```

## Restarting

```
make restart-hugo
```

## Logs

```
make hugo-logs
```

## Shell

```
make hugo-shell
```

## Backing up data

```
make backup-hugo
```

## Restoring data

```
make restore-hugo
```

## Get the Hugo theme

```
make get-hugo-theme
```

## Accessing the running services

The Hugo-Watcher service is configured and deployed as part of the initial stack. The initial stack consists of the Nginx, Hugo Watcher and Watchtower services. To deploy the initial stack, run `make configure-ssl-self-signed` or `make configure-letsencrypt-ssl`.

Use `make configure-ssl-self-signed` if you are going to use a self-signed certificate on a localhost for testing. Use `make configure-letsencrypt-ssl` if you are going to use a Let’s Encrypt signed certificate on a name host for production. Running `make configure-ssl-self-signed` will deploy the Nginx, Hugo Watcher and Watchtower services, but after running `make configure-letsencrypt-ssl` you will need to run `make deploy-hugo` to deploy the Nginx, Hugo Watcher and Watchtower services.

After deploying the initial stack, the static hugo website is available on `https://<server name>.com/`, where the `<server name>` is the hostname of the server where you have set up OSGS.

## Additional Notes

![EEK](https://img.shields.io/badge/eek-F9E79F?style=for-the-badge) Windows users may have issues with the file watcher running on the local file system, even when using virtualization frameworks like CYGWIN, WSL2, or Docker.

## References

<a id="1">[1]</a> Hugo Authors. (2020, June 3). About Hugo. Hugo. https://gohugo.io/about/what-is-hugo/
