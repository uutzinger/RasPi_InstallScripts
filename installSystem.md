# Upgrade System
If you have not done already  
```
sudo apt-get update
sudo apt-get dist-upgrade -y
```
## Zram
```
git clone https://github.com/ecdye/zram-config
cd zram-config
sudo sh install.bash
```
Its usually not necessary to modify the zram settings
```
sudo nano /etc/ztab
```

## Conky
BME210 optional  
```
cd ~
sudo apt-get -y install conky-all
wget -O /home/pi/.conkyrc https://raw.githubusercontent.com/uutzinger/RasPi_InstallScripts/master/conkyrc
```
Setup desktop to autostart conky.
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
If you have not done already:
```
sudo raspi-config
```
* Enable Boot to Desktop, log in as user pi
* Enable VNC, I2C, SPI, Camera

## Setup video to create display even when no display is attached
This has changed in bullseye version and you should attempt raspi-config instead of editing /boot/config.txt.

## Visual Code 
Visual studio code needs more resouces than other editors but I still prefer it on RasPi. The binaries are available at Microsoft: 
https://code.visualstudio.com/#alt-downloads
Download the ARM debian version. Raspian is 32bit operating system. ARM64 will not work.  
Use the file explorerer and navigate to the Downloads folder and execute the downloaded_file.deb.  
Let the installation complete.  

## Python
```
cd ~
sudo apt-get -y install python3-dev
sudo apt-get -y install python3-pybind11
sudo apt-get -y install libusb-1.0-0-dev
sudo apt-get -y install swig
sudo apt-get -y install gfortran
sudo apt-get -y install python3-pip
sudo pip3 install -U setuptools
sudo pip3 install -U six wheel mock
sudo pip3 install -U numpy
```

### Python compiler, picamera, imutils
```
sudo pip3 install cython
sudo pip3 install "picamera[array]"
sudo pip3 install imutils
git clone https://github.com/jrosebr1/imutils.git
```

BME210 optional. This takes a long time  
```
sudo pip3 install scipy
sudo pip3 install scikit-image
```

BME210 optional. These will provide advanced face detection  
```
sudo pip3 install dlib
sudo pip3 install face_recognition
sudo pip3 install zmq
```

### Opencv
You can compile openCV and follow my installOpenCV instrutions.

For BME 210 and if you dont want to compile it, use:  
```
sudo pip3 install opencv-contrib-python==4.5.3.56
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
BME 210 optional  
This will install Open JDK 11 allowing you to program in Java on the Raspberry Pi.
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
Useful to test CSI and USB cameras.
```
sudo apt-get -y install cheese
sudo apt-get -y install luvcview
sudo apt-get -y install fswebcam
```
## Intel Thread Building Blocks
BME210 optional
Other packages can be accelerated with tbb. The link below takes least amoun of time for installation.
```
cd ~
wget https://github.com/PINTO0309/TBBonARMv7/raw/master/libtbb-dev_2019U5_armhf.deb
sudo dpkg -i ~/libtbb-dev_2019U5_armhf.deb
sudo ldconfig
rm libtbb-dev_2019U5_armhf.deb
```
## Build your own CMake
BME 210 optional
```
sudo apt-get -y install qt5-default
sudo apt-get -y install qtcreator
sudo apt-get -y install libssl-dev
git clone https://gitlab.kitware.com/cmake/cmake.git
cd cmake
./bootstrap --qt-gui -- -DCMAKE_BUILD_TYPE:STRING=Release 
make -j3
sudo apt remove cmake cmake-qt-gui
sudo make install
```
