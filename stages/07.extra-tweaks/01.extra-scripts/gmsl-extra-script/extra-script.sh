#!/bin/bash -e
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

############## GUIDELINES ##############

# - This script is run inside 'chroot'. 
# 	* it works as if Kuiper is running on a system with a few limitations
# 	* check 'chroot' documentation for more informations
# - This script is run as root, there is no need to use 'sudo' command.
# - Current directory is '/' (root) of the Kuiper rootfs.
# - If a file needs to be copied, it should be placed inside 'adi-kuiper-gen'.
# - If a variable from the configuration file is needed, source the config file to access its value.
# - At this stage the Kuiper image is not yet partitioned. In order to modify what will be in the boot partition access /boot folder.
# - This script will not be in the resulted image. If this is necessary it should be copied manually.

############## EXAMPLES ##############

# Source the config file to access configuration variables inside script
# source config

# Package installation
# apt install -y <package>

# Package installation without recommended packages (useful when Kuiper image size should be small)
# apt install -y <package> --no-install-recommends

# Copy a file placed in the examples folder to the current directory
# cp stages/07.extra-scripts/examples/<file-to-be-copied> .

# Enable a service 
# systemctl enable <service>.service

#cp stages/07.extra-tweaks/01.extra-scripts/gmsl-extra-script/files/99-v3d.conf /etc/X11/xorg.conf.d


# 1. packages:
apt-get update
# apt-get install -y git
apt-get install -y v4l-utils qv4l2 python3-jinja2

apt-get install -y g++ meson ninja-build pkg-config libyaml-dev python3-yaml python3-ply python3-jinja2 openssl libdw-dev libunwind-dev libudev-dev \
                libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libpython3-dev pybind11-dev \
                libevent-dev libdrm-dev libtiff-dev qt6-base-dev libboost-dev libfmt-dev

cd /usr/local/share/
git clone https://github.com/raspberrypi/libcamera.git
cd libcamera

meson setup build --buildtype=release -Dpipelines=rpi/vc4,rpi/pisp -Dipas=rpi/vc4,rpi/pisp -Dv4l2=true -Dgstreamer=enabled -Dtest=false -Dlc-compliance=disabled -Dcam=disabled -Dqcam=disabled -Ddocumentation=disabled -Dpycamera=enabled
ninja -C build install

# 2.python
apt-get install -y python3-pip

yes | pip3 install --break-system-packages pix-utils v4l2py
yes | pip3 install --break-system-packages git+https://github.com/tomba/pykms.git
yes | pip3 install --break-system-packages git+https://github.com/tomba/pixutils.git
mkdir -p /home/analog/Workspace
cd /home/analog/Workspace
git clone https://github.com/tomba/pyv4l2.git
yes | pip3 install --break-system-packages git+https://github.com/tomba/pyv4l2.git

# 3. extra configs:

# Set the name of the machine to 'analog-rpi-gmsl'
echo "analog-rpi-gmsl" > /etc/hostname
echo "127.0.1.1 analog-rpi-gmsl" >> /etc/hosts