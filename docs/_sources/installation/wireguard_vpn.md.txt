# Wireguard VPN

You can further enhance the security of communications between clients and the OSGS
server by configuring a Wireguard VPN. The goal here will be to tunnel
all non-web based requests to the server through the VPN. This can include 
Postgres and Mosquitto connections, and others if they are published on a port. You can
also move the actual management over SSH of the OSGS server itself into the VPN
so that the only public facing ports of the server are https and the vpn service.

In this document we describe a scenario where the OSGS server is also a VPN server,
but there are other potential scenarios such as using a second server and the VPN server
and the OSGS as a VPN client.

## Setting up the VPN Server

**Note:** There is NO public facing ssh port open on this host, you can only access ssh via the VPN. So for management when the VPN is down or you don't have your client set up yet, use your hosting provider's virtual console.


**Note 2:** Use these instructions at your own risk. Misconfiguring your server could
lock you out of it permanently, so proceed with caution!

**Note 3:** We assume you have already carried out the [server_preparation](server_preparation.md) steps before following this guide.

### Log in to your server

```
ssh yourhost
```

or use the hosting provider's console to log in if you do not already have SSH access.



**Note:** When logging in take note that the keyboard layout in the console is US if you are using hetzner for your provider, so if you have a different layout e.g. Portuguese you need to type as if you are on a US keyboard.

###  Initial Install

Assuming an ubuntu based server here...

```
sudo su -
apt update
apt upgrade
apt install wireguard
cd /etc/wireguard/
umask 077; wg genkey | tee privatekey | wg pubkey > publickey
ls -l privatekey publickey
```

Should show:

```
-rw------- 1 root root 45 Oct 31 23:33 privatekey
-rw------- 1 root root 45 Oct 31 23:33 publickey
```

Make a note of the private key and public key:

```
cat privatekey
cat publickey
```

Now configure the conf file:

```
vim /etc/wireguard/wg-osgs.conf
```

**Note:** You can run multiple Wireguard VPN clients and servers on the same
host so we include osgs in the conf file name to make it clear what this VPN is
to be used for.

Add this content:

```

## Set Up WireGuard VPN on Ubuntu By Editing/Creating wg0.conf File ##
[Interface]
## My VPN server private IP address ##
Address = 192.168.7.1/24
 
## My VPN server port ##
ListenPort = 41194
 
## VPN server's private key i.e. /etc/wireguard/privatekey ##
PrivateKey = xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Also enable NAT routing of all traffic through the VPN
# This is needed for VPN clients to be able to conenct to each other's services and ports
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

##
## All osgs peers (clients) should be added here
## 

[Peer]
## Client VPN public key ##
PublicKey = XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 
## client VPN IP address (note  the /32 subnet) ##
AllowedIPs = 192.168.7.2/32

```


### Server Networking and Firewall Configuration

**Note:** Only do this for cases when you want to support peer to peer access in the VPN. In
normal circumstances it is better to have an architecture where peers can talk to the server
only and not to each other.

This section copied from https://linuxize.com/post/how-to-set-up-wireguard-vpn-on-ubuntu-20-04/#server-networking-and-firewall-configuration

IP forwarding must be enabled for NAT to work. Open the /etc/sysctl.conf file and add or uncomment the following line:
```
sudo vim /etc/sysctl.conf
```
Add this line:

```
net.ipv4.ip_forward=1
```

Save the file and apply the change:

```
sudo sysctl -p
```
Should show:

```
net.ipv4.ip_forward = 1
```

### Firewall config


```
ufw allow 41194/udp
ufw status
```

Should show:

```
Status: inactive
```

Allow ssh connections originating from within the VPN

```
ufw allow from 192.168.7.0/24 to any port 22 proto tcp
```

For the same for each port that you want to be accessible only via the VPN e.g.

```
ufw allow from 192.168.7.0/24 to any port 5432 proto tcp
ufw allow from 192.168.7.0/24 to any port 1883 proto tcp
```

Would allow Postgres connections (5432) and Mosquitto (1883) over the VPN only.


On my test system the set of final UFW rules looks like this:

```
root@osgs:/etc/wireguard# ufw status numbered
Status: active

     To                         Action      From
     --                         ------      ----
[ 1] 80                         ALLOW IN    Anywhere                  
[ 2] 443                        ALLOW IN    Anywhere                  
[ 3] 41194/udp                  ALLOW IN    Anywhere                  
[ 4] 22/tcp                     ALLOW IN    192.168.7.0/24            
[ 5] 5432/tcp                   ALLOW IN    192.168.7.0/24            
[ 6] 1883/tcp                   ALLOW IN    192.168.7.0/24 
```

i.e. only web and vpn traffic are publicly accessible and other services and ports need to
be accessed from within the VPN.


### Enable wireguard service in systemd

```
systemctl enable wg-quick@wg-osgs
systemctl start wg-quick@wg-osgs
systemctl status wg-quick@wg-osgs
```

A convenient way to do status checks is with the wg command. It will show all connected hosts.

```
wg
```

## Connecting with your client


For each client you need to create public/private keys on the client and a [peer] entry on the server, then restart client and server wireguard instances.

### Install Ubuntu

```
apt install wireguard
sudo apt install openresolv
sudo apt install resolvconf
```

or (for fedora):

```
dnf install wireguard wireguard-tools
```

### Configure client keys

```
cd /etc/wireguard/
umask 077; wg genkey | tee privatekey | wg pubkey > publickey
ls -l privatekey publickey
cat publickey
cat privatekey
```

### Add client to the server

Log in to the server:

```
ssh vpn
sudo vim /etc/wireguard/wg-osgs.conf
```

**Note:** Steps below already partly done for the first host if you have
followed the server setup notes above. You need to repeat this process
for each host that needs to connect to the server via VPN.

Now add a new peer, using your public key from your client machine. 
Make sure to allocate a unique IP for it:

```
[Peer]
## Desktop/client VPN public key ##
PublicKey = xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

## client VPN IP address (note  the /32 subnet) ##
AllowedIPs = 192.168.7.2/32

```

# Configure on the client

sudo vim /etc/wireguard/wg-osgs.conf

```
[Interface]
## This Desktop/client's private key ##
PrivateKey = xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=

## Client ip address ##

# Replace .2 with your allocated ip address!
Address = 192.168.7.2/24


[Peer]
## Server public key ##
PublicKey = XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

## set ACL ##
AllowedIPs = 192.168.7.0/24

## Server's public IPv4/IPv6 address and port ##
Endpoint = XX.YY.ZZ.AA:41194

##  Key connection alive ##
PersistentKeepalive = 15
```

### Enable and start wireguard

```
sudo systemctl enable wg-quick@wg-osgs
sudo systemctl start wg-quick@wg-osgs
sudo systemctl status wg-quick@wg-osgs
```

To bring it down again in the future you can do:

```
sudo wg-quick down wg-osgs
```


Or to restart:

```
sudo systemctl restart wg-quick@wg-osgs
```

And to check status:

```
sudo wg
```

Which should show something like this:

```
interface: wg-osgs
  public key: Kimironw1r21/RH3jbd97HTwtXjlUJFJAOXmBKuB+hg=
  private key: (hidden)
  listening port: 58616

peer: IdLyVLa0htZ82EKYWM9sXjB5ST15O3U5yYbNW+3XOQY=
  endpoint: XX.YY.ZZ.AA:41194
  allowed ips: 192.168.7.0/24
  transfer: 0 B received, 296 B sent
  persistent keepalive: every 15 seconds
```


# Allow incoming SSH only from the VPN

```
ufw allow from 192.168.6.0/24 to any port 22 proto tcp
```
Also update your sshd to listen only on the wg interface

```
# Changed by Tim to listen on wireguard interface only
# Change XXX to your IP
ListenAddress 192.168.7.XXX
# Disabled by Tim
PermitRootLogin no
PasswordAuthentication no
```



























## Further configuration notes

**Note:** Only once you have verified that you can connect with a client.


### Stopping Wireguard

```
systemctl stop wg-quick@wg-osgs
```

### Configure ssh

For additional security you can set the SSH listenaddress to your
VPN network so that it will not even respond to conneciton
attempts from the wider internet.

```
vim /etc/ssh/sshd_config
```

Changed these (add them to the end of the file):

```
# Changed by Tim to listen on wireguard interface only
ListenAddress 192.168.7.1
# Disabled by Tim (should already be done in server_preparation step)
PermitRootLogin no
PasswordAuthentication no
```

Again, check carefully at the end of the file, some providers add a ``PasswordAuthentication yes`` to the bottom of the file which you want to override.

### Enable the VPN

```
systemctl enable wg-quick@wg-osgs
```

### Enable the firewall

Now enable the firewall (you probably want to be logged in at the service provider's virtual console here as your WAN connection will be dropped until you access via VPN).

```
ufw enable
ufw status
systemctl restart sshd
```
Should show:

```
Status: active

To                         Action      From
--                         ------      ----
41194/udp                  ALLOW       Anywhere                  
22/tcp                     ALLOW       192.168.7.0/24            
41194/udp (v6)             ALLOW       Anywhere (v6)             
```

Now go to https://github.com/kartoza/kartoza/wiki/WireGuard-Client-Configuration for client configs....


