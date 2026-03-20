#!/bin/bash

# Vitis setup
VITIS=/home/xilinx/2025.1/Vitis/settings64.sh

# XRT setup
XRT=/opt/xrt/2025.1/setup.sh
PETALINUX=/opt/petalinux/2025.1/environment-setup-cortexa72-cortexa53-amd-linux 
# Versal Common Image SDK setup (cross-compiler + sysroot)
COMMON_IMAGE_ENV=/opt/petalinux/2025.1/environment-setup-cortexa72-cortexa53-amd-linux 

echo "Sourcing Vitis..."
source $VITIS

echo "Sourcing XRT..."
source $XRT

echo "Sourcing Petalinux..."
source $PETALINUX

echo "Unsetting LD_LIBRARY_PATH for SDK safety..."
unset LD_LIBRARY_PATH

#echo "Sourcing Versal Common Image SDK environment..."
#source $COMMON_IMAGE_ENV

echo "Exporting ROOTFS and IMAGE..."
export ROOTFS=/opt/AMD/common_devices/xilinx-versal-common-v2025.1/rootfs.ext4
export IMAGE=/opt/AMD/common_devices/xilinx-versal-common-v2025.1/Image

echo "Exporting PLATFORM_REPO_PATHS..."
export PLATFORM_REPO_PATHS=/home/xilinx/2025.1/Vitis/base_platforms

echo "Environment setup complete."
