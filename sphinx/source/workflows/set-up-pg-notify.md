# Set up process for pg notify

Pg notify is a notification system that Postgres has that can let a client know that a change has occurred in the database. This workflow will demonstrate how to: 

* Register the notification function
* Push out the message to a client (we will start with QGIS as the client)
* Have QGIS automatically update and refresh the canvas when a notification happens