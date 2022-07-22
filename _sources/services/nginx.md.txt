# Nginx - PR ![PR](https://img.shields.io/badge/pr-green?style=for-the-badge)

Nginx is a lightweight web server acting as a proxy in front of QGIS Server and as a server for the static HTML content.

**Service name:** nginx

**Project Website:** [nginx.com](https://www.nginx.com/)

**Project Source Repository:** [nginx/nginx](https://github.com/nginx/nginx)

**Project Technical Documentation:** [nginx documentation](http://nginx.org/en/docs/)

**Docker Repository:** [nginx](https://hub.docker.com/_/nginx)

**Docker Source Repository:** [nginxinc/docker-nginx](https://github.com/nginxinc/docker-nginx)

## Deployment

The Nginx service is configured and deployed as part of the initial stack. The initial stack consists of the Nginx, Hugo Watcher and Watchtower services. To deploy the initial stack, run `make configure-ssl-self-signed` or `make configure-letsencrypt-ssl`.

Use `make configure-ssl-self-signed` if you are going to use a self-signed certificate on a localhost for testing. Use `make configure-letsencrypt-ssl` if you are going to use a Let’s Encrypt signed certificate on a name host for production. Running `make configure-ssl-self-signed` will deploy the Nginx, Hugo Watcher and Watchtower services, but after running `make configure-letsencrypt-ssl` you will need to run `make deploy-hugo` to deploy the Nginx, Hugo Watcher and Watchtower services.

## Starting

```
make start-nginx
```

## Stopping

```
make stop-nginx
```

## Restarting

```
make restart-nginx
```

## Logs

```
make nginx-logs
```

## Shell

```
make nginx-shell
```

## Accessing the running services

After deploying the initial stack, the static hugo website is available on `https://<server name>.com/`, where the `<server name>` is the hostname of the server where you have set up OSGS.