./repack_ramdisk boot.img-ramdisk  newramdisk.cpio.gz
./mkbootimg --cmdline 'no_console_suspend=1 console=null' --kernel zImage --ramdisk newramdisk.cpio.gz --base 0x05200000 -o boot.img
