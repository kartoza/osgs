# Introduction

The Open Source GIS Stack by [Kartoza](https://kartoza.com/en/) is maintained in the [kartoza / osgs](https://github.com/kartoza/osgs) repository. 

## What is the Open Source GIS Stack?

In the open source geospatial world, there are different interesting
technologies that have been developed to allow one to manipulate, visualize,
publish, manage, edit, etc. geospatial data. These technologies are often in
disparate projects. Programs like the QGIS project, are often ensemble
applications that take some of these different technologies as components and
use them to provide some higher level functionality. In some cases the
integration is in silos or vertical applications, for example QGIS, PostGIS,
Geoserver, etc. The aim of this project is to take a number of those different
silos and incoporate them into a single platform, therefore making it really
easy to access and publish the different types of services that are easily
available on their own but not so easily available in a consolidated platform.

The [Open Source GIS Stack
(OSGS)](https://kartoza.github.io/osgs/introduction.html) is a platform based
on [Docker](https://www.docker.com/), which is a container deployment
environment. Containers are isolated application runtimes. They typically
contain a minimal version of an operating system, typically Linux. In that
minimal version of the operating system the containers will typically have one
single task they are responsible for doing, for example running PostGIS or
running Geoserver and so on. Each container has a very specific task and the
design intent that you do not deploy mutliple services in a single container.
You must deploy each service in its own container then orcherstrate those
containers together. This is all managed using Docker and Docker Compose which
is the orchestration environment for Docker. OSGS is simply a set of Docker
orchestration routines to bring up different services in different containers,
make them all talk together and present them as one cohesive architecture.


The Open Source GIS Stack (OSGS) is a platform based on Docker, which is a container deployment environment. 
Containers are isolated application runtimes. They typically contain a minimal version of an operating 
system, typically Linux. In that minimal version of the operating system the containers will typically 
have one single task they are responsible for doing, for example running PostGIS or running Geoserver 
and so on. Each container has a very specific task and the design intent that you do not deploy mutliple 
services in a single container. You must deploy each service in its own container then orcherstrate those 
containers together. This is all managed using Docker and Docker Compose which is the orchestration 
environmnt for Docker. OSGS is simply a set of Docker orchestration routines to bring up different 
services in different containers, make them all talk together and present them as one cohesive architecture.

The other important thing that OSGS does, is it provides some scripts to do various management 
commands and tasks, for example, bringing up services or down services, copying data, making 
backups, etc. These scripts are provided using a utility called "make" which is typically used 
by programmers to compile software, but can also be used to automate tasks. There is a Makefile 
which does all the high level tasks on the orchestrated architecture that OSGS provides.




<div class="admonition warning">
The services published in OSGS are independent from the Open Source GIS Stack project 
and any issues encountered using these applications should be raised with the 
appropriate upstream project.
</div>

## Overview Diagram

![Overview Diagram](img/QGIS-Server-PG-Project-Design.png)



**Note**: Anybody can take open source software and package it as Docker services. 
Therefore, when you are choosing which Docker service and containers to run, you can 
go and have a look at the various ways different people have packaged up a particular 
software and find one that works the best for you.
