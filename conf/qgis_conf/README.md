The `auth-db/qgis-auth-pwd.txt` file contains the master password to unlock the `auth-db/qgis-auth.db` file. The `qgis-auth.db` file is created in QGIS and set with a master key/password in QGIS. Paste the master password in the  `qgis-auth-pwd.txt` file   for QGIS server to read at run time.

Make sure to copy over the `qgis-auth.db` file whenever you change it e.g.
`sudo cp ~/.local/share/QGIS/QGIS3/profiles/Smallholding/qgis-auth.db conf/qgis_conf/auth-db/`
Or more conveniently upload the `qgis-auth.db` file into the `qgis_conf/auth-db/` folder in the File Browser web file manager.

An example of how to do the above steps is provided in the [Authentication of Postgres using a pg_service file and a qgis-auth.db file workflow](../../sphinx/source/workflows/authentication-using-pg_service-and-qgisauthdb.md).

These files must be writable by the nginx user in the container. See below:
```
sudo chown 33:33 conf/qgis_conf/auth-db/qgis*
docker-compose exec qgis-server ls -lah /tmp
```

Also make sure to restart docker containers after changing this using `make restart`.
