# Production Stack

## Overview

In this section we will bring up the full production stack, but to do that we first need to get an SSL certificate issued. To facilitate this, there is a special, simplified, version of Nginx which has no reverse proxies in place and not docker dependencies. Here is an overview of the process:

1. Replace the domain name in your letsencrypt init script
2. Replace the email address in your letsencrypt init script
3. Replace the domain name in the certbot init nginx config file
4. Open up ports 80 and 443 on your firewall
5. Run the init script, ensuring it completed successfully
6. Shut down the minimal nginx
7. Replace the domain name in the production nginx config file
8. Generate passwords for geoserver, postgres, postgrest and update .env
9. Copy over the mapproxy template files
10. Run the production profile in docker compose

At the end of the process you should have a fully running production stack with these services:

IMAGE | PORTS | NAMES
------|-------|-------
nginx:alpine | 0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp |  osgisstack_nginx_1
quay.io/lkiesow/docker-scp | 22/tcp  |   osgisstack_scp_1 
kartoza/hugo-watcher:main |  1313/tcp | osgisstack_scp_1


The following ports will be accessible on the host to the docker services. You can, on a case by case basis, allow these through your firewall using ufw (uncomplicated firewall) to make them publicly accessible:

1. 80 - http:Only really needed during initial setup of your letsencrypt
   certificate
2. 443 - https: All web based services run through this port so that they are
   encrypted
3. 5432 - postgres: Only expose this publicly if you intend to allow remote
   clients to access the postgres database. 
4. 2222 - scp: The is an scp/sftp upload mechanism to mobilise data and
   resources to the web site

For those services that are not exposed to the host,  they are generally made
available over 443/SSL via reverse proxy in the Nginx configuration.

Some things should still be configured manually and deployed after the initial
deployment:

1.	Mapproxy configuration
2.	setup.sql (especially needed if you are planning to use postgrest)
3.	Hugo content management
4.	Landing page static HTML

And some services are not intended to be used as long running services.
especially the ODM related services.

## Configuration

We have written 2 make targets that automate the steps 1-10 described in the
overview above. Either target will ask you for your domain name, legitimate email address
and then go ahead and copy the templates over, replace placeholder domain names
and email address, generate passwords for postgres etc. and then run the
production stack. Remember you need to have ufw, rpl, make and pwgen installed
before running either of the commands below.

If you are going to use a self-signed certificate on a localhost (for testing) run:
```
make configure-ssl-self-signed
```

If you are going to use a letsencrypt signed certificate on a name host (for production) run:
```
make configure-letsencrypt-ssl
```


>**Note**: To manually refresh the letsencrypt SSL certificate, run 
`make refresh-letsencrypt`.