SHELL := /bin/bash

# We need to declare phony here since the docs dir exists
# otherwise make tries to execute the docs file directly
.PHONY: docs
docs:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Making docs"
	@echo "------------------------------------------------------------------"
	$(MAKE) -C docs html
	$(MAKE) -C docs latexpdf
	@cp docs/build/latex/osgs.pdf osgs-manual.pdf

ps:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Current status"
	@echo "------------------------------------------------------------------"
	@docker-compose ps

configure: prepare-templates deploy


prepare-templates: 
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Preparing templates"
	@echo "This will replace any local configuration changes you have made"
	@echo "in .env, nginx_conf/servername.conf"
	@echo "------------------------------------------------------------------"
	@echo -n "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	@cp .env.example .env
	@cp nginx_conf/servername.conf.example nginx_conf/servername.conf
	@echo "Please enter your valid domain name for the site."
	@echo "e.g. example.org or subdomain.example.org:"
	@read -p "Domain name: " DOMAIN; \
		rpl example.org $$DOMAIN nginx_conf/servername.conf .env; 
	@echo "We are going to set up a self signed certificate now."
	@make configure-ssl-self-signed
	@cp nginx_conf/ssl/certifcates.conf.selfsigned.example nginx_conf/ssl/ssl.conf
	@echo "Afterwards if you want to put the server into production mode"
	@echo "please run:"
	@echo "make configure-letsencrypt-ssl"

configure-ssl-self-signed:
	@openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./certbot/certbot/conf/nginx-selfsigned.key -out ./certbot/certbot/conf/nginx-selfsigned.crt

configure-letsencrypt-ssl:
	@echo "Do you want to set up SSL using letsencrypt?"
	@echo "This is recommended for production!"
	@echo -n "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	@echo "Please enter your valid domain name for the SSL certificate."
	@echo "e.g. example.org or subdomain.example.org:"
	@read -p "Domain name: " DOMAIN; \
		rpl example.org $$DOMAIN nginx_certbot_init_conf/nginx.conf init-letsencrypt.sh; 
	@cp nginx_certbot_init_conf/nginx.conf.example nginx_certbot_init_conf/nginx.conf
	@cp init-letsencrypt.sh.example init-letsencrypt.sh
	@cp nginx_conf/ssl/ssl.conf.example nginx_conf/ssl/ssl.conf
	@read -p "Valid Contact Person Email Address: " EMAIL; \
	   rpl validemail@yourdomain.org $$EMAIL init-letsencrypt.sh .env

deploy:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting all production containers"
	@echo "------------------------------------------------------------------"
	@docker-compose --profile=production up -d --scale qgis-server=10 --remove-orphans
	@docker-compose --profile=production restart nginx


init-letsencrypt:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Getting an SSL cert from letsencypt"
	@echo "------------------------------------------------------------------"
	@./init-letsencrypt.sh	
	@docker-compose --profile=certbot-init kill
	@docker-compose --profile=certbot-init rm
	@make build-pbf



configure-htpasswd:
	@export PASSWD=$(pwgen 20 1); \
	       	htpasswd -cbB nginx_conf/nginx.conf htpasswd web $$PASSWD; \
		echo "#User account for protected areas of the site using httpauth" >> .env \
		echo "#You can add more accounts to nginx_conf/htpasswd using the htpasswd tool" >> .env \
		echo $$PASSWD >> .env
configure-pgpasswd:
	@export PASSWD=$$(pwgen 20 1); \
		rpl POSTGRES_PASSWORD=docker POSTGRES_PASSWORD=$$PASSWD .env; \
		echo "Postgres password set to $$PASSWD"

configure-geoserver-passwd:
	@export PASSWD=$$(pwgen 20 1); \
		rpl GEOSERVER_ADMIN_PASSWORD=myawesomegeoserver GEOSERVER_ADMIN_PASSWORD=$$PASSWD .env; \
		echo "GeoServer password set to $$PASSWD"

configure-timezone:
	@echo "Please enter the timezone for your server"
	@echo "See https://en.wikipedia.org/wiki/List_of_tz_database_time_zones"
	@echo "Follow exactly the format of the TZ Database Name column"
	@read -p "Server Time Zone (e.g. Etc/UTC):" TZ; \
	   rpl TIMEZONE=Etc/UTC TIMEZONE=$$TZ .env

configure-postgrest:
	@echo "=========================:"
	@echo "PostgREST specific updates:"
	@echo "=========================:"
	@export PASSWD=$$(pwgen 20 1); \
		rpl PGRST_JWT_SECRET=foobarxxxyyyzzz PGRST_JWT_SECRET=$$PASSWD .env; \
		echo "PostGREST JWT token set to $$PASSWD"

configure-mapproxy:
	@echo "=========================:"
	@echo "Mapproxy specific updates:"
	@echo "=========================:"
	@cp mapproxy_conf/mapproxy.yaml.example mapproxy_conf/mapproxy.yaml 
	@cp mapproxy_conf/seed.yaml.example mapproxy_conf/seed.yaml 
	@echo "We have created template mapproxy.yaml and seed.yaml"
	@echo "configuration files in mapproxy_conf."
	@echo "You will need to hand edit those files and then "
	@echo "restart mapproxy for those edits to take effect."
	@echo "see: make reinitialise-mapproxy"	

configure-mergin-client:
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

configure-osm-mirror:
	@echo "=========================:"
	@echo "OSM Mirror specific updates:"
	@echo "=========================:"
	@echo "I have prepared my clip area (optional) and"
	@echo "saved it as osm_config/clip.geojson."
	@echo "You can easily create such a clip document"
	@echo "at https://geojson.io or by using QGIS"
	@read -p "Press enter to continue" CONFIRM;


restart:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restarting all containers"
	@echo "------------------------------------------------------------------"
	@docker-compose --profile=production restart

db-shell:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating db shell"
	@echo "------------------------------------------------------------------"
	@docker-compose exec -u postgres db psql gis

db-qgis-project-backup:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Backing up QGIS project stored in db"
	@echo "------------------------------------------------------------------"
	@docker-compose exec -u postgres db pg_dump -f /tmp/QGISProject.sql -t qgis_projects gis
	@docker cp osgisstack_db_1:/tmp/QGISProject.sql .
	@docker-compose exec -u postgres db rm /tmp/QGISProject.sql
	@ls -lah QGISProject.sql

db-qgis-project-restore:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restoring QGIS project to db"
	@echo "------------------------------------------------------------------"
	@docker cp QGISProject.sql osgisstack_db_1:/tmp/ 
	# - at start of next line means error will be ignored (in case QGIS project table isnt already there)
	-@docker-compose exec -u postgres db psql -c "drop table qgis_projects;" gis 
	@docker-compose exec -u postgres db psql -f /tmp/QGISProject.sql -d gis
	@docker-compose exec db rm /tmp/QGISProject.sql
	@docker-compose exec -u postgres db psql -c "select name from qgis_projects;" gis 

db-backup:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Backing up entire GIS postgres db"
	@echo "------------------------------------------------------------------"
	@docker-compose exec -u postgres db pg_dump -Fc -f /tmp/osgisstack-database.dmp gis
	@docker cp osgisstack_db_1:/tmp/osgisstack-database.dmp .
	@docker-compose exec -u postgres db rm /tmp/osgisstack-database.dmp
	@ls -lah osgisstack-database.dmp

db-backupall:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Backing up all postgres databases"
	@echo "------------------------------------------------------------------"
	@docker-compose exec -u postgres db pg_dumpall -f /tmp/osgisstack-all-databases.dmp
	@docker cp osgisstack_db_1:/tmp/osgisstack-all-databases.dmp .
	@docker-compose exec -u postgres db rm /tmp/osgisstack-all-databases.dmp
	@ls -lah osgisstack-all-databases.dmp

db-backup-mergin-base-schema:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Backing up mergin base schema from  postgres db"
	@echo "------------------------------------------------------------------"
	@docker-compose exec -u postgres db pg_dump -Fc -f /tmp/mergin-base-schema.dmp -n mergin_sync_base_do_not_touch gis
	@docker cp osgisstack_db_1:/tmp/mergin-base-schema.dmp .
	@docker-compose exec -u postgres db rm /tmp/mergin-base-schema.dmp
	@ls -lah mergin-base-schema.dmp

reinitialise-mapproxy:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restarting Mapproxy and clearing its cache"
	@echo "------------------------------------------------------------------"
	@docker-compose kill mapproxy
	@docker-compose rm mapproxy
	@rm -rf mapproxy_conf/cache_data/*
	@docker-compose up -d mapproxy
	@docker-compose logs -f mapproxy


reinitialise-qgis-server:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restarting QGIS Server and Nginx"
	@echo "------------------------------------------------------------------"
	@docker-compose kill qgis-server
	@docker-compose rm qgis-server
	@docker-compose up -d qgis-server
	@docker-compose restart nginx
	@docker-compose logs -f qgis-server 

build-bpf:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Fetching pbf if not cached and then copying to settings dir"
	@echo "You can download PBF files from GeoFabrik here:"
	@echo "https://download.geofabrik.de/"
	@echo "------------------------------------------------------------------"
	@read -p "URL For Country PBF File: " URL; \
	   cp pbf_fetcher/Dockerfile.example pbf_fetcher/Dockerfile; \
	   rpl PBF_URL $$URL pbf_fetcher/Dockerfile
	@docker-compose build pbf
	@docker-compose run pbf
	@docker-compose rm -f pbf

kill-osm:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Deleting all imported OSM data and killing containers"
	@echo "------------------------------------------------------------------"
	@docker-compose kill imposm
	@docker-compose kill osmupdate
	@docker-compose kill osmenrich
	@docker-compose rm imposm
	@docker-compose rm osmupdate
	@docker-compose rm osmenrich
	# Next commands have - in front as they as non compulsory to succeed
	-@sudo rm osm_conf/timestamp.txt
	-@sudo rm osm_conf/last.state.txt
	-@sudo rm osm_conf/importer.lock
	-@docker-compose exec -u postgres db psql -c "drop schema osm cascade;" gis 
	-@docker-compose exec -u postgres db psql -c "drop schema osm_backup cascade;" gis 
	-@docker-compose exec -u postgres db psql -c "drop schema osm_import cascade;" gis 


reinitialise-osm: kill-osm
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Deleting all imported OSM data and reloading"
	@echo "------------------------------------------------------------------"
	@docker-compose up -d imposm osmupdate osmenrich 
	@docker-compose logs -f imposm osmupdate osmenrich

osm-to-mbtiles:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating a vector tiles store from the docker osm schema"
	@echo "------------------------------------------------------------------"
        #@docker-compose run osm-to-mbtiles
	@echo "we use below for now because the container aproach doesnt have a new enough gdal (2.x vs >=3.1 needed)"
	@ogr2ogr -f MBTILES osm.mbtiles PG:"dbname='gis' host='localhost' port='15432' user='docker' password='docker' SCHEMAS=osm" -dsco "MAXZOOM=10 BOUNDS=-7.389126,39.410085,-7.381439,39.415144"
	
redeploy-mergin-client:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Stopping merging container, rebuilding the image, then restarting mergin db sync"
	@echo "------------------------------------------------------------------"
	-@docker-compose kill mergin-sync
	-@docker-compose rm mergin-sync
	-@docker rmi mergin_db_sync
	@git clone git@github.com:lutraconsulting/mergin-db-sync.git --depth=1
	@cd mergin-db-sync; docker build --no-cache -t mergin_db_sync .; cd ..
	@rm -rf mergin-db-sync
	@docker-compose --profile=mergin up -d mergin-sync
	@docker-compose --profile=mergin logs -f mergin-sync

reinitialise-mergin-client:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Deleting mergin database schemas and removing local sync files"
	@echo "Then restarting the mergin sync service"
	@echo "------------------------------------------------------------------"
	@docker-compose kill mergin-sync
	@docker-compose rm mergin-sync
	@sudo rm -rf mergin_sync_data/*
	# Next line allowed to fail
	-@docker-compose exec -u postgres db psql -c "drop schema qgis_demo cascade;" gis 
	# Next line allowed to fail
	-@docker-compose exec -u postgres db psql -c "drop schema mergin_sync_base_do_not_touch cascade;" gis 	
	@docker-compose --profile=mergin up -d mergin-sync
	@docker-compose --profile=mergin logs -f mergin-sync

mergin-dbsycn-start:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting mergin-db-sync service"
	@echo "------------------------------------------------------------------"
	@docker-compose --profile=mergin up mergin-sync
	@docker-compose --profile=mergin logs -f mergin-sync

mergin-dbsync-logs:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Polling mergin-db-sync logs"
	@echo "------------------------------------------------------------------"
	@docker-compose --profile=mergin logs -f mergin-sync

get-fonts:
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


qgis-logs:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Polling QGIS Server logs"
	@echo "------------------------------------------------------------------"
	@docker-compose logs -f qgis-server


odm-clean:
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
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Generating ODM Ortho, DEM, DSM then clipping it and loading it into postgis"
	@echo "Before running please remove any old images from odm_datasets/osgisstack/images"
	@echo "and copy the images that need to be mosaicked into it."
	@echo "Note that the odm_datasets directory should be considered mutable as this script "
	@echo "cleans out all other files"
	@echo "------------------------------------------------------------------"
	@docker-compose run odm

odm-clip:
	@echo "------------------------------------------------------------------"
	@echo "Clippint Ortho, DEM, DSM"
	@echo "------------------------------------------------------------------"
	@docker-compose run odm-ortho-clip
	@docker-compose run odm-dsm-clip
	@docker-compose run odm-dtm-clip

odm-pgraster: export PGPASSWORD = docker
odm-pgraster:
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


site-init: site-config site-build site-set-output

site-config:
	@echo "------------------------------------------------------------------"
	@echo "Configure your static site content management system"
	@echo "You should only do this once per site deployment"
	@echo "------------------------------------------------------------------"
	@echo "This will replace any local configuration changes you have made"
	@echo "------------------------------------------------------------------"
	@echo -n "Are you sure you want to continue? [y/N] " && read ans && [ $${ans:-N} = y ]
	@cp ./site_data/config.yaml.example ./site_data/config.yaml
	@echo "Please enter the site domain name (default 'example.com')"
	@read -p "Domain name: " result; \
	  DOMAINNAME=$${result:-"example.com"} && \
	  rpl -q {{siteDomain}} "$$DOMAINNAME" $(shell pwd)/site_data/config.yaml
	@echo "Please enter the title of your website (default 'Geoservices')"
	@read -p "Site Title: " result; \
	  SITETITLE=$${result:-"Geoservices"} && \
	  rpl -q {{siteTitle}} "$$SITETITLE" $(shell pwd)/site_data/config.yaml
	@echo "Please enter the name of the website owner (default 'Kartoza')"
	@read -p "Site Owner: " result; \
	  SITEOWNER=$${result:-"Kartoza"} && \
	  rpl -q {{ownerName}} "$$SITEOWNER" $(shell pwd)/site_data/config.yaml
	@echo "Please supply the URL of the site owner (default 'www.kartoza.com')."
	@read -p "Owner URL: " result; \
	  OWNERURL=$${result:-"www.kartoza.com"} && \
	  rpl -q {{ownerDomain}} "$$OWNERURL" $(shell pwd)/site_data/config.yaml
	@echo "Please supply a valid public URL to the Website Logo."
	@echo "Be sure to include the protocol prefix (e.g. https://)"
	@read -p "Logo URL: " result; \
	  LOGOURL=$${result:-"img/Circle-icons-stack.svg"} && \
	  rpl -q {{logoURL}} "$$LOGOURL" $(shell pwd)/site_data/config.yaml

site-reset:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Reset site configuration to default values"
	@echo "This will replace any local configuration changes you have made"
	@echo "------------------------------------------------------------------"
	@echo -n "Are you sure you want to continue? [y/N] " && read ans && [ $${ans:-N} = y ]
	@cp ./site_data/config.yaml.example ./site_data/config.yaml

site-build:
	@echo "------------------------------------------------------------------"
	@echo "Building the site, compiling html from any new pages."
	@echo "------------------------------------------------------------------"
	@docker run --rm -it -v $(shell pwd)/site_data:/src klakegg/hugo:0.82.0

#
# TIM: I think we can delete this one?
#
site-set-output:
	@echo "------------------------------------------------------------------"
	@echo "Setting site publication directory to $(shell pwd)/html"
	@echo "This will remove any existing in that location"
	@echo "------------------------------------------------------------------"
	@echo -n "Are you sure you want to continue? [y/N] " && read ans && [ $${ans:-N} = y ]
ifneq ("$(wildcard ./html)","")
	@rm -r $(shell pwd)/html
	@echo "Existing content removed"
else
	@echo "Existing data not available"
endif
	@ln -s $(shell pwd)/site_data/public $(shell pwd)/html
	@echo "Symbolic link created"

site-serve:
	@echo "------------------------------------------------------------------"
	@echo "Serving the site locally - intended for local testing only."
	@echo "------------------------------------------------------------------"
	@docker run --rm -it -v $(shell pwd)/site_data:/src -p 1313:1313 klakegg/hugo:0.82.0 server


setup-scp:
	@echo "------------------------------------------------------------------"
	@echo "Copying .ssh/authorized keys to all scp shares."
	@echo "------------------------------------------------------------------"
	@cat ~/.ssh/authorized_keys > scp_conf/geoserver_data
	@cat ~/.ssh/authorized_keys > scp_conf/qgis_projects
	@cat ~/.ssh/authorized_keys > scp_conf/qgis_fonts
	@cat ~/.ssh/authorized_keys > scp_conf/qgis_svg
	@cat ~/.ssh/authorized_keys > scp_conf/hugo_data
	@cat ~/.ssh/authorized_keys > scp_conf/odm_data
	@cat ~/.ssh/authorized_keys > scp_conf/general_data

kill:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Killing all containers"
	@echo "------------------------------------------------------------------"
	@docker-compose kill

rm: kill
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Removing all containers"
	@echo "------------------------------------------------------------------"
	@docker-compose rm

nuke: rm
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Nuking Everything!
	@echo "------------------------------------------------------------------"
	@sudo docker volume prune
	@sudo rm -rf certbot/certbot

