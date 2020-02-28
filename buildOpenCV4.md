# Build OpenCV
Currently OpenCV 4 is not well supporterd by AllWPIlib and RobotPy


# Prepare
Add symbolic link for cblas.h to /usr/include (required by OpenCV)
```
cd ~
sudo ln -sf /usr/include/arm-linux-gnueabihf/cblas.h /usr/include/cblas.h
```
# Clone the Source

```
wget -O opencv.zip https://github.com/opencv/opencv/archive/4.2.0.zip
unzip opencv.zip
rm opencv.zip
mv opencv-4.2.0 opencv
wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.2.0.zip
unzip opencv_contrib.zip
rm opencv_contrib.zip
mv opencv_contrib-4.2.0 opencv_contrib
```

# Modify Code
Disable extranous USB camera warnings

```
cd ~/opencv
sed -i -e '/JWRN_EXTRANEOUS_DATA/d' 3rdparty/libjpeg/jdmarker.c
sed -i -e '/JWRN_EXTRANEOUS_DATA/d' 3rdparty/libjpeg-turbo/src/jdmarker.c
```

Get a patch to add openblas, tbb  support and atomic compliler/linker option

```
wget https://raw.githubusercontent.com/wpilibsuite/FRCVision-pi-gen/frcvision/stage3/01-sys-tweaks/files/opencv.patch
patch -p0 < opencv.patch
```

## Build Opencv
From https://www.learnopencv.com/install-opencv-4-on-raspberry-pi/

This builkd uses TBB, NEON, VFPV3 for raspi optimization For 4.1.1 you need to add -latomic and precompiled headers off and c++11 standard with 

```
mkdir build
cd build
these flags
cmake -D CMAKE_BUILD_TYPE=RELEASE \
      -D WITH_FFMPEG=OFF \
      -D WITH_GSTREAMER=ON \
      -D WITH_TBB=ON \
      -D WITH_V4L=ON \
      -D WITH_LIBV4L=ON \
      -D WITH_EIGEN=ON \
      -D BUILD_TBB=ON \
      -D BUILD_JPEG=ON \
      -D BUILD_TESTS=OFF \
      -D BUILD_EXAMPLES=ON \
      -D BUILD_JAVA=ON \
      -D BUILD_SHARED_LIBS=ON \
      -D BUILD_opencv_python3=ON \
      -D BUILD_opencv_java=ON \
      -D ENABLE_CXX11=ON \
      -D ENABLE_NEON=ON \
      -D ENABLE_VFPV3=ON \
      -D ENABLE_PRECOMPILED_HEADERS=OFF \
      -D WITH_LIBREALSENSE=ON \
      -D WITH_OPENGL=ON \
      -D INSTALL_PYTHON_EXAMPLES=ON \
      -D INSTALL_C_EXAMPLES=OFF \
      -D OPENCV_ENABLE_NONFREE=ON \
      -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
      -D OPENCV_GENERATE_PKGCONFIG=ON \
      -D PYTHON3_INCLUDE_PATH=/usr/include/python3.7m \
      -D PYTHON3_NUMPY_INCLUDE_DIRS=/usr/include/python3.7m/numpy \
      -D OPENCV_EXTRA_FLAGS_DEBUG=-Og \
      -D CMAKE_CXX_STANDARD_REQUIRED=ON \
      -D CMAKE_CXX_FLAGS=-latomic \
      -D OPENCV_EXTRA_EXE_LINKER_FLAGS=-latomic \
      -D CMAKE_CXX_STANDARD=11 \
      -D CMAKE_INSTALL_PREFIX=/usr/local \
      -D CMAKE_DEBUG_POSTFIX=d ..
```
If you like to inspect the make file
```
cmake-gui ../
```

// opencv-libs/now 4.1.1 armhf [installed,local]
// opencv-python/now 4.1.1 armhf [installed,local]


## Compile and Install
```
make -j3
sudo make install
sudo ldconfig
```
Work in progress: Java is no fully built
```
sudo cp -p lib/libopencv_java*.so "/usr/local/lib/"
sudo mkdir -p /usr/local/java
sudo cp -p bin/opencv-*.jar "/usr/local/java/"
```
