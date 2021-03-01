SHELL := /bin/bash

# -------------------------
#    BUILD THE PBF FETCHER
# -------------------------

run-docker-pbf-fetcher:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Fetching pbf if not cached and then copying to settings dir"
	@echo "------------------------------------------------------------------"
	@docker build -t "pbf:portugal" .
	@docker run -d --name pbf "pbf:portugal"
	@docker cp pbf:/settings/country.pbf ../osm_conf
	@docker rm -f pbf

