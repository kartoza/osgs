# Introduction

This project provides a platform for creating, sharing and publishing data and maps for your smallholding. It has two primary objectives:

1. Provide a demonstrator platform that integrates these technologies:
   1. One or more [QGIS](https://qgis.org) Projects
      1. Projects stored in-database in PostgreSQL
      2. Projects stored in the file system
   2. QGIS Server
   3. The [Mergin](https://public.cloudmergin.com/#) platform
   4. The [INPUT](https://inputapp.io/en/) mobile data collection platform
   5. The [Mergin-db-sync](https://github.com/lutraconsulting/mergin-db-sync) tool that will synchronise a Mergin cloud project into a PostgreSQL project.
   6. [PostgreSQL](https://postgresql.org) and [PostGIS](https://postgis.net/) running in Docker and providing a database backend for our stack.
   7. [NGINX](https://www.nginx.com/) a lightweight web server acting as a proxy in front of QGIS server and as a server for the static HTML content.
   8. [QGIS Server](https://docs.qgis.org/3.16/en/docs/) to serve QGIS projects from the database and from the file system.
   


https://github.com/gem/oq-qgis-server


# Overview Diagram

![Overview Diagram](diagrams/QGIS-Server-PG-Project-Design.png)

# Generalised Workflow

![Workflow Diagram](diagrams/QGIS-Server-PG-Project-Workflow.png)


# Essential Reading

You should read the [QGIS Server documentation](https://docs.qgis.org/3.16/en/docs/server_manual/getting_started.html#) on QGIS.org. It is well written and covers a lot of background explanation which is not provided here. Also you should familiarise yourself with the [Environment Variables](https://docs.qgis.org/3.16/en/docs/server_manual/config.html#environment-variables).



# Authentication Management


[Some discussion](http://osgeo-org.1560.x6.nabble.com/QGIS-Server-qgis-auth-db-td5408912.html) suggest to set authdb configuration parameters in Apache/Nginx but I found it would only work if I set these in the environment of the QGIS Server docker container.


