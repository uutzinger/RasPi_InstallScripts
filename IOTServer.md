# Table of Contents

- [Table of Contents](#table-of-contents)
- [PI Server](#pi-server)
  * [Turn off WiFi and BT](#turn-off-wifi-and-bt)
  * [Boot from USB](#boot-from-usb)
  * [IOTStack](#iotstack)
    + [Configuration](#configuration)
    + [Acccessing Shell inside Docker Container](#acccessing-shell-inside-docker-container)
    + [Updating Containers](#updating-containers)
    + [Backing Up to Google Drive](#backing-up-to-google-drive)
  * [Configure Mosquitto](#configure-mosquitto)
  * [Configure influxDB](#configure-influxdb)
  * [Configure Grafana](#configure-grafana)
  * [motionEye](#motioneye)
  * [piHole, VPN and DHCP](#pihole--vpn-and-dhcp)
    + [Router OpenWRT](#router-openwrt)
    + [DHCP Static Configuration](#dhcp-static-configuration)
      - [DynDNS](#dyndns)
      - [openDNS update registered IP with openWRT](#opendns-update-registered-ip-with-openwrt)
      - [FireWall Port Forwards](#firewall-port-forwards)
    + [PiHole](#pihole)
    + [PiVPN](#pivpn)
      - [WireGuard](#wireguard)
      - [OpenVPN](#openvpn)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

# PI Server

## Turn off WiFi and BT

```sudo nano /boot/config.txt```

```
dtoverlay=disable-wifi
dtoverlay=disable-bt
```

## Boot from USB
This might only work on RasPi 4. This script follows Andreas Spiess youtbe video.  
Install latest Raspian on a SD Card using rufus or etcher.  
Install same image using rufus on SSD.  
Boot and
```
sudo apt update
sudo apt ugrade
sudo rpi-update
sudo reboot
```
Only the latest kernel can boot from USB. Usually you dont want to use rpi-update as the warning clearly state that this process is not intentended for regular users.  
```
sudo apt install rpi-eeprom
git clone https://github.com/raspberrypi/rpi-eeprom
sudo cp rpi-eeprom/firmware/beta/* /lib/firmware/raspberrypi/bootloader/beta
sudo cp rpi-eeprom/repi-eeprom-config /usr/bin
sudo cp rpi-eeprom/repi-eeprom-update /usr/bin
sudo nano /etc/default/rpi-eeprom-update
```
replace critical with beta,ctrl-x and y  
```
sudo rpi-eeprom-update -d -f /lib/firmware/raspberrypi/bootloader/beta/pieeprom-2020-06-15.bin
sudo reboot
```

After reboot is completed attach SSD to USB port.
```
vcgencmd bootloader_version
sudo mkdir /mnt/USBdisk
sudo mount /dev/sda1 /mnt/USBdisk
sudo cp /boot/*.elf /mnt/USBdisk
sudo cp /boot/*.dat /mnt/USBdisk
```

Reboot with SD card removed and SSD plugged in. Then
```
sudo apt update
sudo apt ugrade
```
and complete all the system installations you might want on your IOT server.

## IOTStack
https://github.com/gcgarner/IOTstack

```
git clone https://github.com/gcgarner/IOTstack.git ~/IOTstack
cd ~/IOTstack
./menu.sh
```
You will need Docker
Then we can select modules to be installed. 

* Portainer (docker management)
* Eclipse-Mosquitto (mqtt sensor messaging protocol)
* Grafana (data collection and display)
* Node-RED (automation)
* InfluxDB (timeseries database)

You will not want motionEye running on the IOT server.
motionEye with 3 1080p rtsp streams will take 75-100% CPU time.

```
cd ~/IOTstack
docker-composer up -d
```
### Accessing Docker Stacks

nodered https://localhost:1880  
influxdb https://localhost:8086  
grafana https://localhost:3000  
motionEye: https://localhost:8765  
portainer: https://localhost:9000
telegraf

### Usernames and Passwords
Keep track of the user names and passwords you create:

Portainer Web Access: admin  
Influxdb Administrator: pi  
Indluxdb User: mqtt  
Mosquitto User: mqtt  
Node-red: admin and user  

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
or
docker-compose down
 docker-compose pull
docker-compose up
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
autoconfig: yes (the follow the authentication requests in the browser)
tean drive: no
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

## Configure Portainer
Open portainer in webbrowser  
Set initial password

Select "endpoints" symbol and set PublicIP to the IP of the machine running docker  

### Forgotten Portainer Password
on the pi: ```sudo rm -r ./volumes/portainer``` start the stack and access portainer

## Configure Mosquitto
```
cd ~/IOTstack/services/mosquitto
nano mosquitto.conf
add allow_anonymous true
```

### Setting Password  
```
mosquitto_passwd -c /mosquitto/config/pwfile yourmosquittousername
```

### Change the mosquitto environment  
```
nano ~IOTstack/services/mosquitto/mosquitto.conf
```
Enable password file  

## Configure influxDB

Connect to portainer http://yourIOTstackIP:9000/
Select Containers then indluxdb
Start console
```
influx
CREATE DATABASE airquality
SHOW DATABASES
CREATE USER "pi" WITH PASSWORD 'yourpassword' WITH ALL PRIVILEGES
CREATE USER "mqtt" WITH PASSWORD 'anotherpassword' 
GRANT ALL ON airquality TO mqtt
```

### Change the indluxdb environment   
```
nano ~IOTstack/services/influxdb/influxdb.env
INFLUXDB_DB=airquality
INFLUXDB_HTTP_AUTH_ENABLE=true
INFLUXDB_
INFLUXDB_ADMIN_USER=pi
INFLUXDB_ADMIN_PASSORD=yourpassword
INFLUXDB_USER=mqtt
INFLUXDB_USER_PASSWORD=anotherpassword
```
## Configure Node-red

### To access the GPIO pins on the RasPi  
```
sudo apt-get install pigpio python-pigpio python3-pigpio
```
Edit ```/etc/rc.local``` add ```/usr/bin/pigpiod``` before ```exit 0``` 
Then execute
```sudo /usr/bin/pigpiod -l```

Open shell in portainer node-red stack and install the node:
```npm install node-red-node-pi-gpiod```

Now in the webinterface there should be a Raspberry Pi section in the node list.

### Enable Bluetooth Access
nano ~/IOTstack/services/nodered/service.yml  
add ```network_mode: "host"```  
as consquence http://influxdb:8086 will not become http://127.0.0.1:8086

### Running exec node on host RasPi
Check on https://github.com/gcgarner/IOTstack/wiki/Node-RED how to run script on the host from Node-red.

### Securing Node-red

You will need password hashes to setup authentication in the node-red settings file. You can create a password hash from the console in Node-red container with:  
```node -e "console.log(require('bcryptjs').hashSync(process.argv[1], 8));" anotherpassword```
This will produce something like: ```$2a$08$An17ZKyjuLSlF23ZBU9Y8exQ4HulyNvlu5BHg2gjKaGJIigmCrWc6``` which you will later copy into the settings file.

On RasPi
```
nano ~/IOTstack/volumes/nodered/data/settings.js
```
Follow instructions from https://nodered.org/docs/user-guide/runtime/securing-node-red

Creating https certificates is complicated and not attempted here.  

#### Securing Editor and Admin
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
        default: {
            permissions: "read" 
        }
    },
```
#### Securing Dashboard
At appropirate location the settings.js file enable something like this:
```
    httpNodeAuth: {user:"user",pass:"$2a$08$zZWtXTja0fB1pzD4sHCMyOCMYz2Z6dNbM6t$
```    

## Configure Grafana
The settings are located in ~IOTstack/services/grafana/grafana.env
default is admin/admin

## motionEye
Install motionEye. If you want to boot from USB SSD and store images on SSD you will want to install motionEye as listed on its github wiki https://github.com/ccrisan/motioneye/wiki/Install-On-Raspbian. 

Best is to run motionEye on Raspi 4 with ethernet connection to your router. When you install the system set eth0 IP and gateway accordingly. Also dont forget to enable SSH and/or VNC otherwise it will be difficult to manage the system remotly.

Point your webbrowser to https://IPofyourraspberry:8765
Username: admin pw: empty

add camera such as Dafang Hack camera at rtsp://192.168.x.y:8554/unicast

When you setup motion in the program, the red squares on the edited mask is where motion will not be considered.

## piHole, VPN and DHCP
piHole, VPN and DHCP run well on the same RasPi.
Often VPN and DHCP is configured on your router.

### Router OpenWRT
OpenWRT is thrid party WiFi router software. It comes preinstalled in Gl.inet WiFi routers.

Menu "LAN DHCP Server General Settings": set pool of IP numbers

To use pi-hole as DNS server: https://www.reddit.com/r/pihole/comments/av1qd4/setting_up_pihole_on_openwrt/

Menu "LAN DHCP Server Advanced Settings DHCP Options": 6,pihole_ip_number

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
Example service:

* myddns_ip4 
```
yourselectedname.mooo.com
custom http://freedns.afraid.org/dynamic/update.php?heregoesthelongnumber
```
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
  * WireGueard TCP/UDP 51580 tp pihole  
  * MQTT TCP/UDP to home assistant
    * 1883 default unencrypted
    * 8883 default encrypted
    * 1884
    * 8884   
  * also check custom rules for pi-hole here https://www.reddit.com/r/pihole/comments/av1qd4/setting_up_pihole_on_openwrt/

### PiHole
PiHole is a DNS filter that blocks access to advertising servers.  
For example:  
http://http://192.168.0.250/admin
login

DHCP server 2..128
upstream DNS server on pihole to openDNS
configure openDNS

### PiVPN
Install a custom VPN if your router does not have a VPN server builtin. You can combine pihole, dhcp and vpn on one raspi.  
Documentation:   
* https://www.pivpn.io/
* https://github.com/pivpn/pivpn

```
curl -L https://install.pivpn.io | bash
```
or
```
curl -L https://install.pivpn.io > VPNinstall.sh
chmod +x VPNinstall.sh
```

Configure script
* static ip pihole
* local user default

uninstall
```
pivpn -u
```
#### WireGuard
https://www.wireguard.com/
Settings  
port default 51820  
accept pi hole as DNS server  
public DNS entry utzinger.mooo.com  
unattended upgrades  

Create user profiles  
```
pivpn add
```

Importable settings are in configs. You can display QR codes using   
```
pivpn -qr
```
and import on the phone  

#### OpenVPN
https://openvpn.net/  
OpenVPN can run together with WireGuard but it requires manual setup. Best is to choose either wireguard or openVPN. OpenVPN is useful because there are VPN services you can purchase giving you local access to other countries and if you have OpenVPN already installed on your PC you can just add an other configuration file for the VPN to your home.
