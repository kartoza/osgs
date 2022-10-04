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

curl -s https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh | sudo bash
sudo apt-get update
sudo apt-get install crowdsec
sudo apt-get install crowdsec-firewall-bouncer-iptables
```

### Fail2ban

```
sudo apt install fail2ban
```
See: https://www.fail2ban.org/wiki/index.php/Main_Page 



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

gotop is a great console based dashboard for monitoring your server.

Ubuntu:

```
sudo apt-get install golang
cd ~
go install github.com/xxxserxxx/gotop/v4/cmd/gotop@latest
chmod +x go/bin/gotop
sudo cp go/bin/gotop /usr/local/bin/
```

Fedora:

```
sudo dnf install golang
cd ~
go install github.com/xxxserxxx/gotop/v4/cmd/gotop@latest
chmod +x go/bin/gotop
sudo cp go/bin/gotop /usr/local/bin/
```


Now just type `gotop` in your terminal whenever you want to see your terminal system monitor.



## Additional Software

### Docker

```
# Uninstall old versions of docker.
sudo apt-get remove docker docker-engine docker.io containerd runc
# Update the apt package index and install packages to allow apt to use a repository over HTTPS.
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg lsb-release
# Add Docker’s official GPG key.
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
# Set up the repository.
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# Update the apt package index, and install the latest version of Docker Engine, containerd, and Docker Compose.
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

```

If you don’t want to preface the `docker` command with `sudo`, create a Unix group called `docker` and add users to it using the instructions [here](https://docs.docker.com/engine/install/linux-postinstall/).


### Git, rpl, pwgen, Make and openssl

Needed for checking out our docker project and running the various make
commands we provide.

```
sudo apt install git make rpl pwgen openssl apache2-utils
```

or fedora:
```
sudo dnf install openssl rpl git pwgen
```

## Firewall

If you are using ufw, open port 80 and 443 as minimum. After the initial setup, you
can again close port 80.

```
sudo ufw allow 80
sudo ufw allow 443
```

### Move on to OSGS Installation

Ok we are ready to install OSGS! Go ahead to the [initial configuration page](initial_configuration.md) now.

