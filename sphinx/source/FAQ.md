# Troubleshooting FAQ

The following sections provide answers to frequently asked questions about problems that you might encounter as you use the OSGS platform.


## How do I fix the 403 Forbidden Error when uploading folders to the qgis_projects folder in File Browser?

To fix this error, run the following command in the terminal of the server where you have set up OSGS.

```
sudo sh -c "cd /var/lib/docker/volumes/osgisstack_qgis_projects/; chown -R 1000:1000 _data; chmod o-w -R *; chmod ug+rw -R *;"
```
