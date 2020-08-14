#!/bin/bash

apt update
apt install -y curl git live-build cdebootstrap
cd /media/mxana/A8A8-A710
git clone https://gitlab.com/kalilinux/build-scripts/live-build-config.git
cd live-build-config

./build.sh --variant xfce \
--verbose