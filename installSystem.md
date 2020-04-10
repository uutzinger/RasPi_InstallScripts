# Upgrade System
```
sudo apt-get update
sudo apt-get dist-upgrade -y
```
## Zram
```
git clone https://github.com/StuartIanNaylor/zram-config
cd zram-config
sudo sh install.sh
```
if necessary modify the settings
```
sudo nano /etc/ztab
```

## Conky
```
cd ~
sudo apt-get -y install conky-all
wget -O /home/pi/.conkyrc https://raw.githubusercontent.com/novaspirit/rpi_conky/master/rpi3_conkyrc
```
Setup desktop to autostart conky. Work in progress
```
sudo nano /usr/bin/conky.sh
```
add the following to the file
```
#!/bin/sh
(sleep 4s && conky) &
exit 0
```
then
```
sudo nano /etc/xdg/autostart/conky.desktop 
```
add folliwing lines to the file
```
[Desktop Entry]
Name=conky
Type=Application
Exec=sh /usr/bin/conky.sh
Terminal=false
Comment=system monitoring tool.
Categories=Utility;
```

## Configure Raspi interfaces
```
sudo raspi-config
```
* Enable Boot to Desktop, log in as user pi
* Enable VNC, I2C, SPI, Camera

## Setup video to create display even when no display is attached
Configure for VNC even when no monitor is attached to system
This section is optional
```
sudo nano /boot/config.txt
```
add:
* hdmi_force_hotplug=1
* hdmi_group=1
* hdmi_mode=16

This gives you 720p or 1080p. I have not been able to get 1080p output.

## Visual Code 
This editor needs more resouces than others but I still prefer and it works on RasPi
```
wget https://packagecloud.io/headmelted/codebuilds/gpgkey
sudo apt-key add gpgkey
sudo -s
. <( wget -O - https://code.headmelted.com/installers/apt.sh )
exit
```

## Python
```
cd ~
sudo apt-get -y install python3-pybind11
sudo apt-get -y install python-pybind11
sudo apt-get -y install libusb-1.0-0-dev
sudo apt-get -y install swig
sudo apt-get -y install gfortran
wget https://bootstrap.pypa.io/get-pip.py
sudo python3 get-pip.py
sudo pip3 install --upgrade setuptools
```

### Python compiler, picamera, imutils
```
sudo pip3 install cython
sudo pip3 install "picamera[array]"
sudo pip3 install imutils
git clone https://github.com/jrosebr1/imutils.git
```
This is optional. It takes a long time
```
sudo pip3 install scipy
sudo pip3 install scikit-image
```
These will provide adanced face detection
```
sudo pip3 install dlib
sudo pip3 install face_recognition
sudo pip3 install zmq
```
### Opencv
If you dont want to compile openCV
```
sudo pip3 install opencv-contrib-python==4.1.0.25
```
### I/O 
Allow for digitial input output and its support tools
```
git clone https://github.com/adafruit/Adafruit_Python_PureIO.git
cd Adafruit_Python_PureIO
sudo python3 setup.py install
cd ..
git clone https://github.com/adafruit/Adafruit_Blinka.git
cd Adafruit_Blinka
sudo python3 setup.py install
cd ..
git clone https://github.com/adafruit/Adafruit_CircuitPython_HTU21D.git
cd Adafruit_CircuitPython_HTU21D
sudo python3 setup.py install
cd ..
git clone https://github.com/adafruit/Adafruit_CircuitPython_MotorKit.git
cd Adafruit_CircuitPython_MotorKit
sudo python3 setup.py install
cd ..
git clone https://github.com/uutzinger/meArmPi.git
```

## Java Development Environment
Open JDK 11
This section is needed if you want ot program in Java
```
sudo apt-get -y install ant java-common
sudo apt-get -y install openjdk-11-jdk
sudo update-alternatives --config javac
sudo update-alternatives --config java
sudo ldconfig
```
Update bash 
```
nano ~/.bashrc 
```
add

```
export ANT_HOME=/usr/share/ant
export PATH=${PATH}:${ANT_HOME}/bin
export JAVA_HOME=/usr/lib/jvm/openjdk-11
export PATH=${PATH}:$JAVA_HOME/bin
```

## Camera Viewer
Useful to test cameras.
```
sudo apt-get -y install cheese
sudo apt-get -y install luvcview
sudo apt-get -y install fswebcam
```
