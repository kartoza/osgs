SHELL := /bin/bash

build:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Fetching pbf if not cached and then copying to settings dir"
	@echo "------------------------------------------------------------------"
	@docker-compose build pbf
	@docker-compose up -d pbf
	@docker cp maceiramergindbsync_pbf_1:/settings/country.pbf ../osm_conf
	@docker-compose rm -f pbf

ps:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Current status"
	@echo "------------------------------------------------------------------"
	@docker-compose ps

deploy: build
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting all containers"
	@echo "------------------------------------------------------------------"
	@docker-compose up -d

restart:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restarting all containers"
	@echo "------------------------------------------------------------------"
	@docker-compose restart

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
	@docker cp maceiramergindbsync_db_1:/tmp/QGISProject.sql .
	@docker-compose exec -u postgres db rm /tmp/QGISProject.sql
	@ls -lah QGISProject.sql

db-qgis-project-restore:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restoring QGIS project to db"
	@echo "------------------------------------------------------------------"
	@docker cp QGISProject.sql maceiramergindbsync_db_1:/tmp/ 
	# - at start of next line means error will be ignored (in case QGIS project table isnt already there)
	-@docker-compose exec -u postgres db psql -c "drop table qgis_projects;" gis 
	@docker-compose exec -u postgres db psql -f /tmp/QGISProject.sql -d gis
	@docker-compose exec db rm /tmp/QGISProject.sql
	@docker-compose exec -u postgres db psql -c "select name from qgis_projects;" gis 

db-backup:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Backing up entire postgres db"
	@echo "------------------------------------------------------------------"
	@docker-compose exec -u postgres db pg_dump -Fc -f /tmp/smallholding-database.dmp gis
	@docker cp maceiramergindbsync_db_1:/tmp/smallholding-database.dmp .
	@docker-compose exec -u postgres db rm /tmp/smallholding-database.dmp
	@ls -lah smallholding-database.dmp

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
	@docker-compose logs -f qgis-server nginx


reinitialise-osm:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Deleting all imported OSM data and reloading"
	@echo "------------------------------------------------------------------"
	@docker-compose kill imposm
	@docker-compose kill osmupdate
	@docker-compose kill osmenrich
	@docker-compose rm imposm
	@docker-compose rm osmupdate
	@docker-compose rm osmenrich
	@sudo rm osm_conf/timestamp.txt
	@sudo rm osm_conf/last.state.txt
	@sudo rm osm_conf/importer.lock
	@docker-compose exec -u postgres db psql -c "drop schema osm cascade;" gis 
	@docker-compose exec -u postgres db psql -c "drop schema osm_backup cascade;" gis 
	@docker-compose exec -u postgres db psql -c "drop schema osm_import cascade;" gis 
	@docker-compose up -d imposm osmupdate osmenrich 
	@docker-compose logs -f imposm osmupdate osmenrich


reinitialise-mergin:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Deleting mergin database schemas and removing local sync files"
	@echo "Then restarting the mergin sync service"
	@echo "------------------------------------------------------------------"
	@docker-compose kill mergin-sync
	@docker-compose rm mergin-sync
	@sudo rm -rf mergin_sync_data/*
	@docker-compose exec -u postgres db psql -c "drop schema smallholding cascade;" gis 
	@docker-compose exec -u postgres db psql -c "drop schema mergin_sync_base_do_not_touch cascade;" gis 
	@docker-compose up -d mergin-sync
	@docker-compose logs -f mergin-sync


mergin-logs:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Polling mergin-db-sync logs"
	@echo "------------------------------------------------------------------"
	@docker-compose logs -f mergin-sync


qgis-logs:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Polling QGIS Server logs"
	@echo "------------------------------------------------------------------"
	@docker-compose logs -f qgis-server


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

nuke:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Nuking Everything!
	@echo "------------------------------------------------------------------"
	@sudo rm -rf postgis_data/*
	@sudo rm -rf mergin_sync_data/*
	@sudo rm -rf geoserver_data/*
	@sudo rm -rf certbot/certbot

