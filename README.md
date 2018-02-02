# Caffe compatible with DIGITS on JetsonTX1

This is a guide to install NVIDIA's Caffe v0.15.14 and required dependencies compatible with DIGITS v6.1.0 on the NVIDIA Jetson TX1 Development Kit. It is working on a system running L4T R24.2.1 (Ubuntu 16.04 64bit) with JetPack 3.0 installed. Caffe is a deep learning framework which is very useful and can be used e.g. for DIGITS or simply as library for Python.


## Preparing the system
Before we install Caffe, we need to install a few packages manually to avoid dependency and compiling issues.


### Uninstall LibreOffice
This step is optional and just in order to gain some more space, as LibreOffice isn't used on the Jetson TX1 anyway.
```sh
$ sudo apt-get remove --purge libreoffice*
$ sudo apt-get autoremove
$ sudo apt-get autoclean
```

### Install OpenBLAS
Only necessary if it isn't installed yet.
```sh
$ cd ~/
$ wget https://github.com/xianyi/OpenBLAS/archive/v0.2.20.tar.gz
$ tar -zxvf v0.2.20.tar.gz && rm v0.2.20.tar.gz
$ cd OpenBLAS-0.2.20
$ make -j"$(nproc)"
$ sudo make PREFIX=/usr install
```

### Install LevelDB
Only necessary if it isn't installed yet or your version is lower than *0.191*.
```sh
$ cd ~/
$ wget https://github.com/google/leveldb/archive/v1.20.tar.gz
$ tar -zxvf v1.20.tar.gz && rm v1.20.tar.gz
$ cd leveldb-1.20
$ make -j"$(nproc)"
$ sudo scp -r out-static/lib* out-shared/lib* /usr/local/lib/
$ cd include/
$ sudo scp -r leveldb /usr/local/include/
$ sudo ldconfig
$ cd ..
$ sudo rm -f /usr/local/lib/libleveldb*
$ sudo scp -r out-static/lib* out-shared/lib* /usr/local/lib/
```

### Install libjpeg-turbo
Only necessary if it isn't installed yet.
```sh
$ cd ~/
$ wget https://github.com/libjpeg-turbo/libjpeg-turbo/archive/1.5.3.tar.gz
$ tar -zxvf 1.5.3.tar.gz && rm 1.5.3.tar.gz
$ sudo rm -f /usr/lib/libjpeg.so*
$ cd libjpeg-turbo-1.5.3
$ autoreconf -fiv
$ ./configure --prefix=/usr \
--mandir=/usr/share/man \
--with-jpeg8 \
--disable-static \
--docdir=/usr/share/doc/libjpeg-turbo-1.5.3 &&
make
$ sudo make install
```

### Install OpenCV
Unfortunately the building process won't work if OpenCV 3.2.0 isn't installed with the right cmake values. That's why I **STRONGLY** recommend this reinstallation (remove the old *opencv* and *opencv_contrib* folder first, in case they exist).
```sh
$ sudo apt-get install build-essential cmake gfortran git pkg-config unzip doxygen ffmpeg qtbase5-dev python python3 python-dev python3-dev python-numpy python3-numpy libgtk2.0-dev libgtk-3-dev libdc1394-22 libdc1394-22-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libavcodec-dev libavformat-dev libswscale-dev libxine2-dev libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev libv4l-dev libtbb2 libtbb-dev libfaac-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev libx264-dev v4l-utils python-vtk liblapacke-dev libopenblas-dev libgdal-dev libatlas-base-dev -y
$ cd ~/
$ wget https://github.com/opencv/opencv/archive/3.2.0.tar.gz
$ tar -zxvf 3.2.0.tar.gz && rm 3.2.0.tar.gz
$ wget https://github.com/opencv/opencv_contrib/archive/3.2.0.tar.gz
$ tar -zxvf 3.2.0.tar.gz && rm 3.2.0.tar.gz
$ cd opencv-3.2.0
$ mkdir build
$ cd build
$ cmake -D WITH_CUDA=ON -D CUDA_ARCH_BIN="5.3" -D CUDA_ARCH_PTX="" -D WITH_GSTREAMER=ON -D WITH_OPENGL=ON -D WITH_LIBV4L=ON -D BUILD_TESTS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_EXAMPLES=OFF -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D ENABLE_PRECOMPILED_HEADERS=OFF -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib-3.2.0/modules ..
$ make -j"$(nproc)"
$ sudo make install
```
Note: The extracted source folders from the .tar.gz files can be deleted after running *make install* as everything needed is copied to /usr/local/ (eg: binaries in /usr/local/bin, man pages in /usr/local/man, libraries in /usr/local/lib, etc.). The source folder of Caffe, in turn, will be needed for DIGITS and shouldn't be deleted therefore.


## Finally we can install Caffe
The *jetson.clocks.sh* script will increase the performance of the Jetson TX1 by enabling all CPU cores and maximizing clock speeds on the CPUs and GPU. Restarting the system will reset the values.
```sh
$ cd ~/
$ git clone https://github.com/MoritzDPTV/Caffe_JetsonTX1.git
$ cd Caffe_JetsonTX1
$ sudo ./jetson_clocks.sh
$ ./install_caffe.sh
```
After a system reboot everything should work.
