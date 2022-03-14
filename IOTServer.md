# Table of Contents

- [Table of Contents](#table-of-contents)
- [PI Server](#pi-server)
  * [Turn off WiFi and BT](#turn-off-wifi-and-bt)
  * [Boot from USB](#boot-from-usb)
  * [IOTStack](#iotstack)
    + [Accessing Docker Stacks](#accessing-docker-stacks)
    + [Usernames and Passwords](#usernames-and-passwords)
    + [Acccessing Shell inside a Docker Container](#acccessing-shell-inside-a-docker-container)
    + [Updating Containers](#updating-containers)
    + [Backing Up to Google Drive](#backing-up-to-google-drive)
- [Configuring IOT Server](#configuring-iot-server)
  * [Resources for setting up IOT Server](#resources-for-setting-up-iot-server)
  * [Configure Portainer](#configure-portainer)
    + [Forgotten Portainer Password](#forgotten-portainer-password)
  * [Configure Mosquitto](#configure-mosquitto)
    + [Setting Password](#setting-password)
  * [Configure influxDB port:8086](#configure-influxdb-port-8086)
    + [Change the indluxdb environment](#change-the-indluxdb-environment)
  * [Configure Node-RED port 1880](#configure-node-red-port-1880)
    + [To access the GPIO pins on the RasPi](#to-access-the-gpio-pins-on-the-raspi)
    + [Enable Bluetooth Access](#enable-bluetooth-access)
    + [Running exec node on host RasPi](#running-exec-node-on-host-raspi)
    + [Securing Node-red](#securing-node-red)
  * [Configure Grafana](#configure-grafana)
    + [Set Password](#set-password)
  * [Configure wireguard](#configure-wireguard)
- [Other IOT Webservices](#other-iot-webservices)
  * [motionEye](#motioneye)
  * [piHole, VPN and DHCP (without IOT server and docker)](#pihole--vpn-and-dhcp--without-iot-server-and-docker-)
    + [Router Firmware: OpenWRT](#router-firmware--openwrt)
    + [Force DNS Lookup to PiHole](#force-dns-lookup-to-pihole)
    + [DHCP Static Configuration](#dhcp-static-configuration)
      - [DynDNS](#dyndns)
      - [openDNS update registered IP with openWRT](#opendns-update-registered-ip-with-openwrt)
      - [FireWall Port Forwards](#firewall-port-forwards)
    + [PiHole](#pihole)
    + [PiVPN](#pivpn)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

# PI Server

## Turn off WiFi and BT

```
sudo nano /boot/config.txt
```

```
dtoverlay=disable-wifi
dtoverlay=disable-bt
```

## Boot from USB
This might only work on RasPi 4.  
Install latest Raspian on a SD Card using rufus or etcher.  

Boot and:
```
sudo apt update
sudo apt full-ugrade
sudo rpi-update
sudo reboot
```

```
sudo rpi-eeprom-update -d -a
sudo reboot
```
Copy the content of the SDCard to the USB driver using SD Card Copier in Raspian.

Then configure USB boot:
```
sudo raspi-config
```
In "advanced" you can enable boot device and firmware options.

----
## IOTStack

```
sudo apt install -y curl
```

Install with:
```
curl -fsSL https://raw.githubusercontent.com/SensorsIot/IOTstack/master/install.sh |   bash
cd ~/IOTstack
./menu.sh
```

You will need Docker installed first from the mensu.sh.   

Then we can select modules to be installed:

Select "Build Stack" in menu.sh

* Portainer-ce (docker management)
* Eclipse-Mosquitto (mqtt sensor messaging protocol)
* Grafana (data collection and display)
* Node-RED (automation)
* InfluxDB (timeseries database)

You will not want motionEye running on the IOT server.  
motionEye with three 1080p rtsp streams will consume 75-100% CPU time.

Recommended system patches:

```
sudo bash -c '[ $(egrep -c "^allowinterfaces eth0,wlan0" /etc/dhcpcd.conf) -eq 0 ] && echo "allowinterfaces eth0,wlan0" >> /etc/dhcpcd.conf'
sudo reboot
```

Bring up docker:
```
cd ~/IOTstack
docker-compose up -d
```

You can check the logs:
```
docker logs wireguard
````

### Accessing Docker Stacks

nodered https://localhost:1880  
influxdb https://localhost:8086  
grafana https://localhost:3000  
motionEye: https://localhost:8765  
portainer: https://localhost:9000   
telegraf: 

### Usernames and Passwords
Keep track of the user names and passwords you create:

Portainer Web Access: admin  
Influxdb Administrator: pi  
Indluxdb User: mqtt  
Mosquitto User: mqtt  
Node-red: admin and user 
Grafana: admin

### Acccessing Shell inside a Docker Container
Example influxdb:  
```  
docker exec -it influxdb /bin/bash
influx
```
or
```
~/IOTStack/services/influxdb/terminal.sh
```
or  
open portainer influxdb container  
click on >_console  
select /bin/sh  

### Updating Containers
```
./scripts/update.sh
```
or
```
docker-compose down
docker-compose pull
docker-compose up -d
```
### Backing Up to Google Drive

Install rclone:  
```
curl https://rclone.org/install.sh | sudo bash
```
```
rclone config

name:gdrive
type: Google Drive
client id: empty
client secret: empty
access to files created by rdrive only
root folder id: empty
sercvice account files: empty
advanced config: no
autoconfig: yes (then follow the authentication requests in the browser)
team drive: no
ok: yes
```

Edit the backup script to set backup destination folder, e.g. gdrive:/IOTstack/whereyouwantittogo
```
cd ~/IOTstack
sudo touch backups/rclone
nano ~/IOTstack/scripts/docker_backup.sh
```
Enable backup script
```
crontab -e
* 23 * * * sudo ~/IOTstack/scripts/docker_backup.sh >/dev/null 2>&1
```

# Configuring IOT Server

## Resources for setting up IOT Server

Documentation is:
* https://sensorsiot.github.io/IOTstack/Containers/Portainer-ce/   

Examples are:  
* https://griddb.net/en/blog/monitoring-temperature-sensor-data-with-an-arduino-based-plc-mqtt-node-red-griddb-and-grafana/
* https://www.sensorsiot.org/node-red-infuxdb-grafana-installation/

## Configure Portainer
Open portainer in webbrowser:  ```https://yourIOTstackIP:9000```  
Set initial password.
Select Home and local container  
Select "endpoints" symbol and set PublicIP of local container to the IP of the machine running docker which is autopopulated.

### Forgotten Portainer Password
on the pi: ```sudo rm -r ./volumes/portainer``` start the stack and access portainer

## Configure Mosquitto

There is documentation at https://sensorsiot.github.io/IOTstack/Containers/Mosquitto/.

In general the files of interest are:
* docker-compose.yml ⇒ ~/IOTstack/docker-compose.yml
* mosquitto.conf ⇒ ~/IOTstack/services/mosquitto/mosquitto.conf
* mosquitto.log ⇒ ~/IOTstack/volumes/mosquitto/log/mosquitto.log
* service.yml ⇒ ~/IOTstack/.templates/mosquitto/service.yml
* volumes/mosquitto ⇒ ~/IOTstack/volumes/mosquitto/

```
cd ~/IOTstack/services/mosquitto
nano mosquitto.conf
allow_anonymous true
```

If you plan to use passwords
```
passwordfile /mosquitto/pwfile/pwfile
allow_anonymous false
```
Mosquitto port is by default 1883.

### Setting Password  
Mosquitto runs without passoword by default but you might want to change that. 

If you use a username and password you will need to add ```mqttClient.setCredentials(username, password)``` in your esp8266 sketch to connect to the mqtt broker.

execute 
```
~/IOTstack/services/mosquitto/terminal.sh
```
enter following command with substituted username:
```
mosquitto_passwd -c /mosquitto/pwfile/pwfile yourmosquittousername
```
enter the password and ```exit``` the shell

## Configure influxDB port:8086

Start console ``` run ./services/influxdb/terminal.sh ```

```
influx
CREATE DATABASE airquality
SHOW DATABASES
CREATE USER "pi" WITH PASSWORD 'yourpassword' WITH ALL PRIVILEGES
CREATE USER "mqtt" WITH PASSWORD 'anotherpassword' 
GRANT ALL ON airquality TO mqtt
```

### Change the indluxdb environment   
Influxdb environment is stored in ```~/IOTstack/services/influxdb/influxdb.env```

```
nano ~/IOTstack/services/influxdb/influxdb.env
# add this one to beginning
INFLUXDB_DB=airquality
# enable this 
INFLUXDB_HTTP_AUTH_ENABLE=true
# set users
INFLUX_USERNAME=admin
INFLUX_PASSWORD=anotherpassword
```

## Configure Node-RED port 1880

You might want to consider enabling your GPIO pins and bluetoot to become accessible inside Node-RED container.

### To access the GPIO pins on the RasPi  
```
sudo apt-get install pigpio python-pigpio python3-pigpio
```
Edit ```/etc/rc.local``` and add 
```
/usr/bin/pigpiod
``` 
before ```exit 0```  
Then execute
```
sudo /usr/bin/pigpiod -l
```

Open shell in portainer node-red stack and install the node:
```
npm install node-red-node-pi-gpiod
```

Now in the webinterface there should be a Raspberry Pi section in the node list.

### Enable Bluetooth Access
It might be better to run bluetooth to mqtt server (esprino hub)

edit ```~/IOTstack/services/nodered/service.yml```  
add 
```
network_mode: "host"
```  
as consquence http://influxdb:8086 will not become http://127.0.0.1:8086

### Running exec node on host RasPi
Check on https://github.com/gcgarner/IOTstack/wiki/Node-RED how to run script on the host from Node-red.

### Securing Node-red

Resources: https://nodered.org/docs/user-guide/runtime/securing-node-red

Start a terminal in the node-red contrainer: ```./services/nodered/terminal.sh ```  
You will need password hashes to setup authentication in the node-red settings file. You can create a password hash from the console in Node-red container with:   
```
node -e "console.log(require('bcryptjs').hashSync(process.argv[1], 8));" anotherpassword
```
This will produce something like: ```$2a$08$An17ZKyjuLSlF23ZBU9Y8exQ4HulyNvlu5BHg2gjKaGJIigmCrWc6``` which you will later copy into the settings file.

Make two password hashes, one for the user "admin" and one for "user".

Edit ```~/IOTstack/volumes/nodered/data/settings.js ```   
At appropriate location in the settings.js file enable something like this:
```
   adminAuth: {
        type: "credentials",
        users: [
            {
                username: "admin",
                password: "here goes the hash you created with node-e... command above",
                permissions: "*"
            },
            {
                username: "user",
                password: "here goes the hash you created with node-e... command above",
                permissions: "read"
            }
        ]
    },
```
Enable:
```
    httpNodeAuth: {user:"user",pass:"the hash that goes with user"
```    
Creating https certificates is complicated and not attempted here.  

## Configure Grafana
grafana https://IOTstackIP:3000  

The settings are located in ```~/IOTstack/services/grafana/grafana.env```
default is admin/admin

Edit environment file and change   
```#TZ=Africa/Johannesburg```
Remove ```#``` and use your time zone, e.g. America/Phoenix (https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)

### Set Password
In ```~/IOTstack/services/grafana/grafana.env``` change 
```GF_SECURITY_ADMIN_PASSWORD=yourpassword``` or use firsttime browser logon which forces you to select new password.   

You can reset password with:  
```
docker exec grafana grafana-cli --homepath "/usr/share/grafana" admin reset-admin-password "admin"
```
Then access the web console https://IOTstackIP:3000 and it will ask for new password.

## Configure wireguard

This is not Tested, I run wireguard and network service on separate raspberry pi hardware. Installation is described under other IOT services.

Create compose-override.yml in IOTStack folder:

```
cd ~/IOTStack
sudo nano compose-override.yml
```
```
services:
  wireguard:
    environment:
      - PUID=1000                                       
      - PGID=1000                                     
      - TZ=America/Phoenix
      - SERVERURL=your-dynamic-dns-name.something.com
      - SERVERPORT=51820
      - PEERS=5 #optional                       
      - PEERDNS=auto #optional
      - INTERNAL_SUBNET=100.64.0.0/24 #optional
    ports:
      - 51820:51820/udp
```

On the router make sure port 51820 TCP/UDP is forwarded to the IOT device.

  * WireGueard TCP/UDP 51580 tp pihole

Check that connections work:

```
sudo nmap -sU -p 51820 192.168.11.250
sudo nmap -sU -p 51820 <your-dynamic-dns-account>.something.com
```

Now copy the configuration to your client computer:   
```
scp pi@<Rpi-ip-address>:/home/pi/IOTStack/services/wireguard/config/peer1/peer1.conf ~/peer1.conf
```
and import it into the wireguard client.

---
# Other IOT Webservices

## piHole, VPN and DHCP (without IOT server and docker)
piHole, VPN and DHCP run well on the same RasPi.  

Running VPN on your router might not have as much throughput as on external device.

### Router Firmware: OpenWRT
OpenWRT is thrid party WiFi router software. It comes preinstalled in Gl.inet WiFi routers.

In OpenWRT DHCP set pool of IP numbers. If you used DHCP server from piHole the DHCP IP range on the router and piHole can not overlap.

*Network->Interfaces-Lan->Edit->DHCPServer->GeneralSettings:* Start and Number of leases to be outside of PiHole Server range  

*Network->Interfaces-Lan->Edit->DHCPServer->AdvancedSettings: 6, 192.168.x.numberofpihole*

To use pi-hole as DNS server: https://www.reddit.com/r/pihole/comments/av1qd4/setting_up_pihole_on_openwrt/

In OpenWRT menu "Interfaces, LAN, DHCP Server Advanced Settings DHCP Options": 6,pihole_ip_number

### Force DNS Lookup to PiHole

Network, Firewall, Custom Rules
Redirect DNS requests to go through router
```
iptables -t nat -A PREROUTING -i br-lan ! -s 192.168.yourPiHole -p udp --dport 53 -j REDIRECT
iptables -t nat -A PREROUTING -i br-lan ! -s 192.168.yourPiHole -p tcp --dport 53 -j REDIRECT

iptables -t nat -A PREROUTING -i eth0.2 -p udp --dport 53 -j DNAT --to-destination 192.168.yourPiHole
iptables -t nat -A PREROUTING -i eth0.2 -p tcp --dport 53 -j DNAT --to-destination 192.168.yourPiHole
```

### DHCP Static Configuration
Example home cofiguration:  
192.168.0.200 camera  
192.168.0.201 camera  
192.168.0.202 camera  
192.168.0.250 Pihole (for DNS filterting)  
192.168.0.251 HASS (Home Assistant Server)  
192.168.0.252 IOT (IOT stack) wireless  
192.168.0.253 IOT wired  
192.168.0.254 motionEye (Camera server and recorder)  

#### DynDNS
In most cases you will want to have the IP number of your router accessible from the internet.
Example service in OpenWRT:

* myddns_ip4 
```
enable
yourselectedname.mooo.com
custom http://freedns.afraid.org/dynamic/update.php?heregoesthelongnumber
```
the link above is displayed on afraid.org
dynamic dns -> direct URL -> in the address bar

* opendns 
```
yourusername pw 
use HTTP secure
```
#### openDNS update registered IP with openWRT
Register your ddns account with https://www.dnsomatic.com/  
Then configure ddns update according this link  
https://www.leowkahman.com/2016/01/21/configuring-openwrt-and-opendns-to-log-all-dns-lookups/

Lookup Hostname: dnsomatic.com   
enable  
custom  
https://[USERNAME]:[PASSWORD]@updates.dnsomatic.com/nic/update?hostname=[DOMAIN]&myip=[IP]&wildcard=NOCHG&mx=NOCHG&backmx=NOCHG  
Domain: The home 'network' name you set in dnsomatic, its a single word  
Username: your username for opendns and dns o matic  
Passowrd: as in opendns and dns o matic  

#### FireWall Port Forwards
  * OpenVPN UDP/TCP 1194 to pihole  
  * OpenVPNHPPTS TCP 443 to 1194 pihole  
  * WireGueard UDP 51820 tp pihole  
  * MQTT TCP/UDP to home assistant
    * 1883 default unencrypted
    * 8883 default encrypted (not used)
    * 1884 (not used)
    * 8884 (not used)
  * also check custom rules for pi-hole here https://www.reddit.com/r/pihole/comments/av1qd4/setting_up_pihole_on_openwrt/

### PiHole
PiHole is a DNS filter that blocks access to advertising servers.  

Install pi-hole:
```
wget -O basic-install.sh https://install.pi-hole.net
sudo bash basic-install.sh
```
Keep track of the autogenerated password or set a new password with
```
pihole -a -p
```

Open the interface:    
http://192.168.0.250/admin  
login with password

Enable the DHCP server set the range to e.g. 2..128 but not overlapping the range on your router DHCP.

*PiHole Admin Interface ->Settings->DHCP*  
Set Range with From To  
Enable DHCP Server   

upstream DNS server on pihole to openDNS
configure openDNS

### PiVPN
Install a custom VPN if your router does not have a VPN server builtin. You can combine pihole, dhcp and vpn on one raspi.  
Documentation:   
* https://www.pivpn.io/
* https://github.com/pivpn/pivpn

First install wireguard from repository, then setup with pivpn.

```
sudo apt-get install wireguard
curl -L https://install.pivpn.io | bash
```
or
```
curl -L https://install.pivpn.io > VPNinstall.sh
chmod +x VPNinstall.sh
```

Use the default settings in the configure script plus
* wireguard enable
* port default is 51820
* static ip you reserved on router for the server
* local user default 
* acccept piHole as DNS server for wireguard clients
* dynamicDNS entry of your server e.g. what you setup on afraid.org for your router such as something.mooo.com. dynDNS is usually setup on the router.
* enable unattended upgrades

Make sure there is connection to the wireguard port. You can install nmap on Windows or use unix computer and execute:

```
sudo nmap -sU -p 51820 192.168.11.250
sudo nmap -sU -p 51820 <your-dynamic-dns-account>.something.com
```
Port will need to be listed as open.

Create user profiles  
```
pivpn add
```

Importable settings are in configs. You can display QR codes using   
```
pivpn -qr
```
and import on the phone  

uninstall
```
pivpn -u
```
