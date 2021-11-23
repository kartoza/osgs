SHELL := /bin/bash

help:
	@echo "  ___  ____   ____ ____"
	@echo " / _ \/ ___| / ___/ ___|"
	@echo "| | | \___ \| |  _\___ \ "
	@echo "| |_| |___) | |_| |___) | "
	@echo " \___/|____/ \____|____/ "
	@echo 
	@echo "Open Source GIS Stack"
	@echo "Brought to you by Kartoza (Pty) Ltd."
	@echo 
	@echo "Help for using this Makefile"
	@echo
	@echo "For detailed help please visit:"
	@echo "https://kartoza.github.io/osgs/introduction.html"
	@echo
	@echo "------------------------------------------------------------------"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort  | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m - %s\n", $$1, $$2}'

compose-diagram: ## Generate a diagram of the docker-compose file
	@echo ""
	@echo "Generating diagram of docker architecture"
	@echo ""
	@docker run --rm -it --name dcv -v $(pwd):/input pmsipilot/docker-compose-viz render -m image docker-compose.yml

backup-everything: ## Sequentially run through all backup scripts
	@make backup-hugo
	-@make backup-db-qgis-styles
	-@make backup-db-qgis-project
	@make backup-db
	@make backup-all-databases
	-@make backup-mergin-base-db-schema
	@make backup-node-red
	@make backup-mosquitto
	@make backup-jupyter


# We need to declare phony here since the docs dir exists
# otherwise make tries to execute the docs file directly
.PHONY: docs
docs: ## Generate documentation and place results in docs folder.
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Making sphinx docs"
	@echo "------------------------------------------------------------------"
	$(MAKE) -C sphinx html
	@cp -r  sphinx/build/html/* docs
	$(MAKE) -C sphinx latexpdf
	@cp sphinx/build/latex/osgs.pdf osgs-manual.pdf


ps: ## List all running docker contains
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Current status"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose ps


deploy: configure ## Deploy the initial stack including nginx, scp and hugo-watcher
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting basic nginx site"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f

copy-overrides: ## Copy the docker overrides example if it does not already exist
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Copying overrides"
	@echo "------------------------------------------------------------------"
	@if [ -f "docker-compose.override.yml" ]; then echo "Docker composer override already exists."; exit 0; fi
	@cp docker-compose.override.yml.example docker-compose.override.yml


disable-all-services: ## Disable all services - does not actually stop them
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Disabling services"
	@echo "This will remove any symlinks in conf/nginx_conf/locations and conf/nginx_conf/upstreams"
	@echo "effectively disabling all services exposed by nginx"
	@echo "------------------------------------------------------------------"
	@echo -n "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	@find ./conf/nginx_conf/locations -maxdepth 1 -type l -delete
	@find ./conf/nginx_conf/upstreams -maxdepth 1 -type l -delete
	@echo "" > enabled-profiles

prepare-templates: ## Prepare templates
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Preparing templates"
	@echo "This will replace any local configuration changes you have made"
	@echo "in .env, conf/nginx_conf/servername.conf"
	@echo "------------------------------------------------------------------"
	@echo -n "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	@cp .env.example .env
	@cp conf/nginx_conf/servername.conf.example conf/nginx_conf/servername.conf
	@echo "Please enter your valid domain name for the site."
	@echo "e.g. example.org or subdomain.example.org:"
	@read -p "Domain name: " DOMAIN; \
		rpl example.org $$DOMAIN conf/nginx_conf/servername.conf .env; 
	@echo "We are going to set up a self signed certificate now."

configure:
	@echo "Please run either make configure-ssl-self-signed or make configure-letsencrypt-ssl"	

configure-ssl-self-signed: disable-all-services prepare-templates ## Create a self signed cert for local testing
	@mkdir -p ./certbot/certbot/conf/
	@openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./certbot/certbot/conf/nginx-selfsigned.key -out ./certbot/certbot/conf/nginx-selfsigned.crt
	@cp conf/nginx_conf/ssl/certificates.conf.selfsigned.example conf/nginx_conf/ssl/ssl.conf
	make site-config 
	make enable-hugo 
	make configure-scp 
	make configure-htpasswd 
	make deploy 
	#@rpl "BEGIN CERTIFICATE" "BEGIN TRUSTED CERTIFICATE" ./certbot/certbot/conf/nginx-selfsigned.crt
	#@rpl "END CERTIFICATE" "END  TRUSTED CERTIFICATE" ./certbot/certbot/conf/nginx-selfsigned.crt
	#@rpl "BEGIN PRIVATE KEY" "TRUSTED CERTIFICATE" ./certbot/certbot/conf/nginx-selfsigned.key
	#@rpl "END PRIVATE KEY" "TRUSTED CERTIFICATE" ./certbot/certbot/conf/nginx-selfsigned.key

configure-letsencrypt-ssl: disable-all-services prepare-templates ## Create a certbot SSL certificate for use in production
	@make check-env
	@echo "Do you want to set up SSL using letsencrypt?"
	@echo "This is recommended for production!"
	@echo -n "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	@cp conf/nginx_certbot_init_conf/nginx.conf.example conf/nginx_certbot_init_conf/nginx.conf
	@cp init-letsencrypt.sh.example init-letsencrypt.sh
	@cp conf/nginx_conf/ssl/certificates.conf.example conf/nginx_conf/ssl/ssl.conf
	@rpl example.org $(shell grep DOMAIN .env| sed 's/DOMAIN=//') \
		conf/nginx_certbot_init_conf/nginx.conf \
		conf/nginx_conf/ssl/ssl.conf \
		init-letsencrypt.sh; 
	@read -p "Valid Contact Person Email Address: " EMAIL; \
	   rpl validemail@yourdomain.org $$EMAIL init-letsencrypt.sh .env
	make configure-htpasswd 
	./init-letsencrypt.sh

site-config: ## Configure the hugo static site
	@echo "------------------------------------------------------------------"
	@echo "Configure your static site content management system"
	@echo "You should only do this once per site deployment"
	@echo "------------------------------------------------------------------"
	@echo "This will replace any local configuration changes you have made"
	@echo "------------------------------------------------------------------"
	@echo -n "Are you sure you want to continue? [y/N] " && read ans && [ $${ans:-N} = y ]
	@cp ./conf/hugo_conf/config.yaml.example ./conf/hugo_conf/config.yaml
	@rpl -q {{siteDomain}} $(shell grep DOMAIN .env| sed 's/DOMAIN=//') $(shell pwd)/conf/hugo_conf/config.yaml
	@echo "Please enter the title of your website (default 'Geoservices')"
	@read -p "Site Title: " result; \
	  SITETITLE=$${result:-"Geoservices"} && \
	  rpl -q {{siteTitle}} "$$SITETITLE" $(shell pwd)/conf/hugo_conf/config.yaml
	@echo "Please enter the name of the website owner (default 'Kartoza')"
	@read -p "Site Owner: " result; \
	  SITEOWNER=$${result:-"Kartoza"} && \
	  rpl -q {{ownerName}} "$$SITEOWNER" $(shell pwd)/conf/hugo_conf/config.yaml
	@echo "Please supply the URL of the site owner (default 'www.kartoza.com')."
	@read -p "Owner URL: " result; \
	  OWNERURL=$${result:-"www.kartoza.com"} && \
	  rpl -q {{ownerDomain}} "$$OWNERURL" $(shell pwd)/conf/hugo_conf/config.yaml
	@echo "Please supply a valid public URL to the Website Logo."
	@echo "Be sure to include the protocol prefix (e.g. https://)"
	@read -p "Logo URL: " result; \
	  LOGOURL=$${result:-"img/Circle-icons-stack.svg"} && \
	  rpl -q {{logoURL}} "$$LOGOURL" $(shell pwd)/conf/hugo_conf/config.yaml

# Used by configure-htpasswd to see if we have already set a password...
HTUSERCONFIGURED = $(shell cat .env | grep -o 'NGINX_AUTH_USER')
HTPASSWDCONFIGURED = $(shell cat .env | grep 'NGINX_AUTH_PWD')

configure-htpasswd: ## Set up a password authentiation for password protected ares of the site
	@make check-env
	@echo "------------------------------------------------------------------"
	@echo "Configuring password controlled file sharing are for your site"
	@echo "Accessible at /downloads/"
	@echo "Access credentials will be stored in .env"
	@echo "------------------------------------------------------------------"
	#Sometimes docker will make a directory if the pwd file does not 
	#exist when it starts
	@if [ -d "conf/nginx_conf/htpasswd" ]; then rm -rf conf/nginx_conf/htpasswd; fi
	@if [ -f "conf/nginx_conf/htpasswd" ]; then echo "htpasswd file already exists, skipping"; exit 0; fi
	# bcrypt encrypted pwd, be sure to use nginx:alpine nginx image
# keep unindented or make will treat ifeq as bash rather than make cmd and fail
ifeq ($(HTUSERCONFIGURED),NGINX_AUTH_USER)
	@echo "Web user password is already configured. Please see .env"
	@echo "Current password for web user is:"
	@echo $(HTPASSWDCONFIGURED)
else
	@export PASSWD=$$(pwgen 20 1); \
		htpasswd -cbB conf/nginx_conf/htpasswd web $$PASSWD; \
		echo "#User account for protected areas of the site using httpauth" >> .env; \
		echo "#You can add more accounts to conf/nginx_conf/htpasswd using the htpasswd tool" >> .env; \
		echo "NGINX_AUTH_USER=web" >> .env; \
		echo "NGINX_AUTH_PWD=$$PASSWD" >> .env; \
		echo "File sharing htpasswd set to $$PASSWD" 
endif
	@make enable-downloads

#------------------ Nginx ------------------------
start-nginx: ## Start the Nginx docker container.
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting NGINX"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d nginx

stop-nginx: ## Stop the Nginx docker container.
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Stopping NGINX"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose stop nginx
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm nginx

restart-nginx: ## Restart the Nginx docker container.
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restarting NGINX"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose restart nginx
	make nginx-logs


nginx-shell: ## Create an shell in the Nginx docker container for debugging.
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating nginx shell"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec nginx /bin/sh

nginx-logs: ## Display the logs of Nginx. Press Ctrl-C to exit.
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Tailing logs of nginx. Press Ctrl-c to exit."
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f nginx


#----------------- Hugo --------------------------

deploy-hugo: enable-hugo site-config start-hugo

enable-hugo: ## Enable the Hugo static content management system.
	-@cd conf/nginx_conf/locations; ln -s hugo.conf.available hugo.conf
	@echo "hugo" >> enabled-profiles

start-hugo: ## Start the Hugo static content management system.
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting Hugo"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d

stop-hugo: ## Stop the Hugo static content management system.
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Stopping Hugo"
	@echo "------------------------------------------------------------------"
	-@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill hugo-watcher
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm hugo-watcher

disable-hugo: ## Disable the Hugo static content management system.
	@cd conf/nginx_conf/locations; rm hugo.conf
	# Remove from enabled-profiles
	@sed -i '/hugo/d' enabled-profiles

hugo-logs: ## Display the logs of the hugo-watcher process-
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Polling hugo logs"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f hugo-watcher

hugo-shell: ## Create a shell in the Hugo container for debugging.
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating hugo shell"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec hugo-watcher bash

backup-hugo: ## Create backups of the Hugo content folder.
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating a backup of hugo"
	@echo "------------------------------------------------------------------"
	-@mkdir -p backups
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose run --rm -v ${PWD}/backups:/backups nginx sh -c "tar cvfz /backups/hugo-backup.tar.gz /hugo"
	@cp backups/hugo-backup.tar.gz backups/hugo-backup-$$(date +%Y-%m-%d).tar.gz

restore-hugo: ## Restore the last backup of the Hugo content folder.
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restore last backup of hugo from /backups/hugo-backup.tar.gz"
	@echo "If you wist to restore an older backup, first copy it to /backups/hugo-backup.tar.gz"
	@echo "Note: Restoring will OVERWRITE all data currently in your hugo content dir."
	@echo "------------------------------------------------------------------"
	@echo -n "Are you sure you want to continue? [y/N] " && read ans && [ $${ans:-N} = y ]
	-@mkdir -p backups
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose run --rm -v ${PWD}/backups:/backups nginx sh -c "cd /hugo && tar xvfz /backups/hugo-backup.tar.gz --strip 1"

get-hugo-theme:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Getting hugo theme"
	@echo "------------------------------------------------------------------"
	@export THEME=clarity; wget -O - https://github.com/gohugoio/hugoThemes | grep '<a data-skip-pjax="true" href="' | grep -o "<span title=\".*\">" | sed 's/<span title="//g' | sed 's/"><a data-skip-pjax="true" href="/ /g' | sed 's/">//g' | sed 's/\/tree\//\/archive\//g' | awk '{print  $1 , "https://github.com"$4".zip" }' > themes.txt ; egrep "${THEME}" themes.txt | awk '{print $2}' | xargs wget -O ${THEME}.zip

#----------------- SCP --------------------------

deploy-scp: enable-scp configure-scp start-scp ## Deploy the Secure Copy service.

enable-scp: ## Enable the Secure Copy service.
	@make check-env
	@echo "scp" >> enabled-profiles

configure-scp: ## Configure the Secure Copy service.
	@make check-env
	@echo "------------------------------------------------------------------"
	@echo "Copying .ssh/authorized keys to all scp shares."
	@echo "------------------------------------------------------------------"
	@cat ~/.ssh/authorized_keys > conf/scp_conf/geoserver_data
	@cat ~/.ssh/authorized_keys > conf/scp_conf/qgis_projects
	@cat ~/.ssh/authorized_keys > conf/scp_conf/qgis_fonts
	@cat ~/.ssh/authorized_keys > conf/scp_conf/qgis_svg
	@cat ~/.ssh/authorized_keys > conf/scp_conf/hugo_static
	@cat ~/.ssh/authorized_keys > conf/scp_conf/hugo_data
	@cat ~/.ssh/authorized_keys > conf/scp_conf/odm_data
	@cat ~/.ssh/authorized_keys > conf/scp_conf/general_data
	@cat ~/.ssh/authorized_keys > conf/scp_conf/jupyter_data

start-scp: ## Start the Secure Copy service.
	@make check-env
	@echo "------------------------------------------------------------------"
	@echo "Starting SCP"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d scp	

stop-scp: ## Stop the Secure Copy services.
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Stopping SCP"
	@echo "------------------------------------------------------------------"
	-@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill scp
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm scp

disable-scp: ## Disable the Secure Copy service.
	# Remove from enabled-profiles
	@sed -i '/db/d' enabled-profiles

scp-logs: ## Show the logs for the Secure Copy service.
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Polling SCP logs"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f scp

scp-shell: ## Create a shell inside the Secure Copy container for debugging.
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating SCP shell"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec scp sh 

#----------------- GeoServer --------------------------

deploy-geoserver: enable-geoserver configure-geoserver-passwd start-geoserver ## Deploy the GeoServer service.

enable-geoserver: ## Enable the Geoserver service.
	@make check-env
	-@cd conf/nginx_conf/locations; ln -s geoserver.conf.available geoserver.conf
	@echo "geoserver" >> enabled-profiles

configure-geoserver-passwd:
	@make check-env
	@export PASSWD=$$(pwgen 20 1); \
		rpl GEOSERVER_ADMIN_PASSWORD=myawesomegeoserver GEOSERVER_ADMIN_PASSWORD=$$PASSWD .env; \
		echo "GeoServer password set to $$PASSWD"

start-geoserver:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting GeoServer"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose restart nginx

stop-geoserver:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Stopping GeoServer"
	@echo "------------------------------------------------------------------"
	-@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill geoserver
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm geoserver

disable-geoserver:
	@make check-env
	@cd conf/nginx_conf/locations; rm geoserver.conf
	# Remove from enabled-profiles
	@sed -i '/geoserver/d' enabled-profiles

geoserver-logs:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Polling Geoserver logs"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f geoserver

geoserver-shell:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating Geoserver shell"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec geoserver bash


#----------------- QGIS Server --------------------------

deploy-qgis-server: enable-qgis-server start-qgis-server

enable-qgis-server:
	@make check-env
	-@cd conf/nginx_conf/locations; ln -s qgis-server.conf.available qgis-server.conf
	-@cd conf/nginx_conf/upstreams; ln -s qgis-server.conf.available qgis-server.conf
	@echo "qgis-server" >> enabled-profiles

restart-qgis-server:  ## Stop and restart the QGIS server containers
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restarting QGIS Server containers"
	@echo "------------------------------------------------------------------"
	# Need to flush this completely for it to work on restart
	make stop-qgis-desktop
	make start-qgis-desktop


start-qgis-server:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting QGIS Server"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d --scale qgis-server=10 --remove-orphans
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose restart nginx

stop-qgis-server:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Stopping QGIS Server and Nginx"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill qgis-server
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm qgis-server

disable-qgis-server:
	@make check-env
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill qgis-server
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm qgis-server
	@cd conf/nginx_conf/locations; rm qgis-server.conf
	@cd conf/nginx_conf/upstreams; rm qgis-server.conf
	# Remove from enabled-profiles
	@sed -i '/qgis/d' enabled-profiles

qgis-server-logs:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Polling QGIS Server logs"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f qgis-server

qgis-server-shell:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating QGIS Server shell"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec qgis-server bash

reinitialise-qgis-server:rm-qgis-server start-qgis-server
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restarting QGIS Server and Nginx"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose restart nginx
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f qgis-server 

#----------------- QGIS Desktop --------------------------

deploy-qgis-desktop: enable-qgis-desktop start-qgis-desktop  ## Run QGIS Desktop in your web browser

enable-qgis-desktop:
	@make check-env
	-@cd conf/nginx_conf/locations; ln -s qgis-desktop.conf.available qgis-desktop.conf
	#-@cd conf/nginx_conf/upstreams; ln -s qgis-desktop.conf.available qgis-desktop.conf
	@echo "qgis-desktop" >> enabled-profiles

start-qgis-desktop:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting QGIS Server"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d qgis-desktop
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose restart nginx

stop-qgis-desktop:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Stopping QGIS Server and Nginx"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill qgis-desktop
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm qgis-desktop

disable-qgis-desktop:
	@make check-env
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill qgis-desktop
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm qgis-desktop
	@cd conf/nginx_conf/locations; rm qgis-desktop.conf
	#@cd conf/nginx_conf/upstreams; rm qgis-desktop.conf
	# Remove from enabled-profiles
	@sed -i '/qgis/d' enabled-profiles

qgis-desktop-logs:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Polling QGIS Desktop logs"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f qgis-desktop

qgis-desktop-shell:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating QGIS Desktop shell"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec qgis-desktop bash

reinitialise-qgis-desktop:stop-qgis-desktop start-qgis-desktop
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restarting QGIS Desktop and Nginx"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose restart nginx
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f qgis-desktop 


#----------------- Mapproxy --------------------------

deploy-mapproxy: enable-mapproxy configure-mapproxy start-mapproxy

enable-mapproxy:
	@make check-env
	-@cd conf/nginx_conf/locations; ln -s mapproxy.conf.available mapproxy.conf
	@echo "mapproxy" >> enabled-profiles

configure-mapproxy:
	@make check-env
	@echo "=========================:"
	@echo "Mapproxy configurations:"
	@echo "=========================:"
	@cp conf/mapproxy_conf/mapproxy.yaml.example conf/mapproxy_conf/mapproxy.yaml 
	@cp conf/mapproxy_conf/seed.yaml.example conf/mapproxy_conf/seed.yaml 
	@echo "We have created template mapproxy.yaml and seed.yaml"
	@echo "configuration files in conf/mapproxy_conf."
	@echo "You will need to hand edit those files and then "
	@echo "restart mapproxy for those edits to take effect."
	@echo "see: make reinitialise-mapproxy"	

start-mapproxy:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting Mapproxy"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose -up -d 
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose restart nginx

stop-mapproxy:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Stopping Mapproxy"
	@echo "------------------------------------------------------------------"
	-@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill mapproxy
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm mapproxy

disable-mapproxy:
	@make check-env
	@cd conf/nginx_conf/locations; rm mapproxy.conf
	# Remove from enabled-profiles
	@sed -i '/mapproxy/d' enabled-profiles

mapproxy-logs:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Polling Mapproxy logs"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f mapproxy

mapproxy-shell:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating Mapproxy shell"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec mapproxy bash

reinitialise-mapproxy:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restarting Mapproxy and clearing its cache"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill mapproxy
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm mapproxy
	@rm -rf conf/mapproxy_conf/cache_data/*
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d mapproxy
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f mapproxy


#----------------- Postgres --------------------------

deploy-postgres:enable-postgres configure-postgres start-postgres

enable-postgres:
	@make check-env
	@echo "db" >> enabled-profiles

configure-timezone:
	@make check-env
	@if grep "#TIMEZONE CONFIGURED" .env; then echo "Timezone already configured";  exit 0; else \
	echo "Please enter the timezone for your server"; \
	echo "See https://en.wikipedia.org/wiki/List_of_tz_database_time_zones"; \
	echo "Follow exactly the format of the TZ Database Name column"; \
	read -p "Server Time Zone (e.g. Etc/UTC):" TZ; \
	   rpl TIMEZONE=Etc/UTC TIMEZONE=$$TZ .env; \
	echo "#TIMEZONE CONFIGURED" >> .env; \
	fi

configure-postgres: configure-timezone 
	@make check-env
	@echo "=========================:"
	@echo "Postgres configuration:"
	@echo "=========================:"
	@export PASSWD=$$(pwgen 20 1); \
		rpl POSTGRES_PASSWORD=docker POSTGRES_PASSWORD=$$PASSWD .env; \
		echo "Postgres password set to $$PASSWD"
	@echo "We are going to enable access to Postgres on your host."
	@echo "Typically you would do this when you want to access the database"
	@echo "from software such as QGIS that can directly connect to a Postgres"
	@echo "database. There are some security implications to running on "
	@echo "a publicly accessible port. People with credentials to access your "
	@echo "database may use those credentials to launch arbitrary applications "
	@echo "inside the database container if you do not manage the permissions carefully."
	@echo "Note that the database is configured to require"
	@echo "SSL secure encryption on all connections to the database. This includes"
	@echo "internally between docker containers and from an external client. So be sure"
	@echo "to set your client SSL mode to 'REQUIRE' (e.g. in QGIS  / GeoServer / Node-Red etc.)."
	@echo 
	@echo "If you want to allow/disallow access to this service from other hosts, please use"
	@echo "firewall software such as ufw (uncomplicated firewall) to allow traffic on"
	@echo "your chosen public port."
	@echo
	@echo "Enter to the public port to access PG from the host."
	@echo
	@read -p "Postgis Public Port (e.g. 5432):" PORT; \
	   rpl POSTGRES_PUBLIC_PORT=5432 POSTGRES_PUBLIC_PORT=$$PORT .env; 

start-postgres:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting Postgres"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d 

stop-postgres:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Stopping Postgres"
	@echo "------------------------------------------------------------------"
	-@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill db
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm db

disable-postgres:
	@make check-env
	@echo "This is currently a stub"	
	# Remove from enabled-profiles
	@sed -i '/db/d' enabled-profiles

db-logs:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Polling db logs"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f db

db-shell: ## Create a bash shell in the db container
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating db bash shell"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db bash

db-psql-shell: ## Create a psql session in the db container connected to the gis database
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating db psql shell"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db psql gis


reinitialise-postgres:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restarting postgres"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill db
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm db
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d db
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f db

backup-db-qgis-styles: ## Backup QGIS Styles in the gis database
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Backing up QGIS styles stored in gis db"
	@echo "------------------------------------------------------------------"
	-@mkdir -p backups
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db pg_dump -f /tmp/QGISStyles.sql -t public.layer_styles gis
	@docker cp osgisstack_db_1:/tmp/QGISStyles.sql backups
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db rm /tmp/QGISStyles.sql
	@cp backups/QGISStyles.sql backups/QGISStyles-$$(date +%Y-%m-%d).sql
	@ls -lah backups/*.sql

restore-db-qgis-styles:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restoring QGIS styles to gis db"
	@echo "------------------------------------------------------------------"
	@docker cp backups/QGISStyles.sql osgisstack_db_1:/tmp/ 
	# - at start of next line means error will be ignored (in case QGIS project table isnt already there)
	-@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db psql -c "drop table layer_styles;" gis 
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db psql -f /tmp/QGISStyles.sql -d gis
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec db rm /tmp/QGISStyles.sql
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db psql -c "select stylename from layer_styles;" gis 


backup-db-qgis-project:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Backing up QGIS project stored in db"
	@echo "------------------------------------------------------------------"
	-@mkdir -p backups
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db pg_dump -f /tmp/QGISProject.sql -t public.qgis_projects gis
	@docker cp osgisstack_db_1:/tmp/QGISProject.sql backups
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db rm /tmp/QGISProject.sql
	@cp backups/QGISProject.sql backups/QGISProject-$$(date +%Y-%m-%d).sql
	@ls -lah backups/*.sql

restore-db-qgis-project:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restoring QGIS project to db"
	@echo "------------------------------------------------------------------"
	@docker cp backups/QGISProject.sql osgisstack_db_1:/tmp/ 
	# - at start of next line means error will be ignored (in case QGIS project table isnt already there)
	-@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db psql -c "drop table qgis_projects;" gis 
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db psql -f /tmp/QGISProject.sql -d gis
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec db rm /tmp/QGISProject.sql
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db psql -c "select name from qgis_projects;" gis 

backup-db: ## Backup the gis database
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Backing up entire GIS postgres db"
	@echo "------------------------------------------------------------------"
	-@mkdir -p backups
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db pg_dump -Fc -f /tmp/osgisstack-gis-database.dmp gis
	@docker cp osgisstack_db_1:/tmp/osgisstack-gis-database.dmp backups
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db rm /tmp/osgisstack-gis-database.dmp
	@cp backups/osgisstack-gis-database.dmp backups/osgisstack-gis-database-$$(date +%Y-%m-%d).dmp
	@ls -lah backups/osgisstack-gis-database*

list-database-sizes: ## Show the disk space used by each database
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Listing the sizes of all postgres databases"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db bash -c "psql -c '\l+' > /tmp/listing.txt; cat /tmp/listing.txt | sed 's/--//g'" | sed 's/ //g' | awk 'BEGIN { FS = "|" } {print $$1 ":" $$7}' | tail -n +4 | head -n -5

backup-all-databases: ## Backup all postgresql databases
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Backing up all postgres databases"
	@echo "------------------------------------------------------------------"
	-@mkdir -p backups
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db pg_dumpall -f /tmp/osgisstack-all-databases.dmp
	@docker cp osgisstack_db_1:/tmp/osgisstack-all-databases.dmp .
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db rm /tmp/osgisstack-all-databases.dmp
	@cp backups/osgisstack-all-databases.dmp backups/osgisstack-all-databases-$$(date +%Y-%m-%d).dmp
	@ls -lah backups/osgisstack-all-databases*

restore-db: ## Restore the gis database from a back up
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restoring the entire GIS postgres db from a backup"
	@echo "------------------------------------------------------------------"
	@echo "This will irrevocably delete any pre-existing data in your database."
	@echo -n "Are you sure you want to continue? [y/N] " && read ans && [ $${ans:-N} = y ]
	@docker cp backups/osgisstack-gis-database.dmp osgisstack_db_1:/tmp/
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db psql -c "DROP DATABASE IF EXISTS gis WITH (FORCE);"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db pg_restore -C -d postgres /tmp/osgisstack-gis-database.dmp

backup-mergin-base-db-schema:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Backing up mergin base schema from  postgres db"
	@echo "------------------------------------------------------------------"
	-@mkdir -p backups
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db pg_dump -Fc -f /tmp/mergin-base-schema.dmp -n mergin_sync_base_do_not_touch gis
	@docker cp osgisstack_db_1:/tmp/mergin-base-schema.dmp backups
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db rm /tmp/mergin-base-schema.dmp
	@cp backups/mergin-base-schema.dmp backups/mergin-base-schema-$$(date +%Y-%m-%d).dmp
	@ls -lah backups/*.dmp


#----------------- Jupyter --------------------------

deploy-jupyter: build-jupyter enable-jupyter configure-jupyter start-jupyter jupyter-token

# You need to ensure the build happens before running since we 
# dont use a published docker repo
build-jupyter:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Building Jupyter"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose build jupyter

enable-jupyter:
	@make check-env
	-@cd conf/nginx_conf/locations; ln -s jupyter.conf.available jupyter.conf
	@echo "jupyter" >> enabled-profiles

configure-jupyter:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Configuring Jupyter"
	@echo "------------------------------------------------------------------"

start-jupyter:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting Jupyter"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d 
	make jupyter-token

stop-jupyter:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Stopping Jupyter"
	@echo "------------------------------------------------------------------"
	-@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill jupyter
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm jupyter

disable-jupyter:
	@make check-env
	# Remove symlinks
	@cd conf/nginx_conf/locations; rm jupyter.conf
	# Remove from enabled-profiles
	@sed -i '/jupyter/d' enabled-profiles

jupyter-token:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Getting Jupyter token"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec jupyter bash -c "jupyter notebook list" | grep -E -i -o '=[0-9a-f]*' | sed 's/=//'

jupyter-logs:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Polling jupyter logs"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f jupyter

jupyter-shell: ## Create a bash shell in the jupyter container
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating jupyter bash shell"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec jupyter bash

jupyter-root-shell: ## Create a root bash shell in the jupyter container
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating jupyter bash shell"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u root jupyter bash


restart-jupyter:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restarting jupyter"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill jupyter
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm jupyter
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d jupyter
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f jupyter

backup-jupyter:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Backing up jupyter data to ./backups"
	@echo "------------------------------------------------------------------"
	-@mkdir -p backups
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose run --entrypoint /bin/bash --rm -w / -v $${PWD}/backups:/backups jupyter -c "/bin/tar cvfz /backups/jupyter-backup.tar.gz /home"
	@cp backups/jupyter-backup.tar.gz backups/jupyter-backup-$$(date +%Y-%m-%d).tar.gz
	@ls -lah backups/jupyter*.tar.gz

restore-jupyter:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restore last backup of jupyter from /backups/jupyter-backup.tar.gz"
	@echo "If you wish to restore an older backup, first copy it to /backups/jupyter-backup.tar.gz"
	@echo "Note: Restoring will OVERWRITE all data currently in your jupyter home dir."
	@echo "------------------------------------------------------------------"
	@echo -n "Are you sure you want to continue? [y/N] " && read ans && [ $${ans:-N} = y ]
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose run --entrypoint /bin/bash --rm -w / jupyter -c "rm -rf /home/*"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose run --entrypoint /bin/bash --rm -w / -v ${PWD}/backups:/backups jupyter -c "cd /home && tar xvfz /backups/jupyter-backup.tar.gz --strip 1"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose restart jupyter

#----------------- survey solutions --------------------------

deploy-surveysolutions: enable-surveysolutions configure-surveysolutions start-surveysolutions

enable-surveysolutions:
	@make check-env
	-@cd conf/nginx_conf/locations; ln -s surveysolutions.conf.available surveysolutions.conf
	@echo "surveysolutions" >> enabled-profiles

configure-surveysolutions:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Configuring SurveySolutions"
	@echo "------------------------------------------------------------------"
	@echo "Please edit .env and set the database password in the XXXXXX area"
	@echo "of the HQ_URL string" 

start-surveysolutions:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting SurveySolutions"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d 

stop-surveysolutions:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Stopping SurveySolutions"
	@echo "------------------------------------------------------------------"
	-@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill surveysolutions
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm surveysolutions

disable-surveysolutions:
	@make check-env
	# Remove symlinks
	@cd conf/nginx_conf/locations; rm surveysolutions.conf
	# Remove from enabled-profiles
	@sed -i '/surveysolutions/d' enabled-profiles

surveysolutions-logs:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Polling surveysolutions logs"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f surveysolutions

surveysolutions-shell: ## Create a bash shell in the surveysolutions container
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating surveysolutions bash shell"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec surveysolutions bash

surveysolutions-root-shell: ## Create a root bash shell in the surveysolutions container
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating surveysolutions bash shell"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u root surveysolutions bash


restart-surveysolutions:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restarting surveysolutions"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill surveysolutions
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm surveysolutions
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d surveysolutions
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f surveysolutions

backup-surveysolutions:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Backing up surveysolutions data to ./backups"
	@echo "------------------------------------------------------------------"
	-@mkdir -p backups
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose run --entrypoint /bin/bash --rm -w / -v $${PWD}/backups:/backups surveysolutions -c "/bin/tar cvfz /backups/surveysolutions-backup.tar.gz /home"
	@cp backups/surveysolutions-backup.tar.gz backups/surveysolutions-backup-$$(date +%Y-%m-%d).tar.gz
	@ls -lah backups/surveysolutions*.tar.gz

restore-surveysolutions:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restore last backup of surveysolutions from /backups/surveysolutions-backup.tar.gz"
	@echo "If you wish to restore an older backup, first copy it to /backups/surveysolutions-backup.tar.gz"
	@echo "Note: Restoring will OVERWRITE all data currently in your surveysolutions home dir."
	@echo "------------------------------------------------------------------"
	@echo -n "Are you sure you want to continue? [y/N] " && read ans && [ $${ans:-N} = y ]
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose run --entrypoint /bin/bash --rm -w / surveysolutions -c "rm -rf /home/*"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose run --entrypoint /bin/bash --rm -w / -v ${PWD}/backups:/backups surveysolutions -c "cd /home && tar xvfz /backups/surveysolutions-backup.tar.gz --strip 1"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose restart surveysolutions



#----------------- OSM Mirror --------------------------

deploy-osm-mirror: enable-osm-mirror configure-osm-mirror start-osm-mirror add-db-osm-mirror-qgis-project

enable-osm-mirror:
	@make check-env
	@echo "osm" >> enabled-profiles

configure-osm-mirror:
	@echo "=========================:"
	@echo "OSM Mirror specific updates:"
	@echo "=========================:"
	@echo "I have prepared my clip area (optional) and"
	@echo "saved it as conf/osm_conf/clip.geojson."
	@echo "You can easily create such a clip document"
	@echo "at https://geojson.io or by using QGIS"
	@read -p "Press enter to continue" CONFIRM;
	@make get-pbf

get-pbf:  ## helper to download an osm country pbf file
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Fetching pbf if not cached and then copying to settings dir"
	@echo "You can download PBF files from GeoFabrik here:"
	@echo "https://download.geofabrik.de/"
	@echo "e.g. https://download.geofabrik.de/europe/portugal-latest.osm.pbf"
	@echo "------------------------------------------------------------------"
	-@rm conf/osm_conf/country.pbf 
	@read -p "URL For Country PBF File: " URL; \
	   wget -c -N -O conf/osm_conf/country.pbf $$URL;

get-pbf-lint: ## get the pbflint application which can be used to verify your country.pbf files.
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Fetching pbflint to validate PBF file"
	@echo "------------------------------------------------------------------"
	@wget -O pbflint https://github.com/missinglink/pbflint/blob/master/build/pbflint.linux.bin?raw=true
	@chmod +x pbflint


start-osm-mirror:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting OSM Mirror"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d 


add-db-osm-mirror-qgis-project:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Add the OSM Mirror QGIS project to db"
	@echo "------------------------------------------------------------------"
	@docker cp qgis_projects/osm_mirror_qgis_project/osm_mirror_qgis_project.sql osgisstack_db_1:/tmp/ 
	# - at start of next line means error will be ignored (in case QGIS project table isnt already there)
	-@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db psql -c "drop table qgis_projects;" gis 
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db psql -f /tmp/osm_mirror_qgis_project.sql -d gis
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec db rm /tmp/osm_mirror_qgis_project.sql
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db psql -c "select name from qgis_projects;" gis 


stop-osm-mirror:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Deleting all imported OSM data and killing containers"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill imposm
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill osmupdate
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill osmenrich
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm imposm
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm osmupdate
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm osmenrich
	# Next commands have - in front as they as non compulsory to succeed
	-@sudo rm conf/osm_conf/timestamp.txt
	-@sudo rm conf/osm_conf/last.state.txt
	-@sudo rm conf/osm_conf/importer.lock
	-@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db psql -c "drop schema osm cascade;" gis 
	-@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db psql -c "drop schema osm_backup cascade;" gis 
	-@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db psql -c "drop schema osm_import cascade;" gis 

disable-osm-mirror:
	@make check-env
	# Remove from enabled-profiles
	@sed -i '/osm/d' enabled-profiles

reinitialise-osm-mirror: stop-osm-mirror
	@make check-env
	@echo-----------------------------------------------------------"
	@echo "Deleting
	@echo "------- all imported OSM data and reloading"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d imposm osmupdate osmenrich 
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f imposm osmupdate osmenrich

osm-to-mbtiles:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating a vector tiles store from the docker osm schema"
	@echo "------------------------------------------------------------------"
        #@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose run osm-to-mbtiles
	@echo "we use below for now because the container aproach doesnt have a new enough gdal (2.x vs >=3.1 needed)"
	@ogr2ogr -f MBTILES osm.mbtiles PG:"dbname='gis' host='localhost' port='15432' user='docker' password='docker' SCHEMAS=osm" -dsco "MAXZOOM=10 BOUNDS=-7.389126,39.410085,-7.381439,39.415144"

osm-mirror-logs:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Polling OSM Mirror logs"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f imposm osmupdate

# The OSM mirror profile: osm, runs two services: imposm and osmupdate so the # shells will be separate for each service, 

osm-mirror-osmupdate-shell:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating OSM Mirror osmupdate shell"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec osmupdate bash 

osm-mirror-imposm-shell:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating OSM Mirror imposm shell"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec imposm bash 


#----------------- Postgrest --------------------------

deploy-postgrest:  enable-postgrest configure-postgrest start-postgrest

enable-postgrest:
	-@cd conf/nginx_conf/locations; ln -s postgrest.conf.available postgrest.conf
	-@cd conf/nginx_conf/locations; ln -s swagger.conf.available swagger.conf
	-@cd conf/nginx_conf/upstreams; ln -s postgrest.conf.available postgrest.conf
	-@cd conf/nginx_conf/upstreams; ln -s swagger.conf.available swagger.conf
	@echo "postgrest" >> enabled-profiles

configure-postgrest: start-postgrest
	@echo "========================="
	@echo "PostgREST specific updates"
	@echo "========================="
	@export PASSWD=$$(pwgen 20 1); \
		rpl PGRST_JWT_SECRET=foobarxxxyyyzzz PGRST_JWT_SECRET=$$PASSWD .env; \
		echo "PostGREST JWT token set to $$PASSWD"

start-postgrest:
	@make check-env
	@echo "------------------------------------------------------------------"
	@echo "Starting PostgREST"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d postgrest
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d swagger

stop-postgrest:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Stopping PostgREST"
	@echo "------------------------------------------------------------------"
	-@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill postgrest
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm postgrest
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill swagger
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm swagger

disable-postgrest:
	# Remove from enabled-profiles
	@sed -i '/postgrest/d' enabled-profiles
	# Remove symlinks
	@cd conf/nginx_conf/locations; rm postgrest.conf
	@cd conf/nginx_conf/locations; rm swagger.conf
	@cd conf/nginx_conf/upstreams; rm postgrest.conf
	@cd conf/nginx_conf/upstreams; rm swagger.conf

postgrest-logs:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Polling PostgREST logs"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f postgrest swagger

# not working at the moment 
postgrest-shell:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating PostgREST shell"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec postgrest bash

restore-postgrest-sql:
	@echo "See https://www.compose.com/articles/authenticating-node-red-with-jsonwebtoken/"
	@echo "For notes on how to use the JWT we are about to set up"
	@docker cp setup.sql osgisstack_db_1:/tmp/ 
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db psql -f /tmp/setup.sql -d gis
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec db rm /tmp/setup.sql
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db psql -c "select * from api.monitoring;" gis 

#----------------- NodeRed --------------------------
# The node red location will be locked with the htpasswd

deploy-node-red: enable-node-red configure-node-red configure-htpasswd start-node-red restart

enable-node-red:
	-@cd conf/nginx_conf/locations; ln -s node-red.conf.available node-red.conf
	#-@cd conf/nginx_conf/upstreams; ln -s node-red.conf.available node-red.conf
	@echo "node-red" >> enabled-profiles

configure-node-red:
	@echo "========================="
	@echo "Node Red configured"
	@echo "========================="
	@make configure-timezone

restart-node-red: stop-node-red start-node-red

start-node-red:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting Node-Red"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d
	
stop-node-red:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Stopping Node-Red"
	@echo "------------------------------------------------------------------"
	-@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill node-red
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm node-red

disable-node-red:
	@make check-env
	@cd conf/nginx_conf/locations; rm node-red.conf
	#@cd conf/nginx_conf/upstreams; rm nore-red.conf
	# Remove from enabled-profiles
	@sed -i '/node-red/d' enabled-profiles
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose restart nginx

deploy-node-red-patch:
	# This is needed because the node package does not
	# work with SSL connections
	@echo "Deploying Tim's fork of postgres-multi since upstream is broken"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -w /data node-red npm install git+https://github.com/kartoza/node-red-contrib-postgres-multi.git
	# Hacky thing here because ssl require is broken in node pg for self signed certs
	# need to make an upstream fix then remove this next line
	@docker cp patches/node-red/connection-parameters.js osgisstack_node-red_1:/data/node_modules/pg/lib/connection-parameters.js
	# Now restart nginx
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose restart nginx

node-red-logs:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Logging node red"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f node-red

node-red-shell:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating node red shell"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -w /data node-red bash

backup-node-red:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Backing up node/red data to ./backups"
	@echo "------------------------------------------------------------------"
	-@mkdir -p backups
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose run --entrypoint /bin/bash --rm -w / -v ${PWD}/backups:/backups node-red -c "/bin/tar cvfz /backups/node-red-backup.tar.gz /data"
	@cp backups/node-red-backup.tar.gz backups/node-red-backup-$$(date +%Y-%m-%d).tar.gz
	@ls -lah backups/*.tar.gz

restore-node-red:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restore last backup of node-red from /backups/node-red-backup.tar.gz"
	@echo "If you wist to restore an older backup, first copy it to /backups/node-red-backup.tar.gz"
	@echo "Note: Restoring will OVERWRITE all data currently in your node-red content dir."
	@echo "------------------------------------------------------------------"
	@echo -n "Are you sure you want to continue? [y/N] " && read ans && [ $${ans:-N} = y ]
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose run --entrypoint /bin/bash --rm -w / node-red -c "rm -rf /data/*"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose run --entrypoint /bin/bash --rm -w / -v ${PWD}/backups:/backups node-red -c "cd /data && tar xvfz /backups/node-red-backup.tar.gz --strip 1"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose restart nginx

#----------------- Mosquitto MQTT Broker --------------------------

deploy-mosquitto: enable-mosquitto configure-mosquitto start-mosquitto 

enable-mosquitto:
	@echo "mosquitto" >> enabled-profiles

configure-mosquitto:
	@echo "========================="
	@echo "Configuring Mosquitto"
	@echo "========================="
	@if [ -f "conf/mosquitto/start-mosquitto.sh" ]; then sudo rm conf/mosquitto/start-mosquitto.sh; fi
	@cp conf/mosquitto/start-mosquitto.sh.example conf/mosquitto/start-mosquitto.sh
	@rpl -q {{siteDomain}} $(shell cat conf/nginx_conf/servername.conf | sed 's/         server_name //' | sed 's/;//') conf/mosquitto/start-mosquitto.sh
	@chmod +x conf/mosquitto/start-mosquitto.sh
	@if [ ! -f "conf/mosquitto/mosquitto.conf" ]; then cp conf/mosquitto/mosquitto.conf.example conf/mosquitto/mosquitto.conf; fi

restart-mosquitto: stop-mosquitto start-mosquitto

start-mosquitto:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting Mosquitto"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d mosquitto
	
stop-mosquitto:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Stopping Mosquitto"
	@echo "------------------------------------------------------------------"
	-@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill mosquitto
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm mosquitto

disable-mosquitto:
	@make check-env
	# Remove from enabled-profiles
	@sed -i '/mosquitto/d' enabled-profiles

mosquitto-logs:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Logging mosquitto"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f mosquitto

mosquitto-shell:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating node mosquito shell"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec mosquitto bash

backup-mosquitto:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Backing up mosquitto data to ./backups"
	@echo "------------------------------------------------------------------"
	-@mkdir -p backups
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose run --entrypoint /bin/sh --rm -w / -v ${PWD}/backups:/backups mosquitto -c "/bin/tar cvfz /backups/mosquitto-backup.tar.gz /mosquitto/data"
	@cp backups/mosquitto-backup.tar.gz backups/mosquitto-backup-$$(date +%Y-%m-%d).tar.gz
	@ls backups/mosquitto-backup*

restore-mosquitto:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restore last backup of mosquitto from /backups/mosquitto-backup.tar.gz"
	@echo "If you wist to restore an older backup, first copy it to /backups/mosquitto-backup.tar.gz"
	@echo "Note: Restoring will OVERWRITE all data currently in your mosquitto content dir."
	@echo "------------------------------------------------------------------"
	@echo -n "Are you sure you want to continue? [y/N] " && read ans && [ $${ans:-N} = y ]
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose run --entrypoint /bin/sh --rm -w / mosquitto -c "rm -rf /mosquitto/data/*"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose run --entrypoint /bin/sh --rm -w / -v ${PWD}/backups:/backups mosquitto -c "cd /mosquitto/data && tar xvfz /backups/mosquitto-backup.tar.gz --strip 1"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose restart mosquitto

#----------------- File Browser --------------------------
# See https://filebrowser.org/
#

deploy-file-browser: enable-file-browser configure-file-browser 

enable-file-browser:
	@echo "file-browser" >> enabled-profiles

configure-file-browser:
	# We need to quickly start it to initialise
	# Then stop so that we can write more options to the db
	@make start-file-browser 
	@make stop-file-browser 
	@echo "========================="
	@echo "File browser configured"
	@echo "========================="
	@make copy-overrides
	-@cd conf/nginx_conf/locations; ln -s file-browser.conf.available file-browser.conf
	# This section must run before file-browser is running to avoid an issue in 
	# file-browser that prevents another app from updating it while it is being used
	@echo "------------------------------------------------------------------"
	@echo "Setting up password and branding for file-browser"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose run file-browser config set --branding.name "OSGS File Browser" --branding.files "/conf/branding"
	@make start-file-browser 
	@make stop-nginx
	@make start-nginx

restart-file-browser: stop-file-browser start-file-browser

start-file-browser:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting file browser"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d file-browser
	@make stop-nginx
	@make start-nginx
	
stop-file-browser:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Stopping file browser"
	@echo "------------------------------------------------------------------"
	-@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill file-browser
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm file-browser

disable-file-browser:
	@make check-env
	# Remove from enabled-profiles
	@sed -i '/file-browser/d' enabled-profiles

file-browser-logs:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Logging file-browser"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f file-browser

file-browser-shell:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating file browser shell"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec file-browser sh

create-file-browser-user:
	@echo "------------------------------------------------------------------"
	@echo "Creating a new file browser user"
	@echo "------------------------------------------------------------------"
	@export PASSWD=$$(pwgen 20 1); \
		echo "Browser user set to $$PASSWD"; \
		sed -i "s/# SIMPLE-FILE-UPLOAD-USERS/# SIMPLE-FILE-UPLOAD-USERS\n      - KEY_$$PASSWD=\/browser\/SomeFile.zip/g" docker-compose.override.yml

#----------------- Mergin Server --------------------------

deploy-mergin-server:  enable-mergin-server configure-mergin-server start-mergin-server

enable-mergin-server:
	-@cd conf/nginx_conf/locations; ln -s mergin-server.conf.available mergin-server.conf
	@echo "mergin-server" >> enabled-profiles
	#
# Used to see if we have already set a password...
MERGINSERVERUSERCONFIGURED = $(shell cat .env | grep -o 'MERGIN_SERVER_ADMIN')
MERGINSERVERPASSWDCONFIGURED = $(shell cat .env | grep 'MERGIN_SERVER_PASSWORD')
CONTACTEMAILCONFIGURED = $(shell cat .env | grep '^CONTACT_EMAIL' | sed 's/CONTACT_EMAIL=//')

configure-mergin-server: start-mergin-server
	@echo "========================="
	@echo "Configuring mergin-server"
	@echo "========================="
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d mergin-server
ifeq ($(MERGINSERVERUSERCONFIGURED),MERGIN_SERVER_ADMIN)
	@echo "Mergin admin user password is already configured. Please see .env"
	@echo "Current password for admin user is:"
	@echo $(MERGINPASSWDCONFIGURED)
else
	@export PASSWD=$$(pwgen 60 1); \
		rpl REPLACE_MERGIN_SERVER_SECRET_KEY $$PASSWD .env; 
	@export PASSWD=$$(pwgen 60 1); \
		rpl REPLACE_MERGIN_SERVER_SECURITY_PASSWORD_SALT $$PASSWD .env; 
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec mergin-server flask init-db
	@echo "MERGIN_SERVER_ADMIN=admin" >> .env
	@export PASSWD=$$(pwgen 20 1); \
		echo "MERGIN_SERVER_PASSWORD=$$PASSWD" >> .env; \
		echo "Mergin server credentials set to user: admin password: $$PASSWD"; \
		COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec mergin-server bash -c "flask add-user admin $$PASSWD --is-admin --email $(CONTACTEMAILCONFIGURED)"; \
		COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u root mergin-server bash -c "chown -R  901:999 /data"; \
		COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u root mergin-server bash -c "chmod g+s /data";
	make stop-mergin-server
endif

start-mergin-server:
	@make check-env
	@echo "------------------------------------------------------------------"
	@echo "Starting Mergin Server"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d mergin-server

stop-mergin-server:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Stopping Mergin Server"
	@echo "------------------------------------------------------------------"
	-@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill mergin-server
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm mergin-server

disable-mergin-server:
	# Remove from enabled-profiles
	@sed -i '/mergin-server/d' enabled-profiles
	# Remove symlinks
	@cd conf/nginx_conf/locations; rm mergin-server.conf

mergin-server-logs: ## Show the logs for mergin-server
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Polling Mergin Server logs"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f mergin-server

# not working at the moment 
mergin-server-shell:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating Mergin Server shell"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec mergin-server bash


#----------------- Redis --------------------------

redis-logs: ## Show the logs for the redis service
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Polling Redis Service logs"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f redis


#----------------- LizMap --------------------------

# LIZMAP IS NOT WORKING YET.....


deploy-lizmap: enable-lizmap configure-lizmap  start-lizmap

enable-lizmap:
	@make check-env
	-@cd conf/nginx_conf/locations; ln -s lizmap.conf.available lizmap.conf
	@echo "lizmap" >> enabled-profiles

configure-lizmap:
	@make check-env
	@echo "=========================:"
	@echo "Configuring lizmap:"
	@echo "=========================:"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d 
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose restart nginx

start-lizmap:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting Lizmap"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d lizmap

stop-lizmap:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Stopping Lizmap"
	@echo "------------------------------------------------------------------"
	-@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill lizmap
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm lizmap

disable-lizmap:
	@cd conf/nginx_conf/locations; rm lizmap.conf
	# Remove from enabled-profiles
	@sed -i '/lizmap/d' enabled-profiles

lizmap-logs:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Polling Lizmap logs"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f lizmap

lizmap-shell:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating Lizmap shell"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec lizmap sh


#----------------- Mergin Client ------------------

configure-mergin-client:
	@make check-env
	@echo "=========================:"
	@echo "Mergin related configs:"
	@echo "=========================:"
	@read -p "Mergin User (not email address): " USER; \
	   rpl mergin_username $$USER .env
	@read -p "Mergin Password: " PASSWORD; \
	   rpl mergin_password $$PASSWORD .env
	@read -p "Mergin Project (without username part): " PROJECT; \
	   rpl mergin_project $$PROJECT .env
	@read -p "Mergin Project GeoPackage: " PACKAGE; \
	   rpl mergin_project_geopackage.gpkg $$PACKAGE .env
	@read -p "Mergin Database Schema to hold mirror of geopackage): " SCHEMA; \
	   rpl schematoreceivemergindata $$SCHEMA .env

reinitialise-mergin-client:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Deleting mergin database schemas and removing local sync files"
	@echo "Then restarting the mergin sync service"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill mergin-sync
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm mergin-sync
	@sudo rm -rf mergin_sync_data/*
	# Next line allowed to fail
	-@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db psql -c "drop schema qgis_demo cascade;" gis 
	# Next line allowed to fail
	-@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db psql -c "drop schema mergin_sync_base_do_not_touch cascade;" gis 	
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d mergin-sync
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f mergin-sync

redeploy-mergin-client:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Stopping merging container, rebuilding the image, then restarting mergin db sync"
	@echo "------------------------------------------------------------------"
	-@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill mergin-sync
	-@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm mergin-sync
	-@docker rmi mergin_db_sync
	@git clone git@github.com:lutraconsulting/mergin-db-sync.git --depth=1
	@cd mergin-db-sync; docker build --no-cache -t mergin_db_sync .; cd ..
	@rm -rf mergin-db-sync
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d mergin-sync
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f mergin-sync


#----------------- Mergin DB Sync ----------------------

start-mergin-dbsync:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting mergin-db-sync service"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d mergin-sync
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f mergin-sync

stop-mergin-dbsync:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Stopping mergin-db-sync service"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill mergin-sync
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm mergin-sync


mergin-dbsync-logs:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Polling mergin-db-sync logs"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f mergin-sync

mergin-dbsync-shell:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Shelling into mergin db sync"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose run mergin-sync bash

#----------------- ODM ----------------------

odm-clean:
	@make check-env
	@echo "------------------------------------------------------------------"
	@echo "Note that the odm_datasets directory should be considered mutable as this script "
	@echo "cleans out all other files"
	@echo "------------------------------------------------------------------"
	@sudo rm -rf odm_datasets/osgisstack/odm*
	@sudo rm -rf odm_datasets/osgisstack/cameras.json
	@sudo rm -rf odm_datasets/osgisstack/img_list.txt
	@sudo rm -rf odm_datasets/osgisstack/cameras.json
	@sudo rm -rf odm_datasets/osgisstack/opensfm
	@sudo rm -rf odm_datasets/osgisstack/images.json

odm-run: odm-clean
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Generating ODM Ortho, DEM, DSM then clipping it and loading it into postgis"
	@echo "Before running please remove any old images from odm_datasets/osgisstack/images"
	@echo "and copy the images that need to be mosaicked into it."
	@echo "Note that the odm_datasets directory should be considered mutable as this script "
	@echo "cleans out all other files"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose run odm

odm-clip:
	@make check-env
	@echo "------------------------------------------------------------------"
	@echo "Clippint Ortho, DEM, DSM"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose run odm-ortho-clip
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose run odm-dsm-clip
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose run odm-dtm-clip

# This is how you pass an env var to 
odm-pgraster: export PGPASSWORD = docker
# a makefile target
odm-pgraster:
	@make check-env
	@echo "------------------------------------------------------------------"
	@echo "Loading ODM products into postgis"
	@echo "------------------------------------------------------------------"
	# Todo - run in docker rather than localhost, currently requires pgraster installed locally
	-@echo "drop schema raster cascade;" | psql -h localhost -p 15432 -U docker gis
	@echo "create schema raster;" | psql -h localhost -p 15432 -U docker gis
	@raster2pgsql -s 32629 -t 256x256 -C -l 4,8,16,32,64,128,256,512 -P -F -I ./odm_datasets/orthophoto.tif raster.orthophoto | psql -h localhost -p 15432 -U docker gis
	@raster2pgsql -s 32629 -t 256x256 -C -l 4,8,16,32,64,128,256,512 -d -P -F -I ./odm_datasets/dtm.tif raster.dtm | psql -h localhost -p 15432 -U docker gis
	@raster2pgsql -s 32629 -t 256x256 -C -l 4,8,16,32,64,128,256,512 -d -P -F -I ./odm_datasets/dsm.tif raster.dsm | psql -h localhost -p 15432 -U docker gis

# Runs above 3 tasks all in one go
odm: odm-run odm-clip odm-pgraster


#----------------- Docs --------------------------

enable-docs:
	-@cd conf/nginx_conf/locations; ln -s docs.conf.available docs.conf

disable-docs:
	@cd conf/nginx_conf/locations; rm docs.conf

enable-downloads:
	@if [ ! -f "conf/nginx_conf/locations/files.conf" ]; then \
		cd conf/nginx_conf/locations; \
		ln -s files.conf.available files.conf; \
	       	exit 0; \
	fi

disable-files:
	@cd conf/nginx_conf/locations; rm files.conf


#######################################################
#   General Utilities
#######################################################

check-env: 
	@echo "Checking env"
	@if [ ! -f ".env" ]; then \
		echo "--------------------------------------------------"; \
	       	echo ""; echo ""; echo ".env does not exist yet."; echo ""; \
		echo "Please run either make configure-ssl-self-signed or make configure-letsencrypt-ssl to set up your stack!"; echo ""; \
		echo "--------------------------------------------------"; \
	       	exit 1; \
	fi

site-reset:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Reset site configuration to default values"
	@echo "This will replace any local configuration changes you have made"
	@echo "------------------------------------------------------------------"
	@echo -n "Are you sure you want to continue? [y/N] " && read ans && [ $${ans:-N} = y ]
	@cp ./conf/hugo_conf/config.yaml.example ./conf/hugo_conf/config.yaml

init-letsencrypt:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Getting an SSL cert from letsencypt"
	@echo "------------------------------------------------------------------"
	@./init-letsencrypt.sh	
	@docker-compose --profile=certbot-init kill
	@docker-compose --profile=certbot-init rm

get-fonts: ## Download a whole bunch of free fonts so you can use them in your cartography
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Getting Google apache license and gnu free fonts"
	@echo "and placing them into the qgis_fonts volume" 
	@echo "------------------------------------------------------------------"
	-@mkdir fonts
	@cd fonts;wget  https://github.com/google/fonts/archive/refs/heads/main.zip
	@cd fonts;unzip main.zip; rm main.zip
	@cd fonts;wget http://ftp.gnu.org/gnu/freefont/freefont-ttf-20120503.zip
	@cd fonts;unzip freefont-ttf-20120503.zip; rm freefont-ttf-20120503.zip
	@cd fonts;find . -name "*.ttf" -exec mv -t . {} +
	@docker cp fonts osgisstack_scp_1:/home/qgis_fonts/

vrt-styles:
	@echo "------------------------------------------------------------------"
	@echo "Checking out Vector Tiles QMLs to qgis-vector-tiles folder"
	@echo "------------------------------------------------------------------"
	@git clone git@github.com:lutraconsulting/qgis-vectortiles-styles.git

up:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting all configured services"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d
	make stop-qgis-server
	make start-qgis-server

kill:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Killing all containers"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill

rm: kill
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Removing all containers"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm

restart:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restarting all containers"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose restart
	# Need to flush this completely for it to work on restart
	make stop-qgis-desktop
	make start-qgis-desktop
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f

pull:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Stopping, removing, updating and restarting all containers"
	@echo "------------------------------------------------------------------"
	@echo -n "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose pull
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d

nuke:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Disabling services"
	@echo "This command will delete all your configuration and data permanently."
	@echo -n "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	@echo -n "Please type CONFIRM to proceed " && read ans && [ $${ans:-N} = CONFIRM ]
	@echo "------------------------------------------------------------------"
	@echo "Nuking Everything!"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm -v -f -s
	@rm enabled-profiles
	@make site-reset
	@make disable-all-services
	@echo -n "Deleting volumes will remove all previous application state!!"
	@echo -n "Please type DELETE to proceed " && read ans && [ $${ans:-N} = DELETE ]
	-@docker volume rm $(shell docker volume ls | grep osgisstack | awk '{print $2}')
	@rm .env
	@sudo rm -rf certbot/certbot
	
logs:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Tailing logs"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f
