# Install Basic Libraris

Much of this camre frome here: https://github.com/wpilibsuite/FRCVision-pi-gen/

## Date
Set date closer to actual date, otherwise ntp might not work on your network
```
sudo date -s “Tue Nov 1 10:38:00 MST 2016”
```

## Hostname
Set hostname to the computer name you want e.g.  frcvision
```
sudo hostnamectl set-hostname your_host_name
```
Add your hostnmae to local host list
```
sudo nano /etc/hosts
```

If you conenct your raspberry with a wirex ethernet cable to your computer, you can establish a connections to hostname.local without needing to use a wireless accesspoint or configuring a network adapter. If you want your raspberry to connect to the world you will need a full network setup though (which you can do when connected to hostname.local via VNC). 

## Install packages and apps beyond standard installation

### Basics
```
sudo apt-get -y install coreutils quilt qemu-user-static debootstrap grep rsync xz-utils
sudo apt-get -y install zerofree pxz zip bsdtar parted gparted dosfstools file
sudo apt-get -y install cmake cmake-qt-gui vim git curl jq gdbserver lua5.2
sudo apt-get -y install daemontools daemontools-run
sudo apt-get -y install libarchive-dev libcurl4-openssl-dev intltool libcap2-bin
```

### Get the video and image libraries
```
sudo apt-get -y install libjpeg-dev libtiff-dev libtiff5-dev libjasper-dev
sudo apt-get -y install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libavresample-dev
sudo apt-get -y install libxvidcore-dev libx264-dev
```

### More
```
sudo apt-get -y install libfontconfig1-dev libcairo2-dev
sudo apt-get -y install libgdk-pixbuf2.0-dev libpango1.0-dev
```

### GTK 
```
sudo apt-get -y install libgtkmm-3.0-dev
sudo apt-get -y install libgtk2.0-dev libgtk-3-dev
sudo apt-get -y install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
sudo apt-get -y install libcanberra-gtk*
sudo apt-get -y install libhdf5-dev
```

### QT
```
sudo apt-get -y install python3-pyqt5
sudo apt-get -y install libqtwebkit4 libqt4-test
```

### Numerical computation packages
```
sudo apt-get -y install libopenblas-dev liblapacke-dev
sudo apt-get -y install libatlas-base-dev libblas-dev gfortran
sudo apt-get -y install libboost-all-dev
sudo apt-get -y install libeigen{2,3}-dev liblapack-dev
```

### Network
```
sudo apt-get -y install libldap2-dev
```
