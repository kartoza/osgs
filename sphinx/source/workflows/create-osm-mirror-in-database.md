# Creating an Open Street Map mirror into your database

## Prepare the optional clip area and the url for the Country PBF file

To prepare a clip area to clip all the Open Street Map data to your area of interest, you will need to save the clip area document as `conf/osm_conf/clip.geojson`. You can easily create such a clip document at  https://geojson.io or by using QGIS. 

For this workflow the clip area for Nairobi County, Kenya, was obtained using QGIS. The Nairobi County boundary was obtained from the [Kenya- Subnational Administrative Boundaries data](https://data.humdata.org/dataset/ken-administrative-boundaries) using QGIS.

The PBF files for the country or region of interest can be downloaded from [GeoFabrik](https://download.geofabrik.de/). The PBF file used in this workflow was for Kenya and the URL for the country PBF file is https://download.geofabrik.de/africa/kenya-latest.osm.pbf. 

## Deploying the OSM mirror service. 

To deploy the initial stack including  Nginx, Hugo watcher and SCP services, please run either  `make configure-ssl-self-signed` or `make configure-letsencrypt-ssl`. 

To deploy the OSM mirror service, first deploy the Postgres service using `make deploy-postgres` then the OSM mirror service using  `make deploy-osm-mirror`. If you have PostgreSQL already installed outside of the stack ensure that you specify a different postgres public port other than the default 5432. 
Start the QGIS desktop application. 

The Postgres public port number, username and password are contained in the `.env` file. Use them to create a connection  to the `gis` database. 

