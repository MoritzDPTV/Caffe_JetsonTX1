#!/bin/sh
# Caffe installation script for Jetson TX1 by MDPTV



# Updating the system
sudo add-apt-repository universe
sudo apt-get update


# Install Git, CMake and Doxygen
sudo apt-get install git -y
sudo apt-get install cmake -y
sudo apt-get install doxygen -y


# General dependencies
sudo apt-get install libprotobuf-dev libleveldb-dev libsnappy-dev libhdf5-serial-dev libgflags-dev libgoogle-glog-dev liblmdb-dev libatlas-base-dev libopenblas-dev protobuf-compiler libgtk2.0-dev libgtk-3-dev libdc1394-22 libdc1394-22-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libavcodec-dev libavformat-dev libswscale-dev libxine2-dev libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev libv4l-dev libtbb2 libtbb-dev libfaac-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev libx264-dev liblapacke-dev libgdal-dev pkg-config unzip ffmpeg v4l-utils qtbase5-dev build-essential gfortran -y
sudo apt-get install --no-install-recommends libboost-all-dev libboost-filesystem-dev libboost-python-dev libboost-system-dev libboost-thread-dev -y


# Remaining Python dependencies
sudo apt-get install python python3 python-dev python3-dev python-numpy python3-numpy python-pip python-scipy python-pydot python-skimage python-sklearn python-all-dev python-h5py python-matplotlib python-opencv python-pil python-vtk -y
sudo pip install -U pip
sudo pip install django==1.11.9


# Clone Caffe v0.15.14
cd ~/
wget https://github.com/NVIDIA/caffe/archive/v0.15.14.tar.gz
tar -zxvf v0.15.14.tar.gz
rm v0.15.14.tar.gz
mv caffe-0.15.14/ ~/caffe


# Edit Python requirements and install missing
sudo sed -i '/leveldb>=0.191/d' ~/caffe/python/requirements.txt
sudo pip install -r ~/caffe/python/requirements.txt


# Create Makefile.config and install protocol
cd ~/caffe
cp Makefile.config.example Makefile.config
protoc src/caffe/proto/caffe.proto --cpp_out=.
mkdir include/caffe/proto
cp src/caffe/proto/caffe.pb.h include/caffe/proto


# Add libraries, paths and drivers
sudo sed -i 's/LIBRARIES += glog gflags protobuf boost_system boost_filesystem m hdf5_hl hdf5/LIBRARIES += glog gflags protobuf boost_system boost_filesystem m hdf5_serial_hl hdf5_hl hdf5_serial hdf5/' ~/caffe/Makefile
sudo sed -i 's/	LIBRARIES += opencv_core opencv_highgui opencv_imgproc/	LIBRARIES += opencv_core opencv_highgui opencv_imgproc opencv_imgcodecs/' ~/caffe/Makefile
sudo sed -i 's/        #ifndef __arm__/        #if !defined(__arm__) \&\&\ !defined(__aarch64__)/' ~/caffe/3rdparty/cub/host/mutex.cuh


# Enable of cuDNN, Python layers and OpenCV 3
sudo sed -i 's/# USE_CUDNN := 1/USE_CUDNN := 1/' ~/caffe/Makefile.config
sudo sed -i 's/# OPENCV_VERSION := 3/OPENCV_VERSION := 3/' ~/caffe/Makefile.config
sudo sed -i 's/# WITH_PYTHON_LAYER := 1/WITH_PYTHON_LAYER := 1/' ~/caffe/Makefile.config


# Add paths and right CUDA architecture settings
sudo sed -i 's|CUDA_DIR := /usr/local/cuda|CUDA_DIR := /usr/local/cuda-9.0|g' ~/caffe/Makefile.config
sudo sed -i 's/		-gencode arch=compute_50,code=compute_50/		-gencode arch=compute_53,code=sm_53 \\\n		-gencode arch=compute_53,code=compute_53/' ~/caffe/Makefile.config
sudo sed -i 's|INCLUDE_DIRS := $(PYTHON_INCLUDE) /usr/local/include|INCLUDE_DIRS := $(PYTHON_INCLUDE) /usr/local/include /usr/include/hdf5/serial|g' ~/caffe/Makefile.config
sudo sed -i 's|LIBRARY_DIRS := $(PYTHON_LIB) /usr/local/lib /usr/lib|LIBRARY_DIRS := $(PYTHON_LIB) /usr/local/lib /usr/lib /usr/lib/aarch64-linux-gnu /usr/lib/aarch64-linux-gnu/hdf5/serial|g' ~/caffe/Makefile.config


# To provide that caffe models with different image sizes can be launched
sudo sed -i "s/                raise ValueError('Mean shape incompatible with input shape.')/                print(self.inputs[in_])\\n                in_shape = self.inputs[in_][1:]\\n                m_min, m_max = mean.min(), mean.max()\\n                normal_mean = (mean - m_min) \\/ (m_max - m_min)\\n                mean = resize_image(normal_mean.transpose((1,2,0)),in_shape[1:]).transpose((2,0,1)) * (m_max - m_min) + m_min\\n                #raise ValueError('Mean shape incompatible with input shape.')/" ~/caffe/python/caffe/io.py


# To be able to call "import caffe" from Python and to run DIGITS
sudo sed -i  '$a export CAFFE_ROOT=/home/nvidia/caffe' ~/.bashrc
sudo sed -i  '$a export PYTHONPATH=/home/nvidia/caffe/python:$PYTHONPATH' ~/.bashrc
source ~/.bashrc


# Set MKL's float point operations to non-deterministic and avoid make errors
sudo sed -i '$a export MKL_CBWR=AUTO' ~/.profile
source ~/.profile
sudo ldconfig


# Build Caffe
mkdir build
cd build
cmake ../ -DCUDA_USE_STATIC_CUDA_RUNTIME=OFF
make -j"$(nproc)"
make pycaffe -j"$(nproc)"
sudo make install


# Runtest
#make test -j"$(nproc)"
#make runtest -j"$(nproc)"
