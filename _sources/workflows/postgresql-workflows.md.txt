# PostgreSQL Workflows - PR

There are a number of different workflows we will explore here: 

* Connecting to the PostgreSQL database from your QGIS Desktop application
* Connecting to the PostgreSQL database from QGIS Server
* Connecting to the PostgreSQL database from GeoServer
* Connecting from other applications

Before we dive into the details here, let us quickly examine some basic use cases:

* You collect data in the field using Input and use the mergin-db-sync workflow to synchronised field collected data into the database, then publish maps for this data in QGIS Server.
* You want to publish a layer in GeoServer, so you connect to the database from your desktop, drag and drop a local file system layer into the database using QGIS, then publish the layer from GeoServer.
* You want to create a project in QGIS desktop that uses PostgreSQL for data storage, then publish that data as a QGIS Project.

There are many other workflows that the Open GIS Stack supports, it is really up to your imagination! What is key to understand are the mechanisms that you can use to connect to the database in different contexts. And so we will focus this section on the different connection modalities.

## Direct connection

Direct connection to the server over the standard PostgreSQL port exposed to the public internet is probably the least secure but most convenient approach. We do not recommend this approach, and if you do follow it be sure to use the option to force remote clients to connect using SSL (and expect a performance penalty in the process).

Note also that connecting to a PostgreSQL database using QGIS from a remote host may often be slow and irritating to use on a daily basis, especially if your internet connection is not very fast and your datasets are large.

By default the docker-compose.yaml 


Publishing with QGIS Server

The workflows described in this section apply equally to any database hosted 

Further reading for understanding authentication with PostgreSQL using cert based authentication here:

https://joelonsql.com/2013/04/27/securing-postgresql-using-hostssl-cert-clientcert1/
