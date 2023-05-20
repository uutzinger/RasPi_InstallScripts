# Raspberry Pi Lite For Motor Controller

Here we attempt creating a Raspberry Pi Zero 2 W raspian setup that will work with Odrive and bluetooth gamepad as controller.

For fastest boot the controller should not have anything else running that the minimum services.
Raspberry Pi Zero 2 W will boot in approximately 20 secs from power on and be able to have bluetooth device connected. 

Networking over wireless is not needed and we will use point to point ethernet over serial to connect to second raspberry. Second raspberry will have many more interfaces enabled but  boot will take longer: wireless, i2s sensors, camera and lights etc.

## SD card
1) Download Raspian Imager https://downloads.raspberrypi.org/imager/imager_latest.exe
2) Use Raspberry Pi OS Lite 64bit
3) Set, ssh, wifi, username, password, hostname in the imager settings.
4) Expand the user/2nd partition

## Configuration
If you can not download from several websites check that your time is close to correct.
sudo date -s 2023.04.19-19:35

### General
```
sudo raspi-config
```
Set auto login, the interfaces you need

## Install Packages

### Basics
```
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install python3-pip
```
### Bluetooth and Device Connections
For device connected to Odrive
https://python-evdev.readthedocs.io/en/latest/
```
sudo pip3 install python-evdev
sudo pip3 install pyudev
```

### PySerial
```
sudo pip3 install pyserial```
```
To talk to odrive.

## ODrive Tool
```
sudo pip3 install --pre --upgrade odrive

sudo bash -c "curl https://cdn.odriverobotics.com/files/odrive-udev-rules.rules > /etc/udev/rules.d/91-odrive.rules"
sudo bash -c "udevadm control --reload-rules"
sudo bash -c "udevadm trigger" 
```

Also download latest firmware for your odrive as shown here. https://docs.odriverobotics.com/releases/firmware
E.g. for Odrive V3.6 with 56V capacitors https://odrive-cdn.nyc3.digitaloceanspaces.com/releases/firmware/CYC5jqJ8C3fX8EsJrgmPryR3_y9xgtR-zNw5jgeSUKk/firmware.elf
Once we disable wireless you can no longer download firmware.

Ubuntu, Raspbian: If you can’t invoke odrivetool at this point, try adding ~/.local/bin to your $PATH (see related bug). This is done for example by running nano ~/.bashrc, scrolling to the bottom, pasting export PATH=$PATH:~/.local/bin, and then saving and closing, and close and reopen the terminal window.

### Realtime Clock
For device connecting to internet

pip3 install adafruit-circuitpython-ds1307

sudo modprobe rtc-ds1307
sudo nano /etc/modules 
add to end of file
    rtc-ds1307
sudo nano /etc/rc.local
add before exit0
    echo ds1307 0x68 > /sys/class/i2c-adapter/i2c-1/new_device
    sudo hwclock -s
    date
sudo hwclock -w

### Accelerometer
For device connecting to internet
circuit python

https://pypi.org/project/mpu9250-jmdev
sudo pip3 install mpu9250-jmdev

sudo pip3 install adafruit-circuitpython-icm20649

cd ~
git clone https://github.com/Mayitzin/ahrs.git
cd ahrs
sudo python3 setup.py install

### Neo Pixels
For device connecting to internet

sudo pip3 install rpi_ws281x adafruit-circuitpython-neopixel
pip install neopixel-plus

root access needed

sound needs to be turned off

https://learn.adafruit.com/neopixels-on-raspberry-pi/python-usage


### PPP
We will attempt local network over serial RX/TX. Make sure serial console is disabled but serial is enabled for interfaces.

https://docs.j7k6.org/raspberry-pi-ppp-network-serial-console/
https://www.instructables.com/Connect-the-Raspberry-Pi-to-network-using-UART/

https://docs.bitscope.com/pi-serial/
https://raspberrypi.stackexchange.com/questions/45570/how-do-i-make-serial-work-on-the-raspberry-pi3-pizerow-pi4-or-later-models/45571#45571

```
sudo apt-get install ppp
```

````
sudo raspi-config
```
Select option 5, "Interfacing Options"
Select option P6, "Serial" 
Select "No" to login shell and "Yes" to enabling serial port

Test serial speed with loop back between GPIO 24 and GPIO 15. Direct wire or 500-700 Ohm resistor.
https://di-marco.net/blog/it/2020-06-06-raspberry_pi_3_4_and_0_w_serial_port_usage/

'''
#!/usr/bin/env python
# -*- coding: utf-8 -*-
import serial
test_string = "Test serial port ...".encode('utf-8')
port_list = ["/dev/ttyAMA0","/dev/ttyAMA0","/dev/ttyS0","/dev/ttyS","/dev/Serial0"]
baud_list = [300,1200,2400,4800,9600,19200,38400,57600,115200,128000,256000]
for port in port_list:
  for baud in baud_list:
    try:
        serialPort = serial.Serial(port, baud, timeout = 2)
        print ("Serial port", port, " ready for test :")
        bytes_sent = serialPort.write(test_string)
        print ("Sended", bytes_sent, "byte")
        loopback = serialPort.read(bytes_sent)
        if loopback == test_string:
            print ("Received ",len(loopback), "bytes. Port", port," with ", baud " baud is OK ! \n")
        else:
            print ("Received incorrect data:", loopback, "on serial part", port, " with ", baud " baud, "loopback \n")
        serialPort.close()
    except IOError:
        print ("Error on", port,"\n")
'''    

Maybe '''sudo bash -c "echo 'init_uart_clock=64000000' >> /boot/config.txt"'''

For Pi 3 and Pi 0 W ONLY, decide whether to use the PL011 (which means Bluetooth will be degraded or nonfunctional) or miniUART (your serial connection may not work great but Bluetooth still will work). I have not tested this setup using miniUART, but I assume it would work OK. For PL011, you need to enable one of the device tree overlays that frees PL011 from Bluetooth use e.g. miniuart-bt and disable-bt as described in /boot/overlays/README

It might be necessary: to enable_uart=1 in /boot/config.txt

With sudo nano /boot/cmdline.txt remove the word phase "console=serial0,115200" or "console=ttyAMA0,115200"

Content of /etc/rc.local on server should be:
```
echo "Starting pppd..."
stty -F /dev/serial0 raw
pppd /dev/serial0 1000000 10.0.5.1:10.0.5.2 proxyarp local noauth debug nodetach dump nocrtscts passive persist maxfail 0 holdoff 1
```

On client Raspberry pi
```
sudo pppd /dev/serial0 115200 10.0.0.1:10.0.0.2 proxyarp local noauth debug nodetach dump nocrtscts passive persist maxfail 0 holdoff 1 &
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

### ZeroMQ
On both devices
sudo pip3 install pyzmq

### Network Time
On both devices
https://serverfault.com/questions/806274/how-to-set-up-local-ntp-server-without-internet-access-on-ubuntu

sudo apt install chrony

Client /etc/chrony/chrony.conf:

server 10.0.0.1 iburst
keyfile /etc/chrony/chrony.keys
driftfile /var/lib/chrony/chrony.drift
log tracking measurements statistics
logdir /var/log/chrony

Server /etc/chrony/chrony.conf:
keyfile /etc/chrony/chrony.keys
driftfile /var/lib/chrony/chrony.drift
log tracking measurements statistics
logdir /var/log/chrony
local stratum 8
manual
allow 10.0.0.0/24 allow 10.0.0.1

sudo systemctl stop chrony
sudo systemctl start chrony

sudo systemctl status chrony

chronyc tracking


### Speed up
On ODrive controlling device only

Disable hardware components we dont need:
```
sudo nano /boot/config.txt
```
Specifically
```
# Disable Audio
dtparam=audio=off

# Disable Splash Screen
disable_splash=1
# Disable boot delay, can no longer actiavte debug
boot_delay=0
# Overclock
force_turbo=1
[all]
# Don't need wifi
dtoverlay=disable-wifi
```
Now make boot quiet

```
sudo nano /boot/cmdline.txt
```
add ```loglevel=5 quiet``` after ```console=tty1```
add ```logo.nologo vt.global_cursor_default=0``` after ```rootwait```
change ```fsck.mode=skip```

Check out timing with

```
systemd-analyze # This shows kerne, user space and services.
systemd-analyze critical-chain # Shows dependencies
systemd-analyze blame # Each item
```

### Speed up by disabling services

Consider removing the following services

#### Verified to work

TODO Should look into systemd-timesyncd.service because don't care about time ```sudo systemctl disable systemd-timesyncd.service```
Should look into fschk-root as we dont need system to check drives
Should look into remount fs as we dont need access to boot device once verything is running

```
# Configure once, then leave as is
sudo systemctl disable raspi-config.service
# Run same program, will not need to adjust to programs booting by user
sudo systemctl disable dphys-swapfile.service 
# Don't care about keyboard
sudo systemctl disable keyboard-setup.service
# Will not want to flash EEPROM
sudo systemctl disable rpi-eeprom-update.service
# 3.0 Kernel 10.8 User **6.2** Target reached
# Don't need network at least no the items related to wlan0 and eth0
sudo systemctl disable NetworkManager.service
sudo systemctl disable wpa_supplicant.service
sudo systemctl disable ModemManager.service
# 3.0 Kernel 11.3 User **5.4** Target reached 
# Don't care about printing
sudo systemctl disable cups.service
sudo systemctl disable cups-browsed.service
# 2.9 Kernel 11.5 User **5.0** Target reached 
```

#### Working on

e2scrub_reap.service cleans up unused space on ext4 file systems. It is not essential.
glamor-test.service graphics driver for XWindows
user@1000.service  responsible for managing user-level services for a specific user with UID (User ID) of 1000. Is not essential
systemctl disable avahi-daemon.service that provides network service discovery on local networks, not essential but likely bluetooth needs it
modprobe@drm.service loads the drm (Direct Rendering Manager) kernel module during system startup, not sure if any additions are loeaded 

## Autologin from windows/max/linux to Raspian

On client, e.g. Windows Powershell
```
ssh-keygen
```
On Raspberry Pi:
```
sudo nano .ssh/authorized_keys
```
copy content of id_rsa.pub into file

## Remove CR from files
When you copy paste from windows into ssh terminal, you might insert CR-LF as line terminator. You only want LF. You can strip them in text files with:
```
sed 's/\r$//' in.txt > out.txt
```

## Bluetooth

To permanently install devices you need to manually pair and trust them 

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

### Bluetooth Event Handling
On my setup:
- event0  gamepad
- event1  gamepad
- event2  gamepad
- event3  regular
- js0     gamepad
- mice    regular
- mouse0  gamepad

mouse: Umido ESoul DH2 Mouse
```
REL_X -7 (left) ... +7 (right) 
REL_Y -7   (up) ... +7    (up)
BTN_LEFT       pushed value 1, released 0, large front button and also button A
```

keyboard: Umido ESoul DH2 Keyboard
```
KEY_ESC        pushed value 1, continuous 2, released 0 Second button and button B
KEY_VOLUMEUP   pushed value 1, continuous 2, released 0 Button C
KEY_VOLUMEDOWN pushed value 1, continuous 2, released 0 Button D
```

### Initial Scanning for Devices and Setting up Monitoring

```
# Keep  track of bluetooth device
class BTDevice(object):
    def __init__(self, name="", path="", device=None, poller=None, timeout=5):
        self.name    = name
        self.path    = path
        self.device  = device
        self.poller  = poller    
        self.timeout = timeout  # poller timeout in milliseconds

# Input devices to be watched
# Keypad and Joystick
input_pollInterval = 0.001 # how long to wait for next poll
joystick = BTDevice(name="Umido ESoul DH2 Mouse",    poller=select.poll(), timeout = 5)
keyboard = BTDevice(name="Umido ESoul DH2 Keyboard", poller=select.poll(), timeout = 5)

# UDEV Monitor
# Connection and disconnection monitor
monitor_pollInterval = 1 
monitorPoller  = select.poll()
context =  pyudev.Context()
monitor = pyudev.Monitor.from_netlink(context)
monitor.filter_by(subsystem='input')
monitor.start()
monitorPoller.register(monitor, 
                       select.POLLIN + select.POLLPRI + select.POLLHUP 
                       + select.POLLRDHUP + select.POLLNVAL + select.POLLERR )
                       # register all events except ready for output

# Logging
logging.basicConfig(level=logging.INFO) # options are: DEBUG, INFO, ERROR, WARNING
logger = logging.getLogger("GamePad")

# Initial scan
udevices = context.list_devices(subsystem='input')                  # list all input devices
for udev in udevices:
    if udev.device_node:                                            # only interested in devices with a device node
        if 'event' in udev.device_node:                             # only interested in event devices
            evdevice = InputDevice(udev.device_node)                # create event device
            if joystick.name == evdevice.name:                      # check if desired joystick was added          
                joystick.path = evdevice.path                       # keep track of path
                joystick.device = evdevice                          #
                joystick.poller.register(evdevice, select.POLLIN)   # poller
                logger.log(logging.INFO, "Observing Joystick {} at {} with {}.".format(evdevice.name,evdevice.path,evdevice.phys))
            elif keyboard.name == evdevice.name:                    # check if desired keyboard was added
                keyboard.path = evdevice.path                       # keep track of path
                keyboard.device = evdevice
                keyboard.poller.register(evdevice, select.POLLIN)
                logger.log(logging.INFO, "Observing Keyboard {} at {} with {}.".format(evdevice.name,evdevice.path,evdevice.phys))
            else:
                logger.log(logging.INFO, "System Event Device found {} at {} with {}. Not observing.".format(evdevice.name,evdevice.path,evdevice.phys))
        else:
            logger.log(logging.INFO, "System Input Device found {} with type ({}). Not observing.".format(udev.device_node, udev.device_type))
```

### Check for periodic device Addition or Removal
```
fdVsEvent = monitorPoller.poll(10)                          # timeout in milliseconds
for descriptor, event in fdVsEvent:
    logger.log(logging.DEBUG, "Monitor Descriptor: {} Event: {}".format(descriptor,event))
    if descriptor == monitor.fileno(): 
        for udev in iter(functools.partial(monitor.poll, 0), None):
            if udev.device_node:                            # we're only interested in devices that have a device node
                # Deal with Device Additions
                # ##########################
                if udev.action == 'add':
                    if 'event' in udev.device_node:         # only interested in event devices
                        evdevice = InputDevice(udev.device_node)    # create event device
                        if joystick.name == evdevice.name:  # check if desired joystick was added          
                            joystick.path = evdevice.path   # keep track of path
                            joystick.device = evdevice         
                            joystick.poller.register(evdevice, select.POLLIN)
                            logger.log(logging.INFO, "Observing Joystick {} at {} with {}.".format(evdevice.name,evdevice.path,evdevice.phys))
                        elif keyboard.name == evdevice.name: # check if desired keyboard was added
                            keyboard.path = evdevice.path   # keep track of path
                            keyboard.device = evdevice
                            keyboard.poller.register(evdevice, select.POLLIN)
                            logger.log(logging.INFO, "Observing Keyboard {} at {} with {}.".format(evdevice.name,evdevice.path,evdevice.phys))
                        else:
                            logger.log(logging.INFO, "System Event Device found {} at {} with {}. Not observing.".format(evdevice.name,evdevice.path,evdevice.phys))
                    else:
                        logger.log(logging.INFO, "System Input Device found {} with type ({}). Not observing.".format(udev.device_node, udev.device_type))
                # Deal with Device Removals
                # ##########################
                elif udev.action == 'remove':
                    # check if joystick was removed
                    if udev.device_node == joystick.path:
                        if joystick.device is not None:
                            joystick.poller.unregister(joystick.device)
                        joystick.path = ""
                        joystick.device = None
                        logger.log(logging.INFO, "Joystick {} removed.".format(joystick.name))
                    # check if keybaord was removed
                    elif udev.device_node == keyboard.path:
                        logger.log(logging.INFO, "Keyboard {} removed.".format(keyboard.name))
                        if keyboard.device is not None:
                            keyboard.poller.unregister(keyboard.device)
                        keyboard.path = ""
                        keyboard.device = None
                    else:
                        logger.log(logging.INFO, "Device {} removed.".format(udev.device_node))
                else:
                    logger.log(logging.INFO, "Unknown Action {} from {}.".format(udev.action, udev.device_node))

```

### Check for Input Events
```
fdVsEvent = joystick.poller.poll(joystick.timeout)
for descriptor, event in fdVsEvent:
    logger.log(logging.DEBUG, "Joystick Descriptor: {} Event: {}".format(descriptor, event))
    if event == select.POLLIN:
        if joystick.device is not None:
            for e in joystick.device.read():
                # Convert code, type in names
                print("Type: {}, Code: {}, Value: {}".format(ecodes.EV[e.type], ecodes.bytype[e.type][e.code], e.value))
                
                # Here interpret the event and call appropriate action

    elif event & select.POLLHUP:
        logger.log(logging.INFO, "Joystick disconnected.")
        joystick.poller.unregister(joystick.device)
        joystick.device = None
fdVsEvent = keyboard.poller.poll(keyboard.timeout)          # timeout in milliseconds
for descriptor, event in fdVsEvent:
    logger.log(logging.DEBUG, "Keyboard Descriptor: {} Event: {}".format(descriptor,event))
    if event == select.POLLIN:
        if keyboard.device is not None:
            for e in keyboard.device.read():
                print("Type: {}, Code: {}, Value: {}".format(ecodes.EV[e.type], ecodes.bytype[e.type][e.code], e.value))

                # Here interpret the event and call appropriate action

    elif event & select.POLLHUP:
        logger.log(logging.INFO, "Keyboard disconnected.")
        keyboard.poller.unregister(keyboard.device)
        keyboard.device = None
```

## Tankdrive
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