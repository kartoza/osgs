The auth pwd file contains the password to unlock the the QGIS 
The authdb file is created in QGIS and set with a master key in 
QGIS that is then pasted in the password file for QGIS server to 
read at run time

Make sure to copy over the authdb whenever you change it e.g.

sudo cp ~/.local/share/QGIS/QGIS3/profiles/Smallholding/qgis-auth.db qgis_conf/

These files must be writable by the nginx user in the container. See 
below:

sudo chown 33:33 qgis_conf/qgis*
docker-compose exec qgis-server ls -lah /tmp

total 84K
drwxrwxrwt 1 root     root     4.0K Feb 10 13:13 .
drwxr-xr-x 1 root     root     4.0K Feb 10 13:13 ..
drwxrwxrwt 2 root     root     4.0K Feb 10 13:13 .X11-unix
-r--r--r-- 1 root     root       11 Feb 10 13:13 .X99-lock
drwx------ 2 www-data www-data 4.0K Feb 10 13:13 QGIS3-XpIBVC
-rw-r--r-- 1 www-data www-data    0 Feb 10 13:13 QGIS3.BCjd13
drwx------ 2 root     root     4.0K Jan 18 06:56 crssync-tb3mKp
-rw-rw-r-- 1 www-data www-data    8 Feb 10 00:39 qgis-auth-pwd.txt
-rw-r--r-- 1 www-data www-data  44K Feb  9 18:08 qgis-auth.db
drwx------ 2 www-data www-data 4.0K Feb 10 13:13 qgis_mapserv.fcgi-htBxsD
drwx------ 2 www-data www-data 4.0K Feb 10 13:13 runtime-www-data
drwx------ 2 root     root     4.0K Jan 18 06:53 tmp4q9bqd_o

Also make sure to restart docker containers after changing this.
