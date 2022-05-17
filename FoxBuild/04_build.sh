#!/bin/bash

set -e

export INSTALL_MOD_PATH="../alpine-minirootfs/"

# Build threads equall CPU cores
THREADS=$(getconf _NPROCESSORS_ONLN)

echo "      ____________  "
echo "    /|------------| "
echo "   /_|  .---.     | "
echo "  |    /     \    | "
echo "  |    \.6-6./    | "
echo "  |    /\`\_/\`\    | "
echo "  |   //  _  \\\   | "
echo "  |  | \     / |  | "
echo "  | /\`\_\`>  <_/\`\ | "
echo "  | \__/'---'\__/ | "
echo "  |_______________| "
echo "                    "
echo "   OneFileLinux.efi "

##########################
# Checking root filesystem
##########################

echo "----------------------------------------------------"
echo -e "Checking root filesystem\n"

# Clearing apk cache 
if [ "$(ls -A alpine-minirootfs/var/cache/apk/)" ]; then 
    echo -e "Apk cache folder is not empty: alpine-minirootfs/var/cache/apk/ \nRemoving cache...\n"
    rm alpine-minirootfs/var/cache/apk/*
fi

# Remove shell history
if [ -f alpine-minirootfs/root/.ash_history ]; then
    echo -e "Shell history found: alpine-minirootfs/root/.ash_history \nRemoving history file...\n"
    rm alpine-minirootfs/root/.ash_history
fi

# Clearing kernel modules folder 
if [ "$(ls -A alpine-minirootfs/lib/modules/)" ]; then 
    echo -e "Kernel modules folder is not empty: alpine-minirootfs/lib/modules/ \nRemoving modules...\n"
    rm -r alpine-minirootfs/lib/modules/*
fi

# Removing dev bindings
if [ -e alpine-minirootfs/dev/urandom ]; then
    echo -e "/dev/ bindings found: alpine-minirootfs/dev/urandom . Unmounting...\n"
    umount alpine-minirootfs/dev/urandom || echo -e "Not mounted. \n"
    rm alpine-minirootfs/dev/urandom
fi


## Check if console character file exist
#if [ ! -e alpine-minirootfs/dev/console ]; then
#    echo -e "ERROR: Console device does not exist: alpine-minirootfs/dev/console \nPlease create device file:  mknod -m 600 alpine-minirootfs/dev/console c 5 1"
#    exit 1
#else
#    if [ -d alpine-minirootfs/dev/console ]; then # Check that console device is not a folder 
#        echo -e  "ERROR: Console device is a folder: alpine-minirootfs/dev/console \nPlease create device file:  mknod -m 600 alpine-minirootfs/dev/console c 5 1"
#        exit 1
#    fi
#
#    if [ -f alpine-minirootfs/dev/console ]; then # Check that console device is not a regular file
#        echo -e "ERROR: Console device is a regular: alpine-minirootfs/dev/console \nPlease create device file:  mknod -m 600 alpine-minirootfs/dev/console c 5 1"
#    fi
#fi

# Print rootfs uncompressed size
echo -e "Uncompressed root filesystem size WITHOUT kernel modules: $(du -sh alpine-minirootfs | cut -f1)\n"


cd linux-5.15.40

##########################
# Bulding kernel
##########################
echo "----------------------------------------------------"
echo -e "Building kernel with initrams using $THREADS threads...\n"
make -j$THREADS

##########################
# Bulding kernel modules
##########################

echo "----------------------------------------------------"
echo -e "Building kernel mobules using $THREADS threads...\n"
make modules -j$THREADS

# Copying kernel modules in root filesystem
echo "----------------------------------------------------"
echo -e "Copying kernel modules in root filesystem\n"
make modules_install
echo -e "Uncompressed root filesystem size WITH kernel modules: $(du -sh ../alpine-minirootfs | cut -f1)\n"

# Creating modules.dep
echo "----------------------------------------------------"
echo -e "Copying modules.dep\n"
depmod -b ../alpine-minirootfs -F System.map  5.15.40-onefile

##########################
# Bulding kernel
##########################
echo "----------------------------------------------------"
echo -e "Building kernel with initrams using $THREADS threads...\n"
make -j$THREADS


##########################
# Get builded file
##########################

#rm /boot/efi/EFI/OneFileLinux.efi
#cp arch/x86/boot/bzImage /boot/efi/EFI/OneFileLinux.efi
cp arch/x86/boot/bzImage ../OneFileLinux.efi
#cd ..
echo "----------------------------------------------------"
echo -e "\nBuilded successfully: $(pwd)/OneFileLinux.efi\n"
echo -e "File size: $(du -sh ../OneFileLinux.efi | cut -f1)\n"
