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

