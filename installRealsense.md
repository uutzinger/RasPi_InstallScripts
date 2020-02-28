# Lib realsense

## Required Libraries

```
sudo apt-get install -y libdrm-amdgpu1 libdrm-dev libdrm-exynos1 libdrm-freedreno1 libdrm-nouveau2 libdrm-omap1 libdrm-radeon1 libdrm-tegra0 libdrm2
sudo apt-get install -y libglu1-mesa libglu1-mesa-dev glusterfs-common libglu1-mesa libglu1-mesa-dev libglui-dev libglui2c2
sudo apt-get install -y libglu1-mesa libglu1-mesa-dev mesa-utils mesa-utils-extra xorg-dev libgtk-3-dev libusb-1.0-0-dev
```

## Clone the Repository
Get a copy of RealSense and install USB signatures for the cameras.

```
cd ~
git clone https://github.com/IntelRealSense/librealsense.git
cd librealsense
sudo cp config/99-realsense-libusb.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && udevadm trigger 
```

## Update Library
```
nano ~/.bashrc
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
source ~/.bashrc
```

## Google Protobuf
Download and compile latest copy of Protobuf
```
cd ~
git clone https://github.com/google/protobuf.git
cd protobuf
./autogen.sh
./configure
make -j1
sudo make install
```
Now install the python bindings to Protobuf
```
cd python
export LD_LIBRARY_PATH=../src/.libs
python3 setup.py build --cpp_implementation 
python3 setup.py test --cpp_implementation
sudo python3 setup.py install --cpp_implementation
export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=cpp
export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION_VERSION=3
sudo ldconfig
protoc --version
```
## Intel Thread Building Blocks
Download a precompiled library

```
cd ~
wget https://github.com/PINTO0309/TBBonARMv7/raw/master/libtbb-dev_2019U5_armhf.deb
sudo dpkg -i ~/libtbb-dev_2019U5_armhf.deb
sudo ldconfig
rm libtbb-dev_2019U5_armhf.deb
```

## Configure Lib RealSense

```
cd ~/librealsense
mkdir  build  && cd build
cmake .. -DBUILD_EXAMPLES=true -DCMAKE_BUILD_TYPE=Release -DFORCE_LIBUVC=true
make -j4
sudo make install
```

Again for python bindings

```
cd ~/librealsense/build
#cmake .. -DBUILD_PYTHON_BINDINGS=bool:true -DPYTHON_EXECUTABLE=$(which python)
cmake .. -DBUILD_PYTHON_BINDINGS=bool:true -DPYTHON_EXECUTABLE=$(which python3)
make -j4
sudo make install
```

Upgrade shell environment
```
nano ~/.bashrc
```
add
```
export PYTHONPATH=$PYTHONPATH:/usr/local/lib
```
and import the new startup script
```
source ~/.bashrc
```

## RealSense likes OpenGL
```
sudo apt-get install python-opengl
sudo -H pip3 install pyopengl
sudo -H pip3 install pyopengl_accelerate
```
Enable Raspberry GL Driver
```
sudo raspi-config
```
Select
```
"8.Advanced Options" - "A7 GL Driver" - "G2 GL (Fake KMS)"
```

## Finish and Test
```
sudo reboot
~/librealsense/build/tools/realsense-viewer/realsense-viewer
```

# sudo apt autoremove libopencv4
# wget https://github.com/mt08xx/files/raw/master/opencv-rpi/libopencv4xxxx_armhf.deb
# sudo apt install -y ./libopencv4xxxx_armhf.deb
#sudo ldconfig
