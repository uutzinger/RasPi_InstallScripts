##############################################################
# Urs' desired RasPi Setup
##############################################################
sudo apt-get update
sudo apt-get dist-upgrade -y

# Zram
#############
git clone https://github.com/StuartIanNaylor/zram-config
cd zram-config
sudo sh install.sh
# modiy if necessary
#sudo nano /etc/ztab

# Conky
#######
# This section is optional
cd ~
sudo apt-get -y install conky-all
wget -O /home/pi/.conkyrc https://raw.githubusercontent.com/novaspirit/rpi_conky/master/rpi3_conkyrc
sudo nano /etc/xdg/autostart/conky.desktop 
# add folliwing lines to the file
[Desktop Entry]
Name=conky
Type=Application
Exec=sh /usr/bin/conky.sh
Terminal=false
Comment=system monitoring tool.
Categories=Utility;

# Configure Raspi interfaces
################
sudo raspi-config
# Enable Boot to Desktop, log in as user pi
# Enable VNC, I2C, SPI, Camera

# Setup video to create display even when no display is attached
################################################################
# Configure for VNC even when no monitor is attached to system
# This section is optional
sudo nano /boot/config.txt
add:
hdmi_force_hotplug=1
hdmi_group=2
hdmi_mode=85

# Visual Code 
# This editor needs more resouces than others but I still prefer and it works on RasPi
################################################################
wget https://packagecloud.io/headmelted/codebuilds/gpgkey
sudo apt-key add gpgkey
sudo -s
. <( wget -O - https://code.headmelted.com/installers/apt.sh )
apt-get install code-oss=1.29.0-1539702286
apt-mark hold code-oss # only above version runs on raspi
# apt-mark unhold code-oss
exit

# Python
#############
cd ~
sudo apt-get -y install python3-pybind11
sudo apt-get -y install python-pybind11
sudo apt-get -y install libusb-1.0-0-dev
sudo apt-get -y install swig
sudo apt-get -y install gfortran
wget https://bootstrap.pypa.io/get-pip.py
sudo python3 get-pip.py
sudo python2 get-pip.py
sudo pip3 install --upgrade setuptools

# Python compiler
# picamera
# imutils
#############
sudo pip3 install cython
sudo pip3 install "picamera[array]"
sudo pip3 install imutils
git clone https://github.com/jrosebr1/imutils.git
# The next two lines are optional
sudo pip3 install scipy
sudo pip3 install scikit-image
#
sudo pip3 install dlib
sudo pip3 install face_recognition
sudo pip3 install zmq
sudo pip3 install opencv-contrib-python==4.1.0.25

# I/O 
# Allow for digitial input output and its support tools
#############
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

# Java Development Environment
# Open JDK 11
##############
# This section is optional
sudo apt-get -y install ant java-common
sudo apt-get -y install openjdk-11-jdk
sudo update-alternatives --config javac
sudo update-alternatives --config java
sudo ldconfig
nano ~/.bashrc # add
export ANT_HOME=/usr/share/ant
export PATH=${PATH}:${ANT_HOME}/bin
export JAVA_HOME=/usr/lib/jvm/openjdk-11
export PATH=${PATH}:$JAVA_HOME/bin

# Camera Viewer
###############
# This section is optional
sudo apt-get -y install cheese
sudo apt-get -y install luvcview
sudo apt-get -y install fswebcam

