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
sudo apt-get install libprotobuf-dev libleveldb-dev libsnappy-dev libhdf5-serial-dev libgflags-dev libgoogle-glog-dev liblmdb-dev libatlas-base-dev protobuf-compiler -y
sudo apt-get install --no-install-recommends libboost-all-dev libboost-filesystem-dev libboost-python-dev libboost-system-dev libboost-thread-dev build-essential gfortran -y


# Remaining Python dependencies
sudo apt-get install python-dev python-numpy python-pip python-scipy python-pydot python-skimage python-sklearn python-all-dev python-h5py python-matplotlib python-opencv python-pil -y
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
sudo sed -i 's|CUDA_DIR := /usr/local/cuda|CUDA_DIR := /usr/local/cuda-8.0|g' ~/caffe/Makefile.config
sudo sed -i 's/		-gencode arch=compute_50,code=compute_50/		-gencode arch=compute_53,code=sm_53 \\\n		-gencode arch=compute_53,code=compute_53/' ~/caffe/Makefile.config
sudo sed -i 's|INCLUDE_DIRS := $(PYTHON_INCLUDE) /usr/local/include|INCLUDE_DIRS := $(PYTHON_INCLUDE) /usr/local/include /usr/include/hdf5/serial|g' ~/caffe/Makefile.config
sudo sed -i 's|LIBRARY_DIRS := $(PYTHON_LIB) /usr/local/lib /usr/lib|LIBRARY_DIRS := $(PYTHON_LIB) /usr/local/lib /usr/lib /usr/lib/aarch64-linux-gnu /usr/lib/aarch64-linux-gnu/hdf5/serial|g' ~/caffe/Makefile.config


# To be able to call "import caffe" from Python and to run DIGITS
sudo sed -i  '$a export CAFFE_ROOT=/home/ubuntu/caffe' ~/.bashrc
sudo sed -i  '$a export PYTHONPATH=/home/ubuntu/caffe/python:$PYTHONPATH' ~/.bashrc
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
make install


# Runtest
#make test -j"$(nproc)"
#make runtest -j"$(nproc)"
