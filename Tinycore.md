# Raspberry Pi with Tinycore

Tiny Core Linux is minimalistic operating system booting from small partition into RAM. Wireless, bluetooth, GPIO and camera are extras and need to be loaded from user partition. 

We will create a Raspberry Pi Zero W based micro controller that boots fast, can connect to bluetooth control pad, interface with GPIO, motor controller (USB serial) and be maintained through wireless ssh or serial terminal.

Tiny Core image for Raspberry is installed the same way as Raspian and provides rudimentary headless terminal. It includes wired ethernet but no wireless. Unlike with Raspian you can not just install piCore on the Raspberry Pi 4 and then swap the SD Card to a Raspberry Pi Zero.

Because Tiny Core runs in RAM, additional steps are needed for persistent extensions. They are installed on user partition which first needs to be manually extended. Then extensions need to be loaded through startup list or manually. Services on programs can be automatically started by extending the boot script. Configuration files are stored in compressed user data file and are loaded into RAM at boot time.

The more extensions are present and needed the slower the boot. The bare bone system with eth0 has a command prompt in 10 seconds after power on and 5 seconds after splash screen.

TinyCore has useful *forum* but *you should not bother to register*. The registration process has multiple steps for human versus bot detection and the registration software is flawed so that even with 100s of retries you can not pass. It takes about 5-10 retries and waiting to pass lockout period to get passed the first step. The second step you can not pass even if you take the odds (1 out of 8x8x8) of trying over and over again hoping that just by chance you will be presented with the correct orientation of tiles. There are suggestions on how to attempt modifying the html code in your browser, but you will be frustrated by the server letting you know that you were trying to hack the process. Neither Chrome, Edge and Firefox will solve the issue. 

https://iotbytes.wordpress.com/?s=Tiny+Core


## SD card
1) Download [Stable Release for Raspberry Pi](https://distro.ibiblio.org/tinycorelinux/ports.html)
2) Extract the img file
3) Use Raspberry Pi Imager and custom image option to burn the image file onto SD Card.

## Wifi & Bluetooth Extensions
Installing WiFi support without a wired internet connection is tricky. Its worth obtaining an USB to Ethernet dongle as well as an USB hub for Raspberry Pi Zero and let the extension server decide on the particular file versions you need:

```
tce-load -wi wifi.tcx
tce-load -wi firmware-rpi-wifi.tcz
```
This should automatically obtain the dependencies.

When you inspect the ```config.txt``` on the boot partition you can recognize which kernel the hardware is used:

| Raspberry| Kernel | Wifi Driver | Bluetooth Driver 
| --- | --- | --- | --- |
| Pi0W | 5.10.77.PiCore | wireless-5.10.77-piCore.tcz | bluetooth-5.10.77-piCore.tcz |
| Pi02W |5.10.77.PiCore-v7 | wireless-5.10.77-piCore-v7.tcz | bluetooth-5.10.77-piCore-v7.tcz |
| Pi3 | 5.10.77.PiCore-v7 | wireless-5.10.77-piCore-v7.tcz | bluetooth-5.10.77-piCore-v7.tcz |
| Pi4 | 5.10.77.PiCore-v7l| wireless-5.10.77-piCore-v7l.tcz | bluetooth-5.10.77-piCore-v7l.tcz

Note its version 7 letter l and not number one.

Based on the Kernel you select your download site:

| Version | Archive Site |
|--|--|
| old | http://www.tinycorelinux.net/13.x/armv6/tcz/ |
| v7 | http://www.tinycorelinux.net/13.x/armv7/tcz/ |
| v7l | http://www.tinycorelinux.net/13.x/armv7l/tcz/ |

4) From appropriate site above you can download

```firmware-rpi-wifi``` as well as ```wifi``` with the extensions ```*.tcz```, ```*.tcz.dep```, ```*.md5.txt``` 

and the items listed in http://tinycorelinux.net/13.x/armXXX/tcz/wifi.tcz.tree using same extensions (XXX being v7 or v7l or empty).

This is:
- firmware-rpi-wifi.tcz
- wifi.tcz
- wireless_tools.tcz
- wireless-5.10.77-piCoreXXX.tcz
- wpa_supplicant-dbus.tcz
- wpa_supplicant.tcz
- libnl.tcz
- openssl.tcz
- ca-certificates.tcz
- readline.tcz
- ncurses.tcz
- regdb.tcz
- dbus.tcz

## Boot SD Card
5) Connect keyboard and display to Raspberry
6) Boot Tiny Core.
7) After keypairs have been created, execute ```backup```

## Expand the user/2nd partition
After 10secs of powering on there is minimalistic terminal interface.

8) to expand the user partition:
```
sudo fdisk -u /dev/mmcblk0
```
Then use ```p``` and ```2``` to select partition 2. Take note of start block of partition 2 (e.g. 139264). ```d``` then ```2``` to delete partition 2 and ```n```, ```p``` and ```2``` to create new partition. Use start block of old partition 2. Press enter to select default size which is the max available. ```w``` to write results to disk.
```sudo reboot``` and ```sudo resize2fs /dev/mmcblk0p2``` to make the new partition available. 

## WiFi
If you don't have a wired internet connection and you copied all necessary files into folder tcz on the boot partition you can obtain the files as listed above and:

```
sudo mount /dev/mmcblk0p1 /mnt/mmcblk0p1
cp /mnt/mmcblk0p1/tcz /mnt/mmcblk0p2/tce/optional
chown 1001:staff *.tcz*
chmod 664 *.tcz*
```

If you already have the extensions you only need:
```
echo "firmware-rpi3-wireless.tcz" >> /mnt/mmcblk0p2/tce/onboot.lst
echo "wifi.tcz" >> /mnt/mmcblk0p2/tce/onboot.lst
tce-load -i firmware-rpi-wifi
tce-load -i wifi-wifi
sudo wifi.sh
```
If you obtained the wrong files, executing wifi.sh lets you know that it did not find wifi hardware or that it does not have library to read the passphrase.

Once you have successfully connected to an access point you can run
```
sudo wifi.sh -a
```
Which will try to connect with stored credentials. The credentials are stored in ```~/wifi.db``` and can be edited with plain text editor.

## Username and Password
Defaults are:
```
username: tc
password: piCore
```

## Obtain Extensions
You can view all extension available at the websites listed above. 

You can download a graphical user interface with:

```
tce-load -wi TC
startx
```

Next time you can just load the components without downloading:

```
tce-load -i TC
startx
```

In the GUI environment and using Apps you can select and download several useful extensions.

Apps -> Cloud -> Browse
| Extension | Notes |
|----------------------|-----------------------------|
| hostapd         | Access point daemon |
| dnsmasq         | DNS manipulation |
| samba4          | File Sharing |
| bluez           | Bluetooth functionality |
| firmware-rpi-bt | Bluetooth driver |
| libasound       | needed to run bluetoothctl |
| nano            | Raspi Editor |

To install the extension, select it and for persistent installation choose OnBoot then Go. You can also just download them.

With Apps -> OnBoot Maintenance you can add remove extension that will be loaded at startup.

You can also check if dependencies are met and if any extensions are orphaned.

## onboot.lst

```/mnt/mmcblk0p2/tce/onboot.lst``` is the file that lists all extensions loaded at boot.
You can edit with ```sudo nano /mnt/mmcblk0p2/tce/onboot.lst```

This is example list for Wifi hotspot and bluetooth functionality:
```
openssh.tcz
firmware-rpi-bt.tcz
libasound.tcz
bluez.tcz
firmware-rpi-wifi.tcz
wifi.tcz
```

## Persistence
You need to backup folders from RAM into compressed archive with:
```
backup
```

```/opt/.filetool.lst``` lists additional folders to back up and ```/opt/.xfiletool.lst``` the ones to exclude. The exclude list supersedes the include list.

``` /opt/bootlocal.sh``` is used to start custom program and daemons. More below.

## SSH Connection over WiFi
```
ifconfig -a
sudo wifi.sh
```
Lets you select wireless access point and connect to it.

You should be able to connect to tinycore from an other computer with
```
ssh tc@box
```
Check this if there are issues:
https://iotbytes.wordpress.com/configure-ssh-server-on-microcore-tiny-linux/

It also explains how to make password less SSH connection.

## Remove CR from files
When you copy paste from windows into ssh terminal, you might insert CR-LF as line terminator. You only want LF.
```
sed 's/\r$//' in.txt > out.txt
```

## Wireless Access Point
If you want to use tinycore on Raspberry Pi Zero 2 W, you will want it to automatically connect to Wifi or configure it to behave as access point. You could also use USB OTG cable to ssh into P02W but I have not figured that out yet.
For hotspot look into https://blog.waynejohnson.net/doku.php/airflash

For WiFi client and AP:
https://www.raspberrypi.com/documentation/computers/configuration.html#setting-up-a-routed-wireless-access-point

```
sudo nano /mnt/mmcblk0p2/tce/starnet.sh
```
with content
```
ifconfig wlan0 down
ifconfig wlan0 10.0.0.1 netmask 255.255.255.0 up
```
then
```
chmod 755 /mnt/mmcblk0p2/tce/startnet.sh
````
touch /mnt/mmcblk0p2/tce/dnsmask.leases

The end of ```bootlocal.sh``` should look like:

```
# Start openssh daemon
/usr/local/etc/init.d/openssh start &

# Start wlan0
while ! cat /proc/net/dev | grep wlan0
do
	echo Waiting for wlan0
	sleep 1
done

sudo /mnt/mmcblk0p2/tce/startnet.sh

# hostapd
hostapd -B /mnt/mmcblk0p2/tce/hostapd.conf 2>&1 | tee /tmp/hostapd.log

# DNS masquerade
# dnsmasq -C /mnt/mmcblk0p2/tce/dnsmasq.conf -l /mnt/mmcblk0p2/tce/dnsmasq.leases
```

We need to create a hostapd.conf file with ```sudo nano /mnt/mmcblk0p2/tce/hostapd.conf```

```
# network interface name
interface=wlan0
# firmware driver name: hostapd, wired, madwifi, test, none, nl80211, bsd
driver=nl80211

# Operation mode: a,b,g,ad,
hw_mode=g
# Channel number if 0 need to set with ifconfig
channel=6
# ieee80211n is enabled
ieee80211n=1
# form802.11a and11a networks parameters will be send to wmm clients
wmm_enabled=1
# 0 accept MAC unless in deny list. 1 deny unless in accept list 2 use external radius server
macaddr_acl=0
# 0 desiabled, 1 send empty SSID, 2 clear SSID
ignore_broadcast_ssid=0
# Where are we operating
country_code=US

# 0 open system authentication, 1 shared key authentication,
auth_algs=1
# 1 WPA, 2 WPA2, 3 both
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP

# This is the name of the network
ssid=Urs Tiny Box

# The network passphrase
wpa_passphrase=fluorolog
```

We also need dnsmasq configuration file: ```sudo nano /mnt/mmcblk0p2/tce/hostapd.dnsmasq.conf```

```
interface=wlan0
bind-interfaces
domain-needed
bogus-priv
dhcp-range=10.0.0.2,10.0.0.50,12h
```

We can test Access Point with
```
tce-load -i hostapd
sudo hostapd hostapd.conf
```

## Samba
We need to configure Samba: ```sudo nano /usr/local/etc/samba/smb.conf```

```
[global]
workgroup = WORKGROUP
netbios name = AirFlashNetbios
security = user
guest account = nobody
map to guest = Bad User
usershare path = /usr/local/var/lib/samba/usershares
usershare max shares = 100 
#turn on usershare. 0 is off.
usershare allow guests = yes
usershare owner only = false
```

And extend the extension list ```sudo nano /mnt/mmcblk0p2/tce/onboot.lst```

```
gmp.tcz
nettle.tcz
libattr.tcz
libattr.tcz
p11-kit.tcz
samba4.tcz
```

We also want to backup more folder: ```sudo nano /opt/.filetool.lst```
```
usr/local/etc/samba/
usr/local/var/
```

And we start samaba at boot time ```sudo nano /opt/bootlocal.sh```
```
/usr/local/init.d/samba4 start
```

We need to create the shares:
```
cd /usr/local/var/lib/samba
sudo mkdir usershares
sudo chmod 1770 usershares
sudo chown -R nobody usershares/      
filetool.sh -b
````

## USB Drive Automount
```
sudo net usershare add sdtest /mnt/sda "" Everyone:F guest_ok=y
sudo /usr/local/etc/init.d/samba4 restart
```
And we want to create mounting rules: ```sudo nano /mnt/mmcblk0p2/tce/999-usb-automount.rules```

```
KERNEL=="sd*", ACTION=="add",   SUBSYSTEM=="block", MODE="755", OWNER="nobody", RUN+="/usr/bin/mount /mnt/%k"
KERNEL=="sd*", ACTION=="add",   SUBSYSTEM=="block", RUN+="/usr/local/bin/net usershare add %k /mnt/%k '' Everyone:F guest_ok=yes"
KERNEL=="sd*", ACTION=="remove", SUBSYSTEM=="block",    RUN+="/usr/local/bin/net usershare delete %k"
KERNEL=="sd*", ACTION=="remove", SUBSYSTEM=="block",    RUN+="/usr/bin/fuser -mk /mnt/%k"
KERNEL=="sd*", ACTION=="remove", SUBSYSTEM=="block",    RUN+="/bin/umount /mnt/%k"
KERNEL=="sd*", ACTION=="remove", SUBSYSTEM=="block",    RUN+="/bin/rmdir /mnt/%k"
```

Create rules loading script ```sudo nano /mnt/mmcblk0p2/tce/startusbautomount.sh```

```
#!/bin/sh
sudo cp /mnt/mmcblk0p2/tce/999-usb-automount.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger
```
Make script executable and backup:
```
chmod 755 /mnt/mmcblk0p2/tce/startusbautomount.sh
filetool.sh -b
```
## Fix Shell Scripts
tr -d '\r' input.txt > out.txt











## Bluetooth

It is tricky to enable Bluetooth on piCore and connect to devices. 

Check following links for any basic Bluetooth setup : Rasp Pi specific :
1) *https://www.cnet.com/how-to/how-to-setup-bluetooth-on-a-raspberry-pi-3/

General Bluetooth setup in Linux distros :
2) *https://www.pcsuggest.com/linux-bluetooth-setup-hcitool-bluez/
3) *https://www.pcsuggest.com/bluetooth-linux-part-2/

tinyCore keyboard: 
https://forum.tinycorelinux.net/index.php/topic,25245.msg161269.html#msg161269

other tinyCore posts:
http://forum.tinycorelinux.net/index.php/topic,26117.msg167671.html#msg167671
http://forum.tinycorelinux.net/index.php?topic=23895.0
http://forum.tinycorelinux.net/index.php/topic,19481.30.html
http://forum.tinycorelinux.net/index.php/topic,24427.0.html
https://forum.tinycorelinux.net/index.php?topic=25961.0
http://www.m-opensolutions.com/bluetooth-mouse-on-tiny-core-linux/

Install the necessary extensions. Bluetooth wants the sound drivers too.
```
tce-load -wi firmware-rpi-bt.tcz
tce-load -wi bluez.tcz
tce-load -wi alsa.tcz
tce-load -wi bluez-alsa.tcz
tce-load -wi libasound.tcz
```
Optional installation
```
tce-load -wi blueman.tcz
```
You can scan, pair and connect to devices in the TC GUI after installaing blueman.tcz. Makue sure bluez service is running in TC.

To start bluetooth controller we create a script.

```
#!/bin/sh
# Init Bluetooth.
echo "Helle bluetooth1"
#
# tce-load -i bluez
# tec-load -i firmware-rpi-bt
#
sudo modprobe uhid
sudo modprobe uinput
sudo modprobe joydev
sudo modprobe rfkill
sudo modprobe ecc
sudo modprobe ecdh_generic
sudo modprobe bluetooth
sudo modprobe btbcm
sudo modprobe hci_uart
# list all loaded modules and who is using them
#  - lsmod
# check on system errors
#  - dmesg
sudo /usr/local/etc/init.d/dbus start
sudo /usr/local/etc/init.d/bluez start
sleep 1
sudo /usr/local/etc/init.d/dbus start
# firmware upload command sometimes times out on the first attempt
until sudo hciattach -t 10 /dev/ttyAMA0 bcm43xx 921600 noflow
do
   echo hciattach returned $?
   echo retrying hciattach
done
sleep 1
bluetoothctl power on
bluetoothctl pairable on
```

Make the bluetooth start script bootable and back it up
```
chmod 755 bt_start.sh
backup
```

Make sure that ```UserspaceHID=true``` is set in ```/usr/local/etc/bluetooth/input.conf```

Set ```AutoEnbale=true``` in ```/usr/local/etc/bluetooth/main.conf``` otherwise the trusted devices will not connect by themselves.
Uncomment ```ReconnectionAttemps=7``` and ```ReconnectionIntervals=1,2,4,8,16,32,64``` it might help with reconnecting.

To permanently install devices you need to manually pair and trust them and then include the keys to /opt/.filetools.lst
```
bluetoothctl 
scan on
```
Wait for any pairing keys and enter them on the bluetooth device if prompted.
```
pair 00:00:00:33:9B:58
trust 00:00:00:33:9B:58
connect 00:00:00:33:9B:58
```

### Game Pad

This will only work if appropriate system device drivers are available. Not all necessary device drivers are included in the piCore distro and there are additional modules available in the modules archive. For Pi Zero 2 obain http://tinycorelinux.net/13.x/armv7/releases/RPi/src/kernel/5.10.77-piCore-v7_modules.tar.xz Check for the appropriate archive in config.txt on boot device. It lists which piCore is loaded for which board. There is v6, v7, c7l.

Extract ```joydev.ko``` and copy to ```/lib/modules/5.10.77-piCore-v7/kernel/drivers/input`` and then add its path to backup list ```sudo nano /opt/.filetool.lst``` 

Add ```kernel/drivers/input/joydev.ko:``` to the end of ```/lib/modules/5.10.77-piCore-v7/modules.dep```
Also add modules.dep to backup list.

Create script top start gamepad from know device MAC address. ```sudo nano /home/tc/bt_gamepad.sh```

Might need

libevdev-dev.tcz
libevdev.tcz
libudev-dev.tcz
libudev.tcz

```
#!/bin/sh
# Connect to bluetooth device with mac or ID listed in file

if [ -s "/home/tc/btdev_controller.lst" ]
then
 	echo Searching for bluetooth controllers...
	dev=
	while [ -z "$dev" ]
	do
	  sleep 1
	  dev="`bluetoothctl devices | grep -f /home/tc/btdev_controller.lst`"
	done
	mac=`expr "$dev" : 'Device \(..:..:..:..:..:..\) '`
	sudo bluetoothctl power on
	sudo bluetoothctl pairable on
	# sudo bluetoothctl pair $mac
	sudo bluetoothctl connect $mac
fi
```

Add the file above to backup list with ```sudo nano /opt/.filetools.lst```

We need to create the gamepad device name: ```sudo nano /home/tc/btdev_controller.lst``` for example
```
Umido ESoul DH2
```

Test the setup
```
startx
```
Play with joystick. Mouse shold move.

### Bluetooth Speakers

bluealsa -S &

Create a config file like bluetooth speakers ```sudo nano /etc/asound.conf```
```
defaults.bluealsa.service "org.bluealsa"
defaults.bluealsa.device ""
defaults.bluealsa.profile "a2dp"

pcm.!default {
 type plug
 slave {
 pcm "bluealsa"
 }
}
```

Add the file abvoe to backup list with ```sudo nano /opt/.filetools.lst```

Automatically connecting to speakers with script ```sudo nano /home/tc/bt_speaker.sh```

```
#!/bin/sh
# Connect to bluetooth device with mac or ID listed in file

if [ -s /home/tc/btdev_audio.lst ]
then
	echo Searching for bluetooth speakers...
	dev=
	while [ -z "$dev" ]
	do
	  sleep 1
	  dev="`bluetoothctl devices | grep -f /home/tc/btdev_audio.lst`"
	done
	mac=`expr "$dev" : 'Device \(..:..:..:..:..:..\) '`
	sudo bluetoothctl pair $mac
	sudo bluetoothctl connect $mac
	sed -i "s/defaults.bluealsa.device \".*\"/defaults.bluealsa.device \"$mac\"/" /etc/asound.conf
fi
```

You need to either modify /usr/local/etc/dbus-1/system.d/bluealsa.conf (and add it to /opt/.filetool.lst) to allow the "staff" group to access Bluetooth audio, or create an "audio" group and add users to that. Otherwise you'll only be able to play through the speaker from programs running as root. ...

We need to create device pattern: ```sudo nano /home/tc/btdev_audio.lst``` 
```
Name of your speakers here
```

Test the setup

```
tce-load -i alsa-utils
aplay test.wav
```

### Bluetooth Keyboard
TBD

### Bluetooth Mouse
TBD

### Bluetooth Paired Key Backup

We need to back up the paired devices ```/var/lib/bluetooth/nn:nn:nn:nn:nn:nn``` so that devices can get paired automatically by addign  sudo nano ```/opt/filetool.lst```. We need to add the ```var/lib/bluetooth``` as well as var/lib/bluetooth/*/cache/*```.

```
var/lib/bluetooth/00:15:83:D2:28:ED/cache or
var/lib/bluetooth/00:15:83:D2:28:ED/cache/00:04:20:F2:46:E6
```

Because cache is in /opt/.xfiletool.lst we had to explicityly add the cache folders. ```cache``` is in exclude folder because webbrowser cache can be large.

## Compiling and INstalling Python Extensions

```
tce-load -i binutils
tce-load -i gcc
tce-load -i gcc_base-dev
tce-load -i gcc_libs
tce-load -i gcc_libs-dev
tce-load -i compiletc
tce-load -i python3.8
tce-load -i python3.8-dev
tce-load -i python3.8-pip
tce-load -i python3.8-setuptools
# tce-load -i libbluetooth-dev
# tce-load -i glib2-dev
# tce-load -i boost-dev
```

```
sudo date -s 2023.04.19-19:35
```

Installing from source
```
mkdir ~/python
cd ~/python
pip3 download evdev
python3 setup.py config
python3 setup.py build
sudo pip3 install -e .
```

Or directly
```
sudo pip install evdev    # available globally
pip install --user evdev  # available to the current user
```

## Bluetooth Event Handling


pip3 install joystick

python-evdev 
https://python-evdev.readthedocs.io/en/latest/
https://youtu.be/Ro4wRQGtnBw+


## pyserial
tce-load -i py3.8ser

### UDEV Rules

Create udev rules ```sudo nano /etc/udev/rules.d/99-com.rules``` 

```
SUBSYSTEM=="input", GROUP="staff", MODE="0660"
SUBSYSTEM=="i2c-dev", GROUP="staff", MODE="0660"
SUBSYSTEM=="spidev", GROUP="staff", MODE="0660"
SUBSYSTEM=="bcm2835-gpiomem", GROUP="staff", MODE="0660"

SUBSYSTEM=="gpio", GROUP="staff", MODE="0660"
SUBSYSTEM=="gpio*", PROGRAM="/bin/sh -c '\
        chown -R root:staff /sys/class/gpio && chmod -R 770 /sys/class/gpio;\
        chown -R root:staff /sys/devices/virtual/gpio && chmod -R 770 /sys/devices/virtual/gpio;\
        chown -R root:staff /sys$devpath && chmod -R 770 /sys$devpath\
'"

KERNEL=="ttyAMA[01]", PROGRAM="/bin/sh -c '\
        ALIASES=/proc/device-tree/aliases; \
        if cmp -s $ALIASES/uart0 $ALIASES/serial0; then \
                echo 0;\
        elif cmp -s $ALIASES/uart0 $ALIASES/serial1; then \
                echo 1; \
        else \
                exit 1; \
        fi\
'", SYMLINK+="serial%c"

KERNEL=="ttyS0", PROGRAM="/bin/sh -c '\
        ALIASES=/proc/device-tree/aliases; \
        if cmp -s $ALIASES/uart1 $ALIASES/serial0; then \
                echo 0; \
        elif cmp -s $ALIASES/uart1 $ALIASES/serial1; then \
                echo 1; \
        else \
                exit 1; \
        fi \
'", SYMLINK+="serial%c"
```

Update backup rules by adding rules to ```sudo nano /opt/.filetools.lst```

```
sudo bluetoothctl
power on
discoverable on
pariable on
scan on
pair 00:00:00:33:9B:58
trust 00:00:00:33:9B:58
connect 00:00:00:33:9B:58
pair off
```

## GPIO & Python
https://iotbytes.wordpress.com/control-raspberry-pi-gpio-pins-with-picore-and-rpi-gpio/

```
tce-load -wi python3.8.tcz
tce-load -wi python3.8-rpi-gpio.tcz
mkdir /home/tc/python
nano  /home/tc/python/blink.py
sudo echo '/home/tc/python' >> /opt/.filetool.lst
sudo echo '# sudo python /home/tc/python/blink.py' >> /opt/bootlocal.sh
```

## Notes / Left Overs

dbus
sudo /usr/local/etc/init.d/dbus start
sudo /usr/local/lib/bluetooth/bluetoothd -nd
blutoothctl

