# Initial Configuration

Note for the unprivileged user throughout here, we use the user name ‘timlinux’
in various examples - you should substitute this with your own user.

## User Group

Add yourself to the user group of docker so you don't need to sudo docker
commands.

```
sudo usermod -a -G docker timlinux
```

Then log out and in again to assume the upgraded permissions.

## Project Checkout

```
cd /home
sudo mkdir web
sudo chown timlinux.timlinux web
cd web
git clone https://github.com/kartoza/OpenSource-GIS-Stack
cd OpenSource-GIS-Stack
```

## Fetching Docker Images

![Overview Diagram](img/docker-images.png)



## Configuration

Copy the .env boilerplate file and then adjust any settings in it as needed.

```
cp .env.example .env
```

Replace terms that should be unique for your installation:

```
rpl example.org geoservices.govt.lc .env
rpl example.org geoservices.govt.lc nginx_conf/nginx.conf 
```


