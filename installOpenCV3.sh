# Build OpenCV
###############
cd ~
# Add symbolic link for cblas.h to /usr/include (required by OpenCV)
sudo ln -sf /usr/include/arm-linux-gnueabihf/cblas.h /usr/include/cblas.h
wget -O opencv.zip https://github.com/opencv/opencv/archive/3.4.8.zip
unzip opencv.zip
rm opencv.zip
mv opencv-3.4.8 opencv
wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/3.4.8.zip
unzip opencv_contrib.zip
rm opencv_contrib.zip
mv opencv_contrib-3.4.8 opencv_contrib
cd ~/opencv
#sed -i -e 's/javac sourcepath/javac target="1.8" source="1.8" sourcepath/' modules/java/jar/build.xml.in
# Disable extranous USB camera warnings
sed -i -e '/JWRN_EXTRANEOUS_DATA/d' 3rdparty/libjpeg/jdmarker.c
sed -i -e '/JWRN_EXTRANEOUS_DATA/d' 3rdparty/libjpeg-turbo/src/jdmarker.c
# Get a patch to add openblas, tbb  support and atomic compliler/linker option
wget https://raw.githubusercontent.com/wpilibsuite/FRCVision-pi-gen/frcvision/stage3/01-sys-tweaks/files/opencv.patch
patch -p0 < opencv.patch
mkdir build
cd build
cmake -D CMAKE_BUILD_TYPE=RELEASE \
      -D WITH_FFMPEG=OFF \
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
      -D ENABLE_CXX11=ON \
      -D ENABLE_NEON=ON \
      -D ENABLE_VFPV3=ON \
      -D ENABLE_PRECOMPILED_HEADERS=OFF \
      -D INSTALL_PYTHON_EXAMPLES=ON \
      -D INSTALL_C_EXAMPLES=OFF \
      -D OPENCV_ENABLE_NONFREE=ON \
      -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
      -D OPENCV_GENERATE_PKGCONFIG=ON \
      -D PYTHON3_INCLUDE_PATH=/usr/include/python3.7m \
      -D PYTHON3_NUMPY_INCLUDE_DIRS=/usr/include/python3.7m/numpy \
      -D OPENCV_EXTRA_FLAGS_DEBUG=-Og \
      -D CMAKE_CXX_STANDARD=11 \
      -D CMAKE_INSTALL_PREFIX=/usr/local \
      -D CMAKE_DEBUG_POSTFIX=d ..
# If you like to inspect the make file
# cmake-gui ../
# cofigure & generate
make -j3
sudo make install
sudo ldconfig
sudo cp -p lib/libopencv_java*.so "/usr/local/lib/"
sudo mkdir -p /usr/local/java
sudo cp -p bin/opencv-*.jar "/usr/local/java/"
