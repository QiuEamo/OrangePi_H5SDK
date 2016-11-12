#!/bin/bash
set -e
##########################################
##
##
## Build H5 Linux
##########################################
export ROOT=`pwd`
SCRIPTS=$ROOT/scripts
export BOOT_PATH
export ROOTFS_PATH
export UBOOT_PATH

root_check()
{
	if [ "$(id -u)" -ne "0" ]; then
		echo "This option requires root."
		echo "Pls use command: sudo ./build.sh"
		exit 0
	fi	
}

UBOOT_check()
{
	## Get mount path of U-disk
	echo "Pls input device node of SDcard.(like /dev/sdb)"
	for ((i = 1; i < 5; i++)); do
		read UBOOT_PATH
		if [ ! -b "$UBOOT_PATH" ]; then
			echo "Pls input correct path.(like /dev/sdb)"
		else
			i=200 
		fi 
	done
	if [ ! $i = "201" ]; then
		echo "Pls check your device node of SDcard"
		exit 0
	fi	
}

BOOT_check()
{
	## Get mount path of U-disk
	echo "Pls input mount path of BOOT.(like /media/orange/BOOT)"
	for ((i = 1; i < 5; i++)); do
		read BOOT_PATH
		echo "BOOT_PATH $BOOT_PATH"
		if [ ! -d "$BOOT_PATH" ]; then
			echo "Pls input correct path.(like /media/orange/BOOT)"
		else
			i=200 
		fi 
	done
	if [ ! $i = "201" ]; then
		echo "Pls check your mount path of BOOT"
		exit 0
	fi	
}

ROOTFS_check()
{
	## Get mount path of U-disk
	echo "Pls input mount path of ROOTFS.(like /media/orange/ROOTFS) "
	for ((i = 1; i < 5; i++)); do
		read ROOTFS_PATH
		if [ ! -d "$ROOTFS_PATH" ]; then
			echo "Pls input correct path.(like /media/orange/ROOTFS)"
		else
			i=200 
		fi 
	done
	if [ ! $i = "201" ]; then
		echo "Pls check your mount path of ROOTFS"
		exit 0
	fi
}

##########################################
clear
echo -e "\e[1;31m ======================================== \e[0m"
echo -e "\e[1;31m Welcome to OrangePi Build System \e[0m"
echo -e "\e[1;31m ======================================== \e[0m"
echo -e "\e[1;31m Pls select board \e[0m"
echo -e "\e[1;32m 0. OrangePi PC2 \e[0m"
echo -e "\e[1;32m 1. OrangePi 3 \e[0m"
read OPTION
if [ $OPTION = "0" ]; then
	export PLATFORM="OrangePiH5_PC2"
elif [ $OPTION = "1" ]; then
	export PLATFORM="OrangePiH5_3"
else
	echo -e "\e[1;31m Pls select correct platform \e[0m"
	exit 0
fi
clear
echo -e "\e[1;31m ================================== \e[0m"
echo -e "\e[1;31m Pls select build option \e[0m"
echo -e "\e[1;31m ================================== \e[0m"
echo -e "\e[1;32m 0. Build Release Image \e[0m"
echo -e "\e[1;32m 1. Build Rootfs \e[0m"
echo -e "\e[1;32m 2. Build Linux \e[0m"
echo -e "\e[1;32m 3. Build Kernel only\e[0m"
echo -e "\e[1;32m 4. Build Module only \e[0m"
echo -e "\e[1;31m ================================== \e[0m"
echo -e "\e[1;31m If update Image, pls use root \e[0m"
echo -e "\e[1;31m ================================== \e[0m"
echo -e "\e[1;32m 5. Install Image into SDcard \e[0m"
echo -e "\e[1;32m 6. Update kernel Image \e[0m"
echo -e "\e[1;32m 7. Update Module \e[0m"
echo -e "\e[1;32m 8. Update Uboot \e[0m"
echo -e "\e[1;32m a. Update SDK to Github \e[0m"
echo -e "\e[1;32m b. Update SDK from Github \e[0m"
read OPTION

clear

if [ $OPTION = "0" -o $OPTION = "1" ]; then
	clear
	TMP=$OPTION
	root_check
	echo -e "\e[1;31m =========================================== \e[0m"
	echo -e "\e[1;31m Pls Select Release Version \e[0m"
	echo -e "\e[1;32m 0. ArchLinux \e[0m"
	echo -e "\e[1;32m 1. Ubuntu_Xenial \e[0m"
	echo -e "\e[1;32m 2. Debian_Sid \e[0m"
	echo -e "\e[1;32m 3. Debian_Jessie \e[0m"
	echo -e "\e[1;32m 4. CenterOS \e[0m"
	read OPTION
	
	if [ ! -f $ROOT/output/uImage ]; then
		export BUILD_KERNEL=1
		cd $SCRIPTS
		./kernel_compile.sh
		cd -
	fi
	if [ ! -d $ROOT/output/lib ]; then
		export BUILD_MODULE=1
		cd $SCRIPTS
		./kernel_compile.sh
		cd -
	fi
	if [ $OPTION = "0" ]; then
		export DISTRO="arch"
	elif [ $OPTION = "1" ]; then
		export DISTRO="xenial"	
	elif [ $OPTION = "2" ]; then
		export DISTRO="sid"
	elif [ $OPTION = "3" ]; then
		export DISTRO="jessie"
	elif [ $OPTION = "4" ]; then
		export DISTRO="centeros"
	fi
	cd $SCRIPTS
	./rootfs_build.sh
	if [ $TMP = "0" ]; then 
		./build_image.sh
		echo -e "\e[1;31m ================================== \e[0m"
		echo -e "\e[1;31m Succeed to build Image \e[0m"
		echo -e "\e[1;31m ================================== \e[0m"
	fi
	exit 0
elif [ $OPTION = "2" ]; then
	export BUILD_KERNEL=1
	export BUILD_MODULE=1
	cd $SCRIPTS
	./kernel_compile.sh
	exit 0
elif [ $OPTION = "3" ]; then
	export BUILD_KERNEL=1
	cd $SCRIPTS
	./kernel_compile.sh
	exit 0
elif [ $OPTION = "4" ]; then
	export BUILD_MODULE=1
	cd $SCRIPTS
	./kernel_compile.sh
	exit 0
elif [ $OPTION = "5" ]; then
	clear
	root_check
	UBOOT_check
	clear
	dd bs=1M if=$ROOT/output/${PLATFORM}.img of=$UBOOT_PATH && sync
	clear
	echo -e "\e[1;31m =================================== \e[0m"
	echo -e "\e[1;31m Succeed Download Image into SDcard \e[0m"
	echo -e "\e[1;31m =================================== \e[0m"
	exit 0
elif [ $OPTION = '6' ]; then
	clear 
	root_check
	BOOT_check
	clear
	cd $SCRIPTS
	./kernel_update.sh $BOOT_PATH
	exit 0
elif [ $OPTION = '7' ]; then
	clear 
	root_check
	ROOTFS_check
	clear
	cd $SCRIPTS
	./modules_update.sh $ROOTFS_PATH
	exit 0
elif [ $OPTION = '8' ]; then
	clear
	root_check
	UBOOT_check
	clear
	cd $SCRIPTS
	./uboot_update.sh $UBOOT_PATH
	exit 0
elif [ $OPTION = 'a' ]; then
	clear
	git push -u origin master
	exit 0
elif [ $OPTION = 'b' ]; then
	clear
	git push origin
	exit 0
fi