# Introduction

## **What is the Open Source GIS Stack?**
In the open source geospatial world, there are different interesting technologies that have been developed to allow one to manipulate, visualize, publish, manage, edit, etc. geospatial data.  These technologies are often in disparate projects. Programs like the QGIS project, are often ensemble applications that take some of these different technologies as components and use them to provide some higher level functionality. In some cases the integration is in silos or vertical applications, for example QGIS, PostGIS, Geoserver, etc. The aim of this project is to take a number of those different silos and incoporate them into a single platform, therefore making it really easy to access and publish the different types of services that are easily avalibale on their own but not so easily available in a consolidated platform.

This project provides a platform for creating, sharing and publishing data and maps using an Open Source GIS Stack. It has two primary objectives:

1. Provide a platform that integrates these technologies:
   1. One or more [QGIS](https://qgis.org) Projects
      1. Projects stored in-database in PostgreSQL
      2. Projects stored in the file system
   2. QGIS Server
      1. Publishing projects stored on the files system
      2. Publishing projects stored in the database
   3. Field data collection and project synchronisation support:
      1. The [Mergin](https://public.cloudmergin.com/#) platform for cloud storage of projects
      2. The [INPUT](https://inputapp.io/en/) mobile data collection platform
      3. The [Mergin-db-sync](https://github.com/lutraconsulting/mergin-db-sync) tool that will synchronise a Mergin cloud project into a PostgreSQL project.
   6. [PostgreSQL](https://postgresql.org) and [PostGIS](https://postgis.net/) running in Docker and providing a database backend for our stack.
   7. [NGINX](https://www.nginx.com/) a lightweight web server acting as a proxy in front of QGIS server and as a server for the static HTML content.
   8. [QGIS Server](https://docs.qgis.org/3.16/en/docs/) to serve QGIS projects from the database and from the file system.
   9. [QGIS Server Docker Image](https://github.com/gem/oq-qgis-server) from OpenQuake.
   10. [Apache Superset](https://superset.apache.org/) to provide dashboard visualisations


<div class="admonition warning">
These projects are independent from the Opsn Source GIS Stack project and any issues encountered using these applications should be raised with the appropriate upstream project.
</div>

## Overview Diagram

![Overview Diagram](img/QGIS-Server-PG-Project-Design.png)


The Open Source GIS Stack (OSGS) is a platform based on Docker, which is a container deployment environment. Containers are isolated application runtimes. They typically contain a minimal version of an operating system, typically Linux. In that minimal version of the operating system the containers will typically have one single task they are responsible for doing, for example running PostGIS or running Geoserver and so on. Each container has a very specific task and the design intent that you do not deploy mutliple services in a single container. You must deploy each service in its own container then orcherstrate those containers together. This is all managed using Docker and Docker Compose which is the orchestration environemnt for Docker. OSGS is simply a set of Docker orchestration routines to bring up different services in different containers, make them all talk together and present them as one cohesive architecture.

The other important thing that OSGS does, is it provides some scripts to do various management commands and tasks, for example, bringing up services or down services, copying data, making backups, etc. These scripts are provided using a utility called "make" which is typically used by programmers to compile software. You can also use "make" as a general purpose automation library or application. There is a make file which does some more high level tasks on the orchestrated architecture that OSGS provides.



## **What can you find inside the OSGS stack?**
This section will give a basic overview of some of the key components of the OSGS stack.

### **PostGIS and PostgreSQL**
The heart of any stack like this would be PostGIS and PostgreSQL. This is because many of the other tools provided in the OSGS stack, for example Goeserver, QGIS Server and Mergin, all rely or can make use of PostGIS as a data storage platform and in some cases as a data anlysis platform. The OSGS stack provides  PostgreSQL version 13 along with PostGIS which are provided by the the Kartoza PostGIS Docker container. There are a few considerations that were made when deploying this container. One, which is actually a general design consideration of the OSGS stack, is to try and make everything as secure as possible out of the box, rather than leaving security as an afterthought. To fulfill this consideration, what the OSGS stack does, is it spins up a PostgreSQL instance with PostGIS deployed in it and creates a separate user account for connecting to this instance. It also enables SSL encription by default, as required to the PostgreSQL database. This is so that if you choose to open the port as a public service, firstly, we are not using some well documented default password and username combination and secondly, all the traffic between your client application and the server is encrypted.

### **QGIS Server**
For the QGIS Server, we have chosen the OpenQuake build of QGIS Server because it has a few interesting characteristics. One, is that you can deploy QGIS Server side extensions easily with it and two, is that it supports things like the QGIS Authentication System. The QGIS Authentication System is an authentication database that provides more advanced securty options, provides Pg service support, and provides some special features for url rerouting so that your project paths are hidden away from the user (which is both a security and a convenience concern).  Every project you publish will be available at ```/ogc/project_name``` which makes it very simple to discover where the projects are deployed on the server.

The OpenQuake QGIS Server is deployed as a QGIS Server instance. The OSGS stack also provides a couple of sample plugins like a demonstrater plugin and a plugin for handling atlas reports. The demonstrater plugin is a modified version of the Git feature info handler and will return some html back and some nicely formatted table. The plugin for handling atlas reports, written by Lizmap and (?) as a QGIS propriety extension to the WMS service protocol, allows you to request a specific page of an altas, a QGIS composed atlas, as the report. This is pretty handy if you, for example, click on a feature and you want to get then from an atlas report the one page that that feauture is covered in the atlas.

Another feature that Docker provides for applications such as QGIS Server is the ability to horizontally scale them. Our platform has some key configuration examples showing you how you can, for example, scale up the QGIS Server instance to have ten concurrently running instances. This is useful for handling increased or high load on the server. It will do like a ram rob(?) and server handler, so that as the requests come in, it will pass each successive request over to the next running instance, and those requests will be handled by that instance, passed back and then that instance will stand by and wait for the next request to come in.

### **SCP File Drop Service**
The QGIS Server works in orchestration with many of the other containers, including the PostGIS container. It also works pretty well in conjuction with the SCP (secure copy) container which allows the users of the OSGS architecture to easily move data from their local machine onto the server, either manually by copying and pasting files using an application such as Onescp or using built into Linux file browsers. For example, if you are one the GNOME desktop it has built into SFTP support.

The SCP containers have been arranged so that there are some standard containers out of the box. Each container has its data stored in its own docker volume as well. The data is somewhat isolated and there are containers for QGIS projects, fonts, SVGs that your QGIS projects might reference, general file sharing, uploading data to ODM, etc. The SCP service is designed to only support connections with SSH public-private key encryption and password based authentication. The way that you provision users into it is that you copy the SSH public key into a file in the configuration folder for SCP and then that user will be allowed to make the connection to whichever SCP share that you have created for them. The SCP container can be used to copy a QGIS project file from your desktop up to the server with all the QGIS resources that it needs such as shapefiles. The QGIS Server instance can then be used to access the project from the OGC web services.








**Note**: Anybody can take open source software and package it as Docker services. Therefore, when you are choosing which Docker service and containers to run, you can go and have a look at the various ways different people have packaged up a particular software and find one that works the best for you.
