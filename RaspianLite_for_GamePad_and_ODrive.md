# Raspberry Pi "Lite" for Motor Control

Here I attempt creating a Raspberry Pi Zero 2 W setup that will communicate with **Odrive** and a **bluetooth** controller as well as indicated status and read sensors.

I require **fast boot** time to that the controller can interact with thte motor in reasonable time. Raspberry Pi with linux might not be ideal environment as it will take more than 10 seconds to boot. A short boot time is accomplished by disabling many unneeded services and using a second Raspberry Pi that will be handling other services.

A Raspberry Pi Zero 2 W will boot in approximately 20 secs from power on and be able to have bluetooth device connected.

Networking over wireless is not needed and we will use point to point ethernet over serial UART to connect to the second raspberry. PPP ping delay at 1000k baud is about 1-2ms and using ZMQ for communication between several program and between the two computers should enable realtime handling of the complete system.

- Raspberry Pi **Motor**
    - Bluetooth OFF
    - Wirless OFF
    - Serial UART Point to Point Protocol
    - ODrive
    - [USB Hub](https://a.co/d/i025VFW) for Raspberry Pi Zero
    - [Edimax BLE 5.0 Dongle](https://a.co/d/0fMSu0X)
- Raspberry Pi **Board**
    - Wifi ON
    - Serial UART Point to Point Protocol
    - I2C accelerometer
    - I2C realtime clock
    - Neopixel on PIN18
    - Level Shifter 3.5V to 5V (for neopixel)
    - Camera optional

## Table of Contents
- [Raspberry Pi "Lite" for Motor Control](#raspberry-pi--lite--for-motor-control)
  * [**General Configuration**](#--general-configuration--)
  * [**Install Packages**](#--install-packages--)
    + [Basics](#basics)
    + [**PySerial**](#--pyserial--)
    + [**ODrive Tool**](#--odrive-tool--)
    + [**Other Packages**](#--other-packages--)
    + [**Install Desktop PIXEL**](#--install-desktop-pixel--)
    + [**Realtime Clock**](#--realtime-clock--)
    + [**Accelerometer**](#--accelerometer--)
    + [**Neo Pixels**](#--neo-pixels--)
    + [**PPP**](#--ppp--)
      - [Bauderates](#bauderates)
      - [**Serial on Pi 3 and Pi 0 W**](#--serial-on-pi-3-and-pi-0-w--)
      - [**PPD Setup**](#--ppd-setup--)
      - [**PPD on Server**](#--ppd-on-server--)
      - [**PPD on Client**](#--ppd-on-client--)
    + [**Python program as systemd service**](#--python-program-as-systemd-service--)
    + [**ZeroMQ**](#--zeromq--)
    + [**Sync Time**](#--sync-time--)
    + [**Speed up boot time**](#--speed-up-boot-time--)
      - [**Boot Results**](#--boot-results--)
    + [**Speed up Boot by Disabling Services**](#--speed-up-boot-by-disabling-services--)
      - [**Server**](#--server--)
      - [**Client**](#--client--)
  * [**Auto Login to Raspian**](#--auto-login-to-raspian--)
  * [**Remove CR from files**](#--remove-cr-from-files--)
  * [**Bluetooth**](#--bluetooth--)
  * [**Tankdrive**](#--tankdrive--)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

## **General Configuration**

1) Download Raspian Imager https://downloads.raspberrypi.org/imager/imager_latest.exe
2) Use Raspberry Pi OS Lite 64bit
3) Set, ssh, wifi, username, password, hostname in the imager settings.
4) Expand the user/2nd partition
5) ```sudo raspi-config```, set auto login and the interfaces you need, dont add unnecessar interfaces as it adds to boot delay.

If you have troubles downloading or updating the raspberry pi, check that your time is close to the correct current time. First check date with ```date```, then set the date with ```sudo date -s 2023.04.19-19:35```

## **Install Packages**

### Basics
```
sudo apt-get update
sudo apt-get full-upgrade
sudo apt-get install python3-pip
sudo apt-get install git
sudo apt-get install i2c-tools
```

### **PySerial**
```sudo pip3 install pyserial``` to talk to odrive.

### **ODrive Tool**
```
git clone https://github.com/odriverobotics/ODrive.git
```
```
sudo pip3 install --pre --upgrade odrive
```
```
# cd ~/ODrive
# sudo bash -c "curl https://cdn.odriverobotics.com/files/odrive-udev-rules.rules > /etc/udev/rules.d/91-odrive.rules"
# sudo bash -c "udevadm control --reload-rules"
# sudo bash -c "udevadm trigger" 
```

Also download latest firmware for your Odrive as shown here: [Firmware](https://docs.odriverobotics.com/releases/firmware)

For example I need Odrive V3.6 with 56V capacitors.
```
wget https://odrive-cdn.nyc3.digitaloceanspaces.com/releases/firmware/BhI6UROJjzOq9x1S755S9xKxf8SJcOhtuW9g2OV45-8/firmware.elf
```

If you can’t invoke ```odrivetool``` at this point, try adding ```~/.local/bin``` to your $PATH. This is done for example by running ```nano ~/.bashrc```, scrolling to the bottom, pasting ```export PATH=$PATH:~/.local/bin```, and then saving, closing and reopening the terminal window.

### **Other Packages**
- **bleak**
```
git clone https://github.com/hbldh/bleak.git
cd bleak/
sudo pip3 install poetry
sudo pip3 install pytest
sudo pip3 install flake9
sudo pip3 install black
poetry install
poetry run black .
poetry run flake8
poetry run pytest
sudo pip install .
```

- **uvloop**
```
git clone https://github.com/MagicStack/uvloop.git
cd uvloop
sudo apt -y install python3-docutils
sudo apt-get autoremove  automake
sudo apt-get install automake libtool libssl-dev libffi-dev
git submodule init
git submodule update
sudo pip install .
make test
```

- **bluez**
```
cd ~
wget http://www.kernel.org/pub/linux/bluetooth/bluez-5.68.tar.xz
tar xvf bluez-5.68.tar.xz
cd bluez-5.68
sudo apt-get install -y libusb-dev libdbus-1-dev libglib2.0-dev libudev-dev libical-dev libreadline-dev
./configure --enable-library
make
sudo make install
systemctl status bluetooth
sudo systemctl stop bluetooth
sudo systemctl enable bluetooth

sudo nano /lib/systemd/system/bluetooth.service
```
```
[Service]
...
ExecStart=/usr/local/libexec/bluetooth/bluetoothd --experimental               
...
```
```
sudo systemctl daemon-reload
sudo systemctl restart bluetooth
```

### **Install Desktop PIXEL**
If needed:
```
sudo apt-get install --no-install-recommends xserver-xorg
sudo apt-get install --no-install-recommends xinit
sudo apt-get install raspberrypi-ui-mods
```

### **Realtime Clock**
For a device connecting to the internet we should have a realtime clock, otherwise the security certificates are invalid and it will be difficult to obtain time from a time server. I attached an RTC DS1307 to the I2C interface:

```sudo nano /boot/config.txt```
```
dtoverlay=i2c-rtc,ds1307
```
Rebooth then check if realtime clock is found:
```
sudo i2cdetect -y 1
```
Then finalize the realtime clock setup.
```
sudo apt-get -y remove fake-hwclock
sudo update-rc.d -f fake-hwclock remove
sudo systemctl disable fake-hwclock
```

```sudo nano /lib/udev/hwclock-set``` and comment out these three lines:

```
#if [ -e /run/systemd/system ] ; then
# exit 0
#fi
```

If you want to access RTC with python:
```pip3 install adafruit-circuitpython-ds1307```

### **Accelerometer**
For the device connecting to internet we use circuit python to read the Intertial Measurement Unit. Here I work with icm20649.

```
git clone https://github.com/uutzinger/Aadafruit-circuitpython-icm20x
cd Adafruit
sudo pip install .
```

To fuse the sensor data I use my IMU library:
```
git clone https://github.com/uutzinger/pyIMU.git
cd pyIMU
pip install -e .
```

### **Neo Pixels**
I will want to display speed and battery status on the device connecting to internet. I am using two 30 LED Neo Pixels. They need to be connected serially as raspberry pi can not drive neo pixel led strips connected to different pins.
```
sudo pip3 install rpi_ws281x adafruit-circuitpython-neopixel
```

Neo pixels require that the python program is run with root access and the clock needed for sound needs is no longer availab le. Sound will need to be turned off.

[Learn Neo Pixels](https://learn.adafruit.com/neopixels-on-raspberry-pi/python-usage)

### **PPP**

```
sudo apt-get install ppp
```

We will attempt local network over serial RX/TX (pin 8/10). This will work between two computers only. Make sure serial console is disabled, but serial interface is enabled in ```raspi-config```. Most unix systems can be accessed during boot over hardware serial console. We will need that console to communicate between the two raspberry pi and can not have it act as terminal during boot.

- [PPP over serial](https://docs.j7k6.org/raspberry-pi-ppp-network-serial-console/)
- [Networking over UART](https://www.instructables.com/Connect-the-Raspberry-Pi-to-network-using-UART/)

- [Raspberry Pi Serial Ports](https://docs.bitscope.com/pi-serial/)
- [Raspberry Pi Zero, serial and bluetooth](https://raspberrypi.stackexchange.com/questions/45570/how-do-i-make-serial-work-on-the-raspberry-pi3-pizerow-pi4-or-later-models/45571#45571)

```sudo raspi-config ```
- Select option 5, "Interfacing Options"
- Select option P6, "Serial"
- Select "No" to login shell and "Yes" to enabling serial port

We can test the serial speed with loop back between pins using a direct wire. [Serial Port Loopback](https://di-marco.net/blog/it/2020-06-06-raspberry_pi_3_4_and_0_w_serial_port_usage/).

#### Bauderates
The following official baud rates work with Raspberry Pi Zero:

    0:       0000000,  # hang up
    50:      0o000001, # ...
    75:      0o000002, # ...
    110:     0o000003, # ...
    134:     0o000004, # ...
    150:     0o000005, # ...
    200:     0o000006, # ...
    300:     0o000007, # ...
    600:     0o000010, # ...
    1200:    0o000011, # ...
    1800:    0o000012, # ...
    2400:    0o000013, # ...
    4800:    0o000014, # ...
    9600:    0o000015, # ...
    19200:   0o000016, # ...
    38400:   0o000017, # ...
    57600:   0o010001, # ...
    115200:  0o010002, # works
    230400:  0o010003, # ...
    460800:  0o010004, # ...
    500000:  0o010005, # ...
    576000:  0o010006, # ...
    921600:  0o010007, # works
    1000000: 0o010010, # ...
    1152000: 0o010011, # works
    1500000: 0o010012, # ...
    2000000: 0o010013, # does not work
    2500000: 0o010014, # ...
    3000000: 0o010015, # ...
    3500000: 0o010016, # ...
    4000000: 0o010017  # ...

#### **Serial on Pi 3 and Pi 0 W**

Pi3 and Pi0 have only two UARTs and one is needed for bluetooth functionality. Pi0W has Bluetooth 4.2 and it does not reach data transfer rates of Pi4. A USB to BLE5.0 dongle works better.

After turning on serial in raspi-config you can furhter modify: ```sudo nano /boot/config.txt```

From turning on serial:
```
enable_uart=1
```
We can disable bluetooth with 
```
disable-bt
```
#### **PPD Setup**
PPPD has many options and it will read the once in the file /etc/ppp/options as well as commandline options:
- *proxyarp* make appear on local ethernet
- local* dont use modem control lines
- *lock* get exclusive lock on port
- *noauth* dont require authentication
- *debug* debug to syslog
- *defaultroute* peer becomes gateway (for client)
- *nodetach* dont detach from terminal
- *dump* dump all options, then continue
- *nocrtscts* dont have crtscts hardware
- *passive* wait until packet received
- *persist* try to reopen connection
- *maxfail* 0 do not terminate after failure
- *holdoff* 1 wait 1 sec before re initialize link, needs persist option

#### **PPD on Server**
```cp /etc/ppp/options /etc/ppp/options.back```

Edit the options with:
```sudo nano /etc/ppp/options```

- ms-dns set it to the same DNS as you can find in /etc/resolv.conv
- noauth
- local
- lock
- passive
- silent
- proxyarp
- nopix
- persist
- maxfail 0
- holdoff 1

Set iptables and packet forwarding
```sudo nano /etc/sysctl.conf```
- net.ipv4.ip_forward=1

Load the kernel settings ```sudo sysctl -p```

For packet routing on the server you need the following firewall settings:

```
sudo iptables -A FORWARD -i ppp+ -j ACCEPT
sudo iptables -A FORWARD -o ppp+ -j ACCEPT
sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
sudo iptables -A INPUT -i lo -j ACCEPT
```

You can install netfilter-presient and iptables-persistent and backup IP tables but its faster to add the rules in the rc.local file.
```
sudo apt-get install iptables-persistent
sudo netfilter-persistent save
sudo netfilter-persistent reload
```

Content of /etc/rc.local on **server** should be added by:

```
echo "Starting pppd..."
stty -F /dev/serial0 raw
sudo pppd /dev/serial0 921600 10.0.0.1:10.0.0.2 &
sudo sysctl -p
sudo iptables -A FORWARD -i ppp+ -j ACCEPT
sudo iptables -A FORWARD -o ppp+ -j ACCEPT
sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
sudo iptables -A INPUT -i lo -j ACCEPT
```
#### **PPD on Client**

``` cp /etc/ppp/options /etc/ppp/options.back```
Edit the server options with:
```sudo nano /etc/ppp/options```

- usepeerdns
- noauth
- local
- lock
- defaultroute
- replacedefaultroute
- nopix
- persist
- maxfail 0
- holdoff 1

```
stty -F /dev/serial0 raw
stty -F /dev/serial0 -a 
pppd /dev/serial0 921600 10.0.0.2:10.0.0.1
```
### **Python program as systemd service**
We will need the programs for the sensors and bluetooth controlers to automatically start at boot. That is accomplised with systemd services:

```sudo nano /lib/systemd/system/gearVRC.service``` (name of the service is gearVRC in this case)
```
[Unit]
Description=Samsung gearVR controller
After=multi-user.target

[Service]
Type=simple
User=<username>
Group=<username>
Restart=always
ExecStart=/usr/bin/python3 /home/<username>/gearVRC.py -your options
WorkingDirectory=/home/<username>

StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=my_service

[Install]
WantedBy=multi-user.target
```

For python progras you need to specify user and group because some of your python extensions might a have been installed into the user's local folder.

You will need to set the file properties to enable their execution:

```
sudo chmod 644 /lib/systemd/system/my.service
chmod +x /home/pi/myprogram.py
sudo systemctl daemon-reload
sudo systemctl enable my.service
sudo systemctl start my.service
```
You can observe the progress of your new service:
```
journalctl -f -u my_service
```

### **ZeroMQ**          
On both devices ```sudo pip3 install pyzmq```. We will use ZMQ to communicate between devices and tasks.

### **Sync Time**
We will want both raspberry pi to have the same time.

- Simple
on client execute
```
sudo date --set="$(ssh uuser@10.0.0.1 ‘date -u’)"
```
This requires that permanent security keys are isntalled.

- NTP for more complex time sync

On both devices
https://serverfault.com/questions/806274/how-to-set-up-local-ntp-server-without-internet-access-on-ubuntu

```
sudo apt install chrony
```

```
sudo systemctl enable chronyd
sudo systemctl status chronyd
```

**Client** ```/etc/chrony/chrony.conf```:

```
server 10.0.0.1 iburst
keyfile /etc/chrony/chrony.keys
driftfile /var/lib/chrony/*chrony.drift
log tracking measurements statistics
logdir /var/log/chrony
```
```
sudo systemctl restart chronyd
```

**Server** ```/etc/chrony/chrony.conf```:
```
keyfile /etc/chrony/chrony.keys
driftfile /var/lib/chrony/chrony.drift
log tracking measurements statistics
logdir /var/log/chrony
local stratum 8
manual
allow 10.0.0.0/24 allow 10.0.0.1
```
```
sudo systemctl stop chrony
sudo systemctl start chrony
sudo systemctl status chrony
```
```
chronyc activity
chronyc tracking
chronyc sources
```
```
timedatectl
```

### **Speed up boot time**

For **Motor** ODrive controlling device:

Disable hardware components we don't need:

```
sudo nano /boot/config.txt
```
Specifically
```
# Disable Audio
dtparam=audio=off

# Comment all optional hardware interfaces
#dtparam=i2c_arm=on
#dtparam=i2s=on
#dtparam=spi=on

# Dont cameras
camera_auto_detect=0

# Dont detected DSI displays
display_auto_detect=0

# Disable Splash Screen and Boot Delay
disable_splash=1
boot_delay=0

[all]
# Don't need wifi and internal bt. We have dongle
dtoverlay=disable-wifi
dtoverlay=disable-bt
```

Now we make the boot quiet

```
sudo nano /boot/cmdline.txt
```
```
console=tty1 loglevel=5 quiet root=PARTUUID=44211654-02 rootfstype=ext4 fsck.mode=skip rootwait logo.nologo vt.global_cursor_default=0
```

Check out boot timing with

- ```systemd-analyze``` This shows kernel, user space and services.
- ```systemd-analyze critical-chain``` This shows what is holding up programs
- ```systemd-analyze blame``` This lists execution time of all programs started at boot

#### **Boot Results**
Pi0W2 multiuser target after time in userspace
- [1] 16.9 secs to user space on Raspian Light
- [2] 14.23 boot/config.txt and cmdline.txt changes
- [3] 14.11 disable raspi-config.service
- [4] 13.88 disable rpi-eeprom-update.service
- [5] 9.647 changed to network manager from dhcpd
- [6] 7.16 in client as configured below, no bt and no wifi

Server: 17.47 seconds to finish startup

Client: 11.71 seconds to finihs startup

### **Speed up Boot by Disabling Services**
List the services
- ```systemctl list-unit-files --type=service```
- ```systemctl status```
- ```sudo service --status-all```
- ```sudo rcconf```

#### **Server**
Following services are running
- avahi-daemon (Zeronconf networking protocol)
- bluetooth
- chrony
- cron
- dbus (Inter process communication)
- dphys-swapfile
- fake-hwclock
- kmod (kernel modules)
- networking
- plymouth (boot graphical experience)
- plymouth-log
- procps (syste processes and routines)
- raspi-config (configuration)
- rng-tools-debin (random number tools)
- rsyslog
- ssh
- triggerhappy (hotkeydaemon)
- udev (user space device manager)

#### **Client**

```
# User Boot Experience, does not impact boot times
sudo systemctl disable plymoth.service
sudo systemctl disable plymoth-log.service
# Configure raspi, does not impact boot times
sudo systemctl disable raspi-config.service
# Swapfile does not impact boot tims
sudo systemctl disable dphys-swapfile.service 
# Don't care about keyboard, slight impact on boot times
sudo systemctl disable keyboard-setup.service
sudo systemctl disable triggerhappy
# Will not want to flash EEPROM, does not affect boot times
sudo systemctl disable rpi-eeprom-update.service
# Don't need network wlan and eth0
sudo systemctl disable NetworkManager.service
sudo systemctl disable wpa_supplicant.service
sudo systemctl disable ModemManager.service
# Don't care about printing
sudo systemctl disable cups.service
sudo systemctl disable cups-browsed.service
```
Current **Client** boot time is:

Startup finished in 3.817s (kernel) + 7.738s (userspace) = 11.555s
multi-user.target reached after 7.076s in userspace

## **Auto Login to Raspian**

On client, e.g. Windows Powershell
```
ssh-keygen
ssh-copy-id username@destination.host
```

## **Remove CR from files**
When you copy paste from windows into ssh terminal, you might insert CR-LF as line terminator. You only want LF. You can strip them in text files with:
```
sed 's/\r$//' in.txt > out.txt
```

## **Bluetooth**

To permanently install devices you need to manually pair and trust them.

```
bluetoothctl 
power on
pairable on
scan on
```

Wait for any pairing keys and enter them on the bluetooth device if prompted e.g.:
```
pair 00:00:00:33:9B:58
trust 00:00:00:33:9B:58
connect 00:00:00:33:9B:58
```

If you modify wireless connection or management, it might be necessary to repair the device.
When a device is scanning 

## **Tankdrive**
Example tank drive where there are two wheels or treads that rotate at different speed. The average speed is the vehicle speed but difference between left and righ wheels will roate the vehicle.

```
class TankDrive(object):
    ###########
    # Tank Drive
    # speed: speed base 
    # left_right:  left versus right -1..+1, if -1 speed_motor will become 0
    # speed_Left:  set speed for left motor
    # speed_Right: set speed for right motor
    ###########

    def __init__(self):
        self.MAXUPDOWN     = 7  # max joystick value, needs to be postive
        self.MINUPDOWN     = -7 # min joystick value, needs to be negative
        self.MAXLR         = 7 
        self.MINLR         = -7 
        self.SENS          = 1.5 # non linear joystick sensitivity
        self.MAX_SPEED     =  30 # max speed value
        self.MIN_SPEED     = -30
        self.MAX_RATIO     =  1.
        self.MIN_RATIO     = -1.
        self.SPEED_GAIN    = 0.1 # how fast to increase/decrease speed
        self.RATIO_GAIN    = 0.1 # how fast to steer
        self.speed         = 0   # set speed to zero
        self.ratio         = 0   # set steering straight
        self.speed_left    = 0   # set left & right zero
        self.speed_right   = 0
        self.eco           = True

    def update(self, REL_X=0, REL_Y=0):
        # Joystick conversion
        # Will create values between -1 and 1
        # non linear adjustments

        if REL_Y < 0:
            _up_down    = - (REL_Y/MINUPDOWN)^SENS # -1..1
        else: 
            _up_down    =   (REL_Y/MAXUPDOWN)^SENS
        if REL_X < 0:
            _left_right = - (REL_X/MINLR)^SENS     # -1..1
        else:
            _left_right =   (REL_X/MAXLR)^SENS     # -1..1

        # Set speed will be adjusted incrementally by joystick value
        # Speed is clamped
        self.speed   += (self.SPEED_GAIN * _up_down)
        self.speed = clamp(self.speed, self.MIN_SPEED, self.MAX_SPEED)

        # Left-Right ratio
        self.ratio  += (self.RATIO_GAIN * left_right)
        self.ratio = clamp(self.ratio, self.MIN_RATIO, self.MAX_RATIO)

        # Left versus right motor
        # if ratio is -1 left motor is 0 and right motor is 2 * speed
        self.speed_left  = self.speed + self.speed *self.ratio
        self.speed_right = self.speed - self.speed *self.ratio

    def turbo(self):
        if self.eco:
            self.eco=True
            self.SPEED_GAIN = 0.2
        else:
            self.eco=False
            self.SPEED_GAIN = 0.1

    def center(self):
        self.ratio = 0
```
