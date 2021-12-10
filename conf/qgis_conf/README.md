The auth pwd file contains the password to unlock the the QGIS 
The authdb file is created in QGIS and set with a master key in 
QGIS that is then pasted in the password file for QGIS server to 
read at run time

Make sure to copy over the authdb whenever you change it e.g.

sudo cp ~/.local/share/QGIS/QGIS3/profiles/Smallholding/qgis-auth.db qgis_conf/

Or more conveniently copy it into the filebrowser web file manager.

These files must be writable by the nginx user in the container. See 
below:

sudo chown 33:33 qgis_conf/auth-db-password/qgis*
sudo chown 33:33 qgis_conf/auth-db/qgis*
docker-compose exec qgis-server ls -lah /tmp


auth-db-password/qgis-auth-pwd.txt
auth-db/qgis-auth.db


Also make sure to restart docker containers after changing this.
