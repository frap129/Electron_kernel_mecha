#!/bin/sh
# Copyright (C) 2011 Twisted Playground
# Copyright (C) 2015 Joe Maples
# This script was designed by Twisted Playground for use on MacOSX 10.7 but can be modified for other distributions of Mac and Linux
# It has been modified by Joe Maples for Linux and Electron kernel
PROPER=`echo $2 | sed 's/\([a-z]\)\([a-zA-Z0-9]*\)/\u\1\2/g'`
read -p "Do you wish to make Full or Core? Answer F or C" yn
    case $yn in
        [Ff]* ) export FULL=1
        [Cc]* ) export FULL=0
        * ) echo "Please answer F or C.";;
    esac
HANDLE=frap129
KERNELSPEC=~/mecha/
KERNELREPO=~/Desktop/mecha
TOOLCHAIN_PREFIX=~/saber/bin/arm-eabi-
PUNCHCARD=`date "+%m-%d-%Y_%H.%M"`
CPU_JOB_NUM=8
if [ -e $KERNELSPEC/mkboot.aosp/boot.img ]; then
rm -R $KERNELSPEC/mkboot.aosp/boot.img
fi
if [ -e $KERNELSPEC/mkboot.aosp/newramdisk.cpio.gz ]; then
rm -R $KERNELSPEC/mkboot.aosp/newramdisk.cpio.gz
fi
if [ -e $KERNELSPEC/mkboot.aosp/zImage ]; then
rm -R $KERNELSPEC/mkboot.aosp/zImage
fi
make clean -j$CPU_JOB_NUM
make -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PREFIX
# make nsio module here for now
cd nsio*
make CROSS_COMPILE=$TOOLCHAIN_PREFIX
cd ..
if [ -e arch/arm/boot/zImage ]; then
cp .config arch/arm/configs/electron_defconfig
if [ "$FULL" == "1" ]; then
KERNELOUT=zip.aosp
else
KERNELOUT=AnyKernel
fi
if [ `find . -name "*.ko" | grep -c ko` > 0 ]; then
find . -name "*.ko" | xargs ${TOOLCHAIN_PREFIX}strip --strip-unneeded
if [ ! -d $KERNELOUT/system ]; then
mkdir $KERNELOUT/system
fi
if [ ! -d $KERNELOUT/system/lib ]; then
mkdir $KERNELOUT/system/lib
fi
if [ ! -d $KERNELOUT/system/lib/modules ]; then
mkdir $KERNELOUT/system/lib/modules
else
rm -r $KERNELOUT/system/lib/modules
mkdir $KERNELOUT/system/lib/modules
fi
for j in $(find . -name "*.ko"); do
cp -R "${j}" $KERNELOUT/system/lib/modules
done
else
if [ -e $KERNELOUT/system/lib ]; then
rm -r $KERNELOUT/system/lib
fi
fi
if [ "$FULL" == "1" ]; then
zipfile=$HANDLE"_Electron_beta-Full.zip"
KENRELZIP="Electron_beta-$PUNCHCARD-Full.zip"
cp -R arch/arm/boot/zImage mkboot.aosp
cd mkboot.aosp
./img.sh
echo "building boot package"
cp -R boot.img ../$KERNELOUT/kernel
cd ../$KERNELOUT
else
zipfile=$HANDLE"_Electron_beta-Core.zip"
KENRELZIP="Electron_beta-$PUNCHCARD-Core.zip"
echo "building kernel package"
cp -R arch/arm/boot/zImage $KERNELOUT/kernel
cd $KERNELOUT
fi
rm *.zip
zip -r $zipfile *
cp -R $KERNELSPEC/$KERNELOUT/$zipfile $KERNELREPO/$zipfile
if [ -e $KERNELREPO/$zipfile ]; then
cp -R $KERNELREPO/$zipfile $KERNELREPO/$KENRELZIP
fi
fi
cd $KERNELSPEC
