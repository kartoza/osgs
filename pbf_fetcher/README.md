This directory will create a storage only docker image
that contains the PBF that will be used to bootstrap
the Docker OSM live mirror of the specified area.

Either copy the Dockerfile.example to Dockerfile and
then replace the PBF_URL with a valid link to a 
PBF file (typically from GeoFabrik), or run:

```
make configure
```

The above command will take care of copying the 
example, ask you for the PBF url and then build the 
docker image.
