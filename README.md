# Caffe for Jetson TX1
This is a guide to install NVIDIA's Caffe v0.15.14 and required dependencies compatible with DIGITS on the NVIDIA Jetson TX1 Development Kit. It is working on a system with JetPack 3.2 installed.



## Preparing the system
Before we install Caffe, we need to install a few libraries manually to avoid dependency and compiling issues.



### Install LevelDB
First we will install LevelDB, in case it isn't installed yet or your version is lower than *0.191*:

```sh
$ sudo apt-get install nasm autoconf
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
$ cd ~/
$ sudo rm -r leveldb-1.20
```


### Install libjpeg-turbo
Furthermore we have to install libjpeg-turbo, if it isn't installed yet:

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
$ cd ~/
$ sudo rm -r libjpeg-turbo-1.5.3
```



## Install Caffe
Now we can finally install Caffe, which then will work after a system reboot:

```sh
$ cd ~/
$ git clone https://github.com/MoritzDPTV/caffe_jetson_tx1.git
$ cd caffe_jetson_tx1
$ sudo ./jetson_clocks.sh
$ sudo ./install_caffe.sh
$ cd ~/
$ sudo rm -r caffe_jetson_tx1
```

Note: The 'jetson.clocks.sh' script will increase the performance of the Jetson by enabling all CPU cores and maximizing clock speeds on the CPUs and GPU. Restarting the system will reset the values.
