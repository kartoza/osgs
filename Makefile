COMPOSE := -f docker-compose.yml

SHELL := /bin/bash

# -------------------------
#    BUILD THE PBF FETCHER
# -------------------------

run-docker-pbf-fetcher:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Fetching pbf if not cached and then copying to settings dir"
	@echo "------------------------------------------------------------------"
	@cd pbf_fetcher
	@docker build -t "pbf:latest" .
	@docker run -d --name pbf pbf
	@docker cp pbf:/settings/country.pbf ../osm_conf
	@docker rm -f pbf
	@cd ..

logs:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Show logs of stack status"
	@echo "------------------------------------------------------------------"
	@docker-compose -f docker-compose.yml logs --tail 100 -f
