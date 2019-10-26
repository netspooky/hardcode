#!/bin/sh

echo "This will install all required prereqs for osspd"

sudo apt-get install fuse gcc fbset libfuse-dev libpulse-dev libasound-dev || exit 1

wget "http://downloads.sourceforge.net/project/osspd/ossp-1.3.2.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fosspd%2F&ts=1343919816&use_mirror=netcologne" -O ossp-1.3.2.tar.gz || exit 2

tar xzf ossp-1.3.2.tar.gz

cd ossp-1.3.2

make

sudo modprobe cuse
sudo ./osspd --dsp-maj=100
sudo chmod a+rw /dev/dsp
sudo chmod a+rw /dev/fb0
