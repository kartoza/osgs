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
# We comment this out in the assumption that you want to support only client
# to client communications and not client to server communications.
#PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
#PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

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

**Note:** Only complete this section if you want to support VPN client to client
communications instead of just client to server comms.


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

# Enable wireguard service in systemd

```
systemctl enable wg-quick@wg-osgs
systemctl start wg-quick@wg-osgs
systemctl status wg-quick@wg-osgs
```

A convenient way to do status checks is with the wg command. It will show all connected hosts.

```
wg
```

### Stopping Wireguard

```
systemctl stop wg-quick@wg-osgs
```

### Configure ssh


```
vim /etc/ssh/sshd_config
```

Changed these (add them to the end of the file):

```
# Changed by Tim to listen on wireguard interface only
ListenAddress 192.168.7.1
# Disabled by Tim
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
22/tcp                     ALLOW       192.168.6.0/24            
41194/udp (v6)             ALLOW       Anywhere (v6)             
```

Now go to https://github.com/kartoza/kartoza/wiki/WireGuard-Client-Configuration for client configs....


