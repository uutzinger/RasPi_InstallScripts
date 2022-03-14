# Create Simple RTSP Server on Raspberry Pi or Similar Computer

The RTSP streamer is an H264 video server with gstreamer.
This will work for raspberry pi or jetson nano and likely any unix system.

## I have existing Installation and need to Connect or Change Settings

- Install gstreamer on your client and make a script as outline below in Receiver section.
- Make sure to connect ethernet cable between client and server
- Connect to client with ```ssh pi@bucketcamera0.local``` or similar
- Login with standard username and password
- Edit the run_streamer.sh if you need to make changes, see create shell script section below.
- You will be able to watch the stream with ```gst-launch-1.0 rtspsrc location=rtsp://hostname.local:8554/test latency=10 ! decodebin ! autovideosink```
- Best on windows is to create a batch file and run it with CLI. e.g. use notepad.exe edit file by entering above command and save it to desktop as ```watchstream.bat```. Double click the file and it should start the stream, given the server is connected and running.

## Dependencies

```
sudo apt-get -y install libjpeg-dev libtiff-dev libtiff5-dev libjasper-dev libpng-dev
sudo apt-get -y install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libavresample-dev
sudo apt-get -y install libxvidcore-dev libx264-dev
sudo apt-get -y install libtbb2 libtbb-dev libdc1394-22-dev libv4l-dev
sudo apt-get -y install libjasper-dev libhdf5-dev
sudo apt-get -y install libopenblas-dev liblapack-dev libatlas-base-dev libblas-dev libeigen{2,3}-dev
sudo apt-get -y install python3-numpy python3-dev python3-pip python3-mock
sudo apt-get -y install cmake gfortran
sudo apt-get -y install protobuf-compiler
sudo apt-get -y install libgtk2.0-dev libcanberra-gtk* libgtk-3-dev 
sudo apt-get -y install python3-pyqt5
sudo pip3 install opencv-contrib-python==4.1.0.25
```

## Install Server

Either Install pre built or build your own (not recommended) 

Check current verison with:
```
dpkg -l | grep gstream*
```
2/14/2022 this version 1.14.4

```
# install base and plugins
sudo apt-get install -y libgstreamer1.0-dev \
     libgstreamer-plugins-base1.0-dev \
     libgstreamer-plugins-bad1.0-dev \
     gstreamer1.0-plugins-ugly \
     gstreamer1.0-tools
# install some optional plugins
sudo apt-get install -y gstreamer1.0-gl gstreamer1.0-gtk3
# if you have Qt5 install this plugin
sudo apt-get install -y gstreamer1.0-qt5
# install if you want to work with audio
sudo apt-get install -y gstreamer1.0-pulseaudio
# perhaps useful also
sudo apt-get install -y gstreamer1.0-python3-plugin-loader
sudo apt-get install -y gstreamer1.0-rtsp
```

## Alternative: Installing latest gstreamer,build from source
Replace current version with a version of your choice  
Source: https://qengineering.eu/install-gstreamer-1.18-on-raspberry-pi-4.html

These apps might be helpful:  

https://github.com/jetsonhacks/camera-caps
https://github.com/jetsonhacks/gst-explorer

Continue with steps outline at the end or the QEngineering Website.

## Build and Install Gstramer RTSP server
You will need to build RTSP server regradless how you installed gstreamer.
RTSP server is not available on Windows.

```
sudo apt-get -y install gobject-introspection
sudo apt-get -y install libgirepository1.0-dev
sudo apt-get -y install gir1.2-gst-rtsp-server-1.0

# Download rtsp server version 1.14.4
wget https://gstreamer.freedesktop.org/src/gst-rtsp-server/gst-rtsp-server-1.14.4.tar.xz
tar -xf gst-rtsp-server-1.14.4.tar.xz
cd gst-rtsp-server-1.14.4
./configure --enable-introspection=yes
make
sudo make install
sudo ldconfig
```

## Test the Streams

```
cd ~/gst-rtsp-server-1.14.4/build/examples
# run the test pipeline
./test-launch "( videotestsrc ! x264enc ! rtph264pay name=pay0 pt=96 )"
# smaller number less output
export GST_DEBUG="*:5"
```
Watch with receiver as shonw below on Windows or on same computer.

## Create Shell Script to Simplify start of Server
Youi will want to simply the start of the servcer.

```
#! /bin/bash
cd /home/pi
./test-launch "( v4l2src device=/dev/video0 ! video/x-h264, width=1280, height=720, framerate=15/1 ! h264parse config-interval=1 ! rtph264pay name=pay0 pt=96 )" &
v4l2-ctl -c white_balance_auto_preset=10
v4l2-ctl -c auto_exposure=0
# v4l2-ctl -c exposure_time_absolute=10000
v4l2-ctl -c video_bitrate=500000
v4l2-ctl -c video_bitrate_mode=0
```

v4l2-ctl -l list camera options. You will need to program the following
- video bit rate
- autoexposure or set exposure time, often auto_exposre on means setting it to 0
- white balancing
- bitrate mode, you will want either constant bit rate or varibale bit rate
- if you have more than one camera you can change the camera device=/dev/video1 etc.

On jetson nano your script might need to look like:
```
./test-launch "v4l2src device=/dev/video0 ! nvvidconv ! nvv4l2h264enc insert-sps-pps=1 insert-vui=1 ! h264parse ! rtph264pay name=pay0"
```

## Run the Script at Boot
To run the above script each time the raspberry pi boots you edit
```
sudo nano /etc/rc.local
```
You add the following line before exit 0
```
/home/pi/run_streamer.sh >> /home/pi/run_streamer.log 2>&1
```

## Make the device Wired and Compliant
You might need to turn off wireless and bluetooth for your application.
You will want to set the hostname
```
sudo raspi-config
```
Set hostname under system

## Receiver
On windows machine instgall gstreamer from https://gstreamer.freedesktop.org/download/ using 64bit runtime installer for MSVC

Plug the server directly into your notebook computer and:

```
gst-launch-1.0 rtspsrc location=rtsp://hostname.local:8554/test latency=10 ! decodebin ! autovideosink
```

or use VLC
```
vlc rtsp://hostname.local:8554/test
```

# Build from source 1.18.4
Not recommended

## Remove the old version of gstreamer
```
sudo apt-get remove gstreamer1.0
sudo apt-get remove gstreamer-1.0

sudo rm -rf /usr/bin/gst-*
sudo rm -rf /usr/include/gstreamer-1.0
# install a few dependencies
sudo apt-get install -y cmake meson flex bison pkg-config
sudo apt-get install -y python3-dev
sudo apt-get install -y libglib2.0-dev libjpeg-dev libx264-dev
sudo apt-get install -y libgtk2.0-dev libcanberra-gtk* libgtk-3-dev
sudo apt-get install -y libasound2-dev
sudo apt-get install -y glib-2.0 
sudo apt-get install -y libcairo2-dev
sudo apt-get install -y gir1.2-gst-plugins-base-1.0
sudo apt-get install -y python-gi-dev
#sudo apt-get install -y libgirepository1.0-dev
```

## Download and unpack gstreamer
```
wget https://gstreamer.freedesktop.org/src/gstreamer/gstreamer-1.18.4.tar.xz
sudo tar -xf gstreamer-1.18.4.tar.xz
cd gstreamer-1.18.4
# make an installation folder
mkdir build && cd build
# run meson (a kind of cmake)
meson --prefix=/usr \
        --wrap-mode=nofallback \
        -D buildtype=release \
        -D gst_debug=true \
        -D package-origin=https://gstreamer.freedesktop.org/src/gstreamer/ \
        -D package-name="GStreamer 1.18.4 BLFS" ..
# build the software
ninja -j4
# test the software (optional)
ninja test
# install the libraries
sudo ninja install
sudo ldconfig
```

## Download and unpack base plugins
```
cd ~
wget https://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-1.18.4.tar.xz
sudo tar -xf gst-plugins-base-1.18.4.tar.xz
# make an installation folder
cd gst-plugins-base-1.18.4
mkdir build
cd build
# run meson
meson --prefix=/usr \
-D buildtype=release \
-D package-origin=https://gstreamer.freedesktop.org/src/gstreamer/ ..
ninja -j4
# optional
# ninja test
# install the libraries
sudo ninja install
sudo ldconfig
```

## Download and unpack good plugins
```
cd ~
sudo apt-get install -y libjpeg-dev
# download and unpack the plug-ins good
wget https://gstreamer.freedesktop.org/src/gst-plugins-good/gst-plugins-good-1.18.4.tar.xz
sudo tar -xf gst-plugins-good-1.18.4.tar.xz
cd gst-plugins-good-1.18.4
# make an installation folder
mkdir build && cd build
# run meson
meson --prefix=/usr       \
       -D buildtype=release \
       -D package-origin=https://gstreamer.freedesktop.org/src/gstreamer/ \
       -D package-name="GStreamer 1.18.4 BLFS" ..
ninja -j4
# optional
ninja test
# install the libraries
sudo ninja install
sudo ldconfig
```

## Download and unpack bad plugins
```
cd ~
# dependencies for RTMP streaming (YouTube)
sudo apt install -y librtmp-dev
sudo apt-get install -y libvo-aacenc-dev
# download and unpack the plug-ins bad
wget https://gstreamer.freedesktop.org/src/gst-plugins-bad/gst-plugins-bad-1.18.4.tar.xz
sudo tar -xf gst-plugins-bad-1.18.4.tar.xz
cd gst-plugins-bad-1.18.4
# make an installation folder
mkdir build && cd build
# run meson
meson --prefix=/usr       \
       -D buildtype=release \
       -D package-origin=https://gstreamer.freedesktop.org/src/gstreamer/ \
       -D package-name="GStreamer 1.18.4 BLFS" ..
ninja -j4
# optional
# ninja test
# install the libraries
sudo ninja install
sudo ldconfig
```

## Download and unpack ugly plugins
```
cd ~
# download and unpack the plug-ins ugly
wget https://gstreamer.freedesktop.org/src/gst-plugins-ugly/gst-plugins-ugly-1.18.4.tar.xz
sudo tar -xf gst-plugins-ugly-1.18.4.tar.xz
cd gst-plugins-ugly-1.18.4
# make an installation folder
mkdir build && cd build
# run meson
meson --prefix=/usr       \
      -D buildtype=release \
      -D package-origin=https://gstreamer.freedesktop.org/src/gstreamer/ \
      -D package-name="GStreamer 1.18.4 BLFS" ..
ninja -j4
# optional
ninja test
# install the libraries
sudo ninja install
sudo ldconfig

# test if the module exists (for instance x264enc)
gst-inspect-1.0 x264enc
# if not, make sure you have the libraries installed
# stackoverflow is your friend here
sudo apt-get install libx264-dev
# check which the GStreamer site which plugin holds the module
```

## download and unpack omxh264enc plugins
```
cd ~
# Download and unpack the plug-in gst-omx
wget https://gstreamer.freedesktop.org/src/gst-omx/gst-omx-1.18.4.tar.xz
sudo tar -xf gst-omx-1.18.4.tar.xz
cd gst-omx-1.18.4
# make an installation folder
mkdir build && cd build
# run meson
meson --prefix=/usr       \
       -D header_path=/opt/vc/include/IL \
       -D target=rpi \
       -D buildtype=release ..
ninja -j4
# optional
ninja test
# install the libraries
sudo ninja install
sudo ldconfig
```

## Download and unpack rtsp server
```
cd ~
wget https://gstreamer.freedesktop.org/src/gst-rtsp-server/gst-rtsp-server-1.18.4.tar.xz
tar -xf gst-rtsp-server-1.18.4.tar.xz
cd gst-rtsp-server-1.18.4
# make an installation folder
mkdir build && cd build
# run meson
meson --prefix=/usr       \
       --wrap-mode=nofallback \
       -D buildtype=release \
       -D package-origin=https://gstreamer.freedesktop.org/src/gstreamer/ \
       -D package-name="GStreamer 1.18.4 BLFS" ..
ninja -j4
# install the libraries
sudo ninja install
sudo ldconfig
```

sudo apt install gir1.2-gst-rtsp-server-1.0

## gst python
```

cd ~
wget https://gstreamer.freedesktop.org/src/gst-python/gst-python-1.18.4.tar.xz
tar -xf gst-python-1.18.4.tar.xz
cd gst-python-1.18.4
# make an installation folder
mkdir build && cd build
# run meson
meson --prefix=/usr       \
      -D buildtype=release \
      -D package-origin=https://gstreamer.freedesktop.org/src/gstreamer/ \
      -D package-name="GStreamer 1.18.4 BLFS" ..
ninja -j4
# install the libraries
sudo ninja install
sudo ldconfig
```

## Test the streams
```
cd ~/gst-rtsp-server-1.18.4/build/examples
# run the test pipeline
./test-launch "( videotestsrc ! x264enc ! rtph264pay name=pay0 pt=96 )"

# run camera pipeline
./test-launch "v4l2src device=/dev/video0 ! video/x-h264, width=640, height=480, framerate=30/1 ! h264parse config-interval=1 ! rtph264pay name=pay0 pt=96"
```

./test-launch "v4l2src device=/dev/video0 ! video/x-h264, width=640, height=480, framerate=30/1 ! h264parse config-interval=1 ! rtph264pay name=pay0 pt=96"

## Receiver
```
gst-launch-1.0 rtspsrc location=rtsp://192.168.178.32:8554/test/ latency=10 ! decodebin ! autovideosink
```

or

```
vlc rtsp://serverip:8554/test
```
