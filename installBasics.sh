###!/bin/bash -e
#
# Much of this camre frome here:
# https://github.com/wpilibsuite/FRCVision-pi-gen/
#

# Set date closer to actual date, otherwise ntp might not work on your network
sudo date -s “Tue Nov 1 10:38:00 MST 2016”

# Add PGPG Key
#sudo apt-key add - < files/raspberry.gpg.key

##############################################################
#set hostname e.g. frcvision

# 1) Install packages and apps beyond standard buster installation
##################################################################

# Basics, are already on Buster
#
#sudo apt-get -y install raspi-config rpi-update
#sudo apt-get -y install netbase
#sudo apt-get -y install raspi-copies-and-fills
#sudo apt-get -y install ssh less fbset psmisc strace ed ncdu crda
#sudo apt-get -y install console-setup keyboard-configuration debconf-utils
#sudo apt-get -y install avahi-daemon
#sudo apt-get -y install luajit
#sudo apt-get -y install hardlink ca-certificates
#sudo apt-get -y install fake-hwclock usbutils
#sudo apt-get -y install dphys-swapfile
#sudo apt-get -y install raspberrypi-sys-mods 
#sudo apt-get -y install apt-listchanges
#sudo apt-get -y install usb-modeswitch
#sudo apt-get -y install libpam-chksshpwd
#sudo apt-get -y install libmtp-runtime
#sudo apt-get -y install htop
#sudo apt-get -y install policykit-1
#sudo apt-get -y install ssh-import-id
#sudo apt-get -y install rng-tools
#sudo apt-get -y install ethtool
#sudo apt-get -y install cifs-utils
#
sudo apt-get -y install coreutils vim quilt qemu-user-static 
sudo apt-get -y install debootstrap zerofree pxz zip unzip dosfstools
sudo apt-get -y install bsdtar libcap2-bin 
sudo apt-get -y install parted grep rsync xz-utils file git curl
sudo apt-get -y install xxd udev xz-utils
sudo apt-get -y install build-essential gdb cmake cmake-qt-gui unzip pkg-config 
sudo apt-get -y install daemontools daemontools-run
sudo apt-get -y install busybox-syslogd
sudo apt-get -y install gdbserver
sudo apt-get -y install lua5.2
# GTK programmers interface, takes a while
sudo apt-get -y install libgtkmm-3.0-dev libarchive-dev libcurl4-openssl-dev intltool
# Package maintenance
sudo apt-get -y install devscripts debhelper 
# Get the video and image libraries
sudo apt-get -y install v4l-utils
sudo apt-get -y install libjpeg-dev libpng-dev libtiff-dev libjasper-dev
sudo apt-get -y install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libavresample-dev
sudo apt-get -y install libxvidcore-dev libx264-dev
sudo apt-get -y install libgtk2.0-dev libgtk-3-dev
sudo apt-get -y install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
sudo apt-get -y install libcanberra-gtk*
sudo apt-get -y install libhdf5-dev
sudo apt-get -y install libqtwebkit4 libqt4-test
# Get numerical computation packages
sudo apt-get -y install libopenblas-dev liblapacke-dev
sudo apt-get -y install libatlas-base-dev libblas-dev gfortran
sudo apt-get -y install libboost-all-dev
sudo apt-get -y install libeigen{2,3}-dev liblapack-dev
# Network
#sudo apt-get -y install wpasupplicant wireless-tools 
#sudo apt-get -y install firmware-atheros firmware-brcm80211 
#sudo apt-get -y install firmware-libertas firmware-misc-nonfree firmware-realtek
#sudo apt-get -y install raspberrypi-net-mods
#sudo apt-get -y install dhcpcd5
#sudo apt-get -y install net-tools
sudo apt-get -y install ntp
sudo apt-get -y install libldap2-dev