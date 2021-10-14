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
git clone https://github.com/kartoza/osgs
cd osgs
```

## Fetching Docker Images

![Overview Diagram](../img/docker-images.png)



## Configuration

If you are going to use a self-signed certificate on a localhost (for testing):


```
make configure-ssl-self-signed
```

If you are going to use a letsencrypt signed certificate on a name host (for production):


```
make configure-letsencrypt-ssl
```
