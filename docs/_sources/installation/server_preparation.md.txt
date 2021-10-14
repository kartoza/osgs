# Preparing the server

## Basic Security

### Unattended upgrades

This will automatically install only security fixes on a continual basis on your server.

```
sudo apt install unattended-upgrades
```

### ssh

Disable password authentication for SSH

```
sudo vim /etc/ssh/sshd_config
```

Set this:

```
PasswordAuthentication no
Then do
sudo systemctl restart sshd.service
```

### Crowdsec

https://crowdsec.net/ 


```
wget -qO - https://s3-eu-west-1.amazonaws.com/crowdsec.debian.pragmatic/crowdsec.asc |sudo apt-key add - && echo "deb https://s3-eu-west-1.amazonaws.com/crowdsec.debian.pragmatic/$(lsb_release -cs) $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/crowdsec.list > /dev/null;
sudo apt-get update
sudo apt-get install crowdsec
```

### Fail2ban

```
sudo apt install fail2ban
https://www.fail2ban.org/wiki/index.php/Main_Page 
```


### Firewall

```
sudo ufw allow ssh
sudo ufw enable
sudo ufw status
```

Should show something like this:

```
Status: active

To             Action   From
--             ------   ----
22/tcp           ALLOW    Anywhere         
22/tcp (v6)        ALLOW    Anywhere (v6)
```

We will open more ports as they are needed.

### Status monitoring

bpytop is a great console based dashboard for monitoring your server.

```
sudo snap install bpytop
```

## Additional Software

### Docker

```
sudo apt install docker.io
sudo apt-get -y install python3-pip
sudo pip3 install docker-compose
```

### Git, rpl, pwgen, Make and openssl

Needed for checking out our docker project and running the various make
commands we provide.

```
sudo apt install git make rpl pwgen openssl
```

or fedora:
```
sudo dnf install openssl rpl git pwgen
```

