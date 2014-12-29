#!/bin/sh

# Simple script to get the job done

# Get Optimal Threading
IS_DARWIN=$(uname -a | grep Darwin)
if [ -n "$IS_DARWIN" ]; then
CPUS=$(sysctl hw.ncpu | awk '{print $2}')
DATE=gdate
else
CPUS=$(grep "^processor" /proc/cpuinfo | wc -l)
DATE=date


make clean && make mrproper && make electron_defconfig && make zImage -j"$CPUS"
