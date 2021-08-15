# SCP File Drop Service

This is a container intended for users to upload files for publication on the
server. It runs on port 2222 so we need to expose that through the firewall:

```
sudo ufw allow 2222
```

You can add your public keys from the host e.g.

```
cat ~/.ssh/authorized_keys > scp_conf/gis_projects
```

Or copy them in by other means. Each file you create in scp_conf will be a user
name when the scp container runs, with it’s own directory in the storage
volume, unless an explicit storage volume has been pre-defined (see list of
these below). Each file should contain a list of public keys. If you add a key
at some point, or a new user file, you may need to restart the container:

```
docker-compose profile=scp restart
```

The following scp shares are made for the various purposes listed below. You
need to follow the same pattern of creating a config file for each. These
shares each have a dedicated volume associated with it which is also mounted
into the associated server container.


---

* **User:** geoserver_data
* **Named Volume:** scp_geoserver_data
* **Volume Mounted To:**	scp, geoserver	
* **Notes:** Copy vector and raster datasets here for publishing in GeoServer.
* **Example Use:** ``sftp://geoserver_data@<hostname>:2222/home/geoserver_data``
  
---

* **User:** qgis_projects
* **Named Volume:** scp_qgis_projects
* **Volume Mounted To:** scp, qgis-server
* **Notes:** Copy QGIS projects and data here for publishing with QGIS Server.
  See notes on directory layout below.
* **Example Use:** ``sftp://qgis_projects@<hostname>:2222/home/qgis_projects``
  
---

* **User:** qgis_svgs
* **Named Volume:** scp_qgis_svgs
* **Volume Mounted To:** scp, qgis-server
* **Notes:** Embed SVGs in styles by preference in QGIS. Use this drop if you
  have no way to use embeded SVGS.
* **Example Use:** ``sftp://qgis_svgs@<hostname>:2222/home/qgis_svgs`

---

* **User:** qgis_fonts
* **Named Volume:** scp_qgis_fonts
* **Volume Mounted To:** scp, qgis-server
* **Notes:** Copy fonts directly into the root folder.
* **Example Use:** ``sftp://qgis_fonts@<hostname>:2222/home/qgis_fonts``

---

* **User:** hugo_data
* **Named Volume:** scp_hugo_data
* **Volume Mounted To:** scp, hugo*
* **Notes:** Upload markdown files for static site generation with Hugo.
* **Example Use:** ``sftp://hugo_data@<hostname>:2222/home/hugo_data``

---

* **User:** odm_data
* **Named Volume:** scp_odm_data
* **Volume Mounted To:** scp, odm *
* **Notes:** Upload imagery data for processing with ODM
* **Example Use:** ``sftp://odm_data@<hostname>:2222/home/odm_data``

---

* **User:** general_data
* **Named Volume:** scp_general_data
* **Volume Mounted To:** scp
* **Notes:** General sharing directory. Later we  will publish this under nginx
  for public downloads. Don’t put any sensitive data in here.
* **Example Use:** ``sftp://general_data@<hostname>:2222/home/general_data``

---

**Note:** Any user connecting to any of these shares will be able to see all
other files from all other users. They will only have write access to the
folder they are connecting to, for all other shares their access will be read
only. If you want to further partition the access to files you can create
multiple scp services, each with one of the mount points listed above. In so
doing users would not be able to see the other mount points listed above.

## Directory layout for the QGIS projects folder

When adding projects to the qgis_projects folder, you need to follow this
convention strictly for the projects to be recognised by QGIS Server:

``qgis_projects/<project_name>/<project_name>.qgs``

For example:

``qgis_projects/terrain/terrain.qgs``

There is a convenience Make target that will copy your .ssh/authorized_keys
file contents into each of the scp_config user files listed in the table above.


``make setup-scp``

## Starting the container

``docker-compose --profile=scp up -d scp``

Example copying of data into the container from the command line:

``scp -P 2222 sample-document.txt localhost:/data//gis_projects/gis_projects/gis_projects``

In Nautilus (file manager in Linux Gnome Desktop) you can test by connecting 

``sftp://<hostname>:2222/data/gis_projects``

into the red highlighted box below:

XXXXXXXXXXXXXXXXXXXX


After that open a second window and you can drag and drop files too and from
the folder. Windows users can use the free WinSCP application to copy files to
the server.  


## FAQ

**Q:** When connecting I get “Host key validation failure” or similar
**A:** Remove the entry for the server in your ~/.ssh/known_hosts
