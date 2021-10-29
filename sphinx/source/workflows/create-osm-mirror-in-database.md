# Creating an Open Street Map mirror into your database

## Prepare the clip area and the url for the Country PBF file

To prepare a clip area to clip all the Open Street Map data to your area of interest, you will need to save the clip area document as `conf/osm_conf/clip.geojson`. 

<img align="middle" src="../img/osm-mirror-workflow-1.png" alt="OSM mirror " width="300">

You can easily create such a clip document at  https://geojson.io or by using QGIS. For this workflow the clip area document for the country Kenya, was obtained using QGIS. The Kenya country boundary data was obtained from the [Kenya- Subnational Administrative Boundaries data](https://data.humdata.org/dataset/ken-administrative-boundaries).

The PBF files for the country or region of interest can be downloaded from [GeoFabrik](https://download.geofabrik.de/). The PBF file used in this workflow was for Kenya and the URL for the country PBF file is https://download.geofabrik.de/africa/kenya-latest.osm.pbf. 

## Deploying the OSM mirror service. 

To deploy the initial stack, which includes the  Nginx, Hugo watcher and SCP services, please run either  `make configure-ssl-self-signed` or `make configure-letsencrypt-ssl`. 

Next deploy the Postgres service using `make deploy-postgres`. If you have PostgreSQL already installed outside of the stack (on your local machine) ensure that you specify a different postgres public port number other than the default 5432. For example you can use the port number 5434 for the public port. 

To deploy the OSM mirror service, using the `make deploy-osm-mirror` command and follow the subsequent instructions. 

Use the Postgres public port number, username and password contained in the `.env` file to create a connection  to the `gis` database. Make sure to the set the SSL mode to require. 

<img align="middle" src="../img/osm-mirror-workflow-2.png" alt="OSM mirror " width="300">

The imported Open Street Map layers are present in the `osm` schema of the database. 

<img align="middle" src="../img/osm-mirror-workflow-3.png" alt="OSM mirror " width="300">
