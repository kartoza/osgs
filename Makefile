SHELL := /bin/bash


help:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Please visit https://kartoza.github.io/osgs/introduction.html"
	@echo "for detailed help."
	@echo "------------------------------------------------------------------"


# We need to declare phony here since the docs dir exists
# otherwise make tries to execute the docs file directly
.PHONY: docs
docs:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Making sphinx docs"
	@echo "------------------------------------------------------------------"
	$(MAKE) -C sphinx html
	@cp -r  sphinx/build/html/* docs
	$(MAKE) -C sphinx latexpdf
	@cp sphinx/build/latex/osgs.pdf osgs-manual.pdf


ps: 
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Current status"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose ps


deploy: configure
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting basic nginx site"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f

configure: disable-all-services prepare-templates site-config enable-hugo configure-scp configure-htpasswd deploy

disable-all-services:
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

prepare-templates: 
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
	@make configure-ssl-self-signed
	@cp conf/nginx_conf/ssl/certificates.conf.selfsigned.example conf/nginx_conf/ssl/ssl.conf
	@echo "Afterwards if you want to put the server into production mode"
	@echo "please run:"
	@echo "make configure-letsencrypt-ssl"

configure-ssl-self-signed:
	@mkdir -p ./certbot/certbot/conf/
	@openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./certbot/certbot/conf/nginx-selfsigned.key -out ./certbot/certbot/conf/nginx-selfsigned.crt
	#@rpl "BEGIN CERTIFICATE" "BEGIN TRUSTED CERTIFICATE" ./certbot/certbot/conf/nginx-selfsigned.crt
	#@rpl "END CERTIFICATE" "END  TRUSTED CERTIFICATE" ./certbot/certbot/conf/nginx-selfsigned.crt
	#@rpl "BEGIN PRIVATE KEY" "TRUSTED CERTIFICATE" ./certbot/certbot/conf/nginx-selfsigned.key
	#@rpl "END PRIVATE KEY" "TRUSTED CERTIFICATE" ./certbot/certbot/conf/nginx-selfsigned.key

configure-letsencrypt-ssl:
	@make check-env
	@echo "Do you want to set up SSL using letsencrypt?"
	@echo "This is recommended for production!"
	@echo -n "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	@rpl example.org $(shell grep DOMAIN .env| sed 's/DOMAIN=//') nginx_certbot_init_conf/nginx.conf init-letsencrypt.sh; 
	@cp nginx_certbot_init_conf/nginx.conf.example nginx_certbot_init_conf/nginx.conf
	@cp init-letsencrypt.sh.example init-letsencrypt.sh
	@cp conf/nginx_conf/ssl/ssl.conf.example conf/nginx_conf/ssl/ssl.conf
	@read -p "Valid Contact Person Email Address: " EMAIL; \
	   rpl validemail@yourdomain.org $$EMAIL init-letsencrypt.sh .env

site-config:
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

configure-htpasswd:
	@make check-env
	@echo "------------------------------------------------------------------"
	@echo "Configuring password controlled file sharing are for your site"
	@echo "Accessible at /files/"
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
	@make enable-files


#----------------- Hugo --------------------------

enable-hugo:
	-@cd conf/nginx_conf/locations; ln -s hugo.conf.available hugo.conf
	@echo "hugo" >> enabled-profiles

start-hugo:
	@make check-env
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d

disable-hugo:
	@cd conf/nginx_conf/locations; rm hugo.conf
	# Remove from enabled-profiles
	@sed -i '/hugo/d' enabled-profiles

hugo-logs:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Polling hugo logs"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f hugo-watcher

backup-hugo:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating a backup of hugo"
	@echo "------------------------------------------------------------------"
	-@mkdir -p backups
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose run --rm -v ${PWD}/backups:/backups nginx tar cvfz /backups/hugo-backup.tar.gz /hugo
	@cp ./backups/hugo-backup.tar.gz ./backups/

restore-hugo:
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

hugo-shell:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating hugo shell"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec hugo-watcher bash

#----------------- SCP --------------------------

configure-scp:
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

start-scp:
	@make check-env
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d scp	

enable-scp:
	@make check-env
	@echo "scp" >> enabled-profiles

disable-scp:
	# Remove from enabled-profiles
	@sed -i '/db/d' enabled-profiles
	

#----------------- Docs --------------------------

enable-docs:
	-@cd conf/nginx_conf/locations; ln -s docs.conf.available docs.conf

disable-docs:
	@cd conf/nginx_conf/locations; rm docs.conf

enable-files:
	@if [ ! -f "conf/nginx_conf/locations/files.conf" ]; then \
		cd conf/nginx_conf/locations; \
		ln -s files.conf.available files.conf; \
	       	exit 0; \
	fi

disable-files:
	@cd conf/nginx_conf/locations; rm files.conf

#----------------- GeoServer --------------------------

deploy-geoserver: enable-geoserver configure-geoserver-passwd start-geoserver

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

configure-geoserver-passwd:
	@make check-env
	@export PASSWD=$$(pwgen 20 1); \
		rpl GEOSERVER_ADMIN_PASSWORD=myawesomegeoserver GEOSERVER_ADMIN_PASSWORD=$$PASSWD .env; \
		echo "GeoServer password set to $$PASSWD"

enable-geoserver:
	@make check-env
	-@cd conf/nginx_conf/locations; ln -s geoserver.conf.available geoserver.conf
	@echo "geoserver" >> enabled-profiles

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

#----------------- QGIS Server --------------------------

deploy-qgis-server: -qgis-server start-qgis-server

start-qgis-server:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting QGIS Server"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d --scale qgis-server=10 --remove-orphans
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose restart nginx

enable-qgis-server:
	@make check-env
	-@cd conf/nginx_conf/locations; ln -s qgis-server.conf.available qgis-server.conf
	-@cd conf/nginx_conf/upstreams; ln -s qgis-server.conf.available qgis-server.conf
	@echo "qgis-server" >> enabled-profiles

disable-qgis-server:
	@make check-env
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill qgis-server
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm qgis-server
	@cd conf/nginx_conf/locations; rm qgis-server.conf
	@cd conf/nginx_conf/upstreams; rm qgis-server.conf
	# Remove from enabled-profiles
	@sed -i '/qgis/d' enabled-profiles

reinitialise-qgis-server:rm-qgis-server start-qgis-server
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restarting QGIS Server and Nginx"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose restart nginx
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f qgis-server 

rm-qgis-server:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Stopping QGIS Server and Nginx"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill qgis-server
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm qgis-server

qgis-logs:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Polling QGIS Server logs"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f qgis-server

#----------------- Mapproxy --------------------------

deploy-mapproxy: enable-mapproxy configure-mapproxy start-mapproxy

start-mapproxy:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting Mapproxy"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose -up -d 
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose restart nginx

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

enable-mapproxy:
	@make check-env
	-@cd conf/nginx_conf/locations; ln -s mapproxy.conf.available mapproxy.conf
	@echo "mapproxy" >> enabled-profiles

disable-mapproxy:
	@make check-env
	@cd conf/nginx_conf/locations; rm mapproxy.conf
	# Remove from enabled-profiles
	@sed -i '/mapproxy/d' enabled-profiles

#----------------- Postgres --------------------------

deploy-postgres:enable-postgres configure-postgres start-postgres

start-postgres:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting Postgres"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d 

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

enable-postgres:
	@make check-env
	@echo "db" >> enabled-profiles

disable-postgres:
	@make check-env
	@echo "This is currently a stub"	
	# Remove from enabled-profiles
	@sed -i '/db/d' enabled-profiles

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

db-shell:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating db shell"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db psql gis

db-qgis-project-backup:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Backing up QGIS project stored in db"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db pg_dump -f /tmp/QGISProject.sql -t qgis_projects gis
	@docker cp osgisstack_db_1:/tmp/QGISProject.sql .
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db rm /tmp/QGISProject.sql
	@ls -lah QGISProject.sql

db-qgis-project-restore:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restoring QGIS project to db"
	@echo "------------------------------------------------------------------"
	@docker cp QGISProject.sql osgisstack_db_1:/tmp/ 
	# - at start of next line means error will be ignored (in case QGIS project table isnt already there)
	-@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db psql -c "drop table qgis_projects;" gis 
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db psql -f /tmp/QGISProject.sql -d gis
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec db rm /tmp/QGISProject.sql
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db psql -c "select name from qgis_projects;" gis 

db-backup:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Backing up entire GIS postgres db"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db pg_dump -Fc -f /tmp/osgisstack-database.dmp gis
	@docker cp osgisstack_db_1:/tmp/osgisstack-database.dmp .
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db rm /tmp/osgisstack-database.dmp
	@ls -lah osgisstack-database.dmp

db-backupall:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Backing up all postgres databases"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db pg_dumpall -f /tmp/osgisstack-all-databases.dmp
	@docker cp osgisstack_db_1:/tmp/osgisstack-all-databases.dmp .
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db rm /tmp/osgisstack-all-databases.dmp
	@ls -lah osgisstack-all-databases.dmp

db-backup-mergin-base-schema:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Backing up mergin base schema from  postgres db"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db pg_dump -Fc -f /tmp/mergin-base-schema.dmp -n mergin_sync_base_do_not_touch gis
	@docker cp osgisstack_db_1:/tmp/mergin-base-schema.dmp .
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -u postgres db rm /tmp/mergin-base-schema.dmp
	@ls -lah mergin-base-schema.dmp



#----------------- OSM Mirror --------------------------

deploy-osm-mirror: enable-osm-mirror configure-osm-mirror start-osm-mirror

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

get-pbf:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Fetching pbf if not cached and then copying to settings dir"
	@echo "You can download PBF files from GeoFabrik here:"
	@echo "https://download.geofabrik.de/"
	@echo "e.g. https://download.geofabrik.de/europe/portugal-latest.osm.pbf"
	@echo "------------------------------------------------------------------"
	@read -p "URL For Country PBF File: " URL; \
	   wget -c -N -O conf/osm_conf/country.pbf $$URL;

start-osm-mirror:
	@make check-env
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d 

enable-osm-mirror:
	@make check-env
	@echo "osm" >> enabled-profiles

disable-osm-mirror:
	@make check-env
	# Remove from enabled-profiles
	@sed -i '/osm/d' enabled-profiles

#----------------- Postgrest --------------------------

deploy-postgrest: configure-postgrest enable-postgrest start-postgrest

configure-postgrest: start-postgrest
	@echo "========================="
	@echo "PostgREST specific updates"
	@echo "========================="
	@export PASSWD=$$(pwgen 20 1); \
		rpl PGRST_JWT_SECRET=foobarxxxyyyzzz PGRST_JWT_SECRET=$$PASSWD .env; \
		echo "PostGREST JWT token set to $$PASSWD"

start-postgrest:
	@make check-env
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d postgrest

enable-postgrest:
	@echo "postgrest" >> enabled-profiles

disable-postgrest:
	# Remove from enabled-profiles
	@sed -i '/postgrest/d' enabled-profiles

#----------------- NodeRed --------------------------
# The node red location will be locked with the htpasswd

deploy-node-red: configure-node-red configure-htpasswd enable-node-red start-node-red

configure-node-red:
	@echo "========================="
	@echo "Node Red configured"
	@echo "========================="
	@make configure-timezone

start-node-red:
	@make check-env
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d
	@echo "Deploying Tim's fork of postgres-multi since upstream is broken"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec -w /data node-red npm install git+https://github.com/kartoza/node-red-contrib-postgres-multi.git
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose restart nginx

enable-node-red:
	-@cd conf/nginx_conf/locations; ln -s node-red.conf.available node-red.conf
	#-@cd conf/nginx_conf/upstreams; ln -s node-red.conf.available node-red.conf
	@echo "node-red" >> enabled-profiles

disable-node-red:
	@make check-env
	@cd conf/nginx_conf/locations; rm node-red.conf
	#@cd conf/nginx_conf/upstreams; rm nore-red.conf
	# Remove from enabled-profiles
	@sed -i '/node-red/d' enabled-profiles
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose restart nginx

stop-node-red:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Stopping Node-Red"
	@echo "------------------------------------------------------------------"
	-@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose kill node-red
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose rm node-red

node-red-shell:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating node red shell"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec node-red bash

node-red-logs:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Logging node red"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f node-red

#----------------- LizMap --------------------------

# LIZMAP IS NOT WORKING YET.....


deploy-lizmap: configure-lizmap enable-lizmap start-lizmap

start-lizmap:
	@make check-env
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d lizmap

configure-lizmap:
	@make check-env
	@echo "=========================:"
	@echo "Configuring lizmap:"
	@echo "=========================:"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up -d 
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose restart nginx

enable-lizmap:
	@make check-env
	-@cd conf/nginx_conf/locations; ln -s lizmap.conf.available lizmap.conf
	@echo "lizmap" >> enabled-profiles


disable-lizmap:
	@make check-env
	@cd conf/nginx_conf/locations; rm lizmap.conf
	# Remove from enabled-profiles
	@sed -i '/lizmap/d' enabled-profiles

#######################################################
#   General Utilities
#######################################################

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

restart:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restarting all containers"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose restart
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f

logs:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Tailing logs"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f

nginx-shell:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating nginx shell"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose exec nginx /bin/sh

nginx-logs:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Tailing logs of nginx"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f nginx


kill-osm:
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

reinitialise-osm: kill-osm
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Deleting all imported OSM data and reloading"
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


mergin-dbsycn-start:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting mergin-db-sync service"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose up mergin-sync
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f mergin-sync

mergin-dbsync-logs:
	@make check-env
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Polling mergin-db-sync logs"
	@echo "------------------------------------------------------------------"
	@COMPOSE_PROFILES=$(shell paste -sd, enabled-profiles) docker-compose logs -f mergin-sync

get-fonts:
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
	
check-env: 
	@echo "Checking env"
	@if [ ! -f ".env" ]; then \
		echo "--------------------------------------------------"; \
	       	echo ""; echo ""; echo ".env does not exist yet."; echo ""; \
		echo "Run make deploy to set up your stack!"; echo ""; \
		echo "--------------------------------------------------"; \
	       	exit 1; \
	fi

