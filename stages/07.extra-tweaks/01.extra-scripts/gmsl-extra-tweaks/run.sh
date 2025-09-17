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

install -m 644 "${BASH_SOURCE%%/run.sh}"/files/99-v3d.conf "${BUILD_DIR}/etc/X11/xorg.conf.d"

# 1. packages:
apt install v4l-utils qv4l2

apt install -y python3-pip git python3-jinja2 libboost-dev libgnutls28-dev openssl libtiff-dev pybind11-dev \
               qtbase5-dev libqt5core5a libqt5widgets meson cmake python3-yaml python3-ply libglib2.0-dev \
               libgstreamer-plugins-base1.0-dev g++ ninja-build pkg-config libyaml-dev libdw-dev libunwind-dev \
               libudev-dev libgstreamer1.0-dev libpython3-dev libevent-dev libdrm-dev libtiff-dev qt6-base-dev

git clone https://github.com/raspberrypi/libcamera.git
cd libcamera
meson setup build --buildtype=release -Dpipelines=rpi/vc4,rpi/pisp -Dipas=rpi/vc4,rpi/pisp -Dv4l2=true -Dgstreamer=enabled -Dtest=false -Dlc-compliance=disabled -Dcam=disabled -Dqcam=disabled -Ddocumentation=disabled -Dpycamera=enabled
ninja -C build install

# 2.python
pip install pixutils pykms pyv4l2

# 3. extra configs:

# Set the name of the machine to 'analog-rpi-gmsl'
echo "analog-rpi-gmsl" > /etc/hostname