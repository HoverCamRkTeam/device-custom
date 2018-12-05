#!/bin/bash

COMMON_DIR=$(cd `dirname $0`; pwd)
if [ -h $0 ]
then
        CMD=$(readlink $0)
        COMMON_DIR=$(dirname $CMD)
fi
cd $COMMON_DIR
cd ../../..
TOP_DIR=$(pwd)
COMMON_DIR=$TOP_DIR/device/rockchip/common
BOARD_CONFIG=$TOP_DIR/device/rockchip/.BoardConfig.mk
CFG_DIR=$TOP_DIR/device/rockchip
ROCKDEV=$TOP_DIR/rockdev
source $BOARD_CONFIG
PARAMETER=$TOP_DIR/device/rockchip/$RK_TARGET_PRODUCT/$RK_PARAMETER
SD_PARAMETER=$TOP_DIR/device/rockchip/$RK_TARGET_PRODUCT/$RK_SD_PARAMETER

if [ ! -n "$1" ];then
	echo "build all and save all as default"
	BUILD_TARGET=allsave
else
	BUILD_TARGET=$1
   	NEW_BOARD_CONFIG=$(find $CFG_DIR -name "$1")
fi

usage()
{
	echo "====USAGE: build.sh modules===="
	echo "uboot              -build uboot"
	echo "kernel             -build kernel"
	echo "extboot			 -build extlinux boot.img, boot from EFI partition"
	echo "rootfs             -build default rootfs, currently build buildroot as default"
	echo "buildroot          -build buildroot rootfs"
	echo "yocto              -build yocto rootfs, currently build ros as default"
	echo "ros                -build ros rootfs"
	echo "debian             -build debian rootfs"
	echo "pcba               -build pcba"
	echo "recovery           -build recovery"
	echo "all                -build uboot, kernel, rootfs, recovery image"
	echo "cleanall           -clean uboot, kernel, rootfs, recovery"
	echo "firmware           -pack all the image we need to boot up system"
	echo "updateimg          -pack update image"
	echo "sdbootimg          -pack sdboot image"
	echo "sdupdateimg        -pack sdupdate image"
	echo "save               -save images, patches, commands used to debug"
	echo "default            -build all modules"
    echo "BoardConfig Board  -select Board and it's BoardConfig.mk   "
}

function build_extboot_image() {

    build_kernel

	BOOT=${TOP_DIR}/kernel/extboot.img
	rm -rf ${BOOT}

	echo -e "\e[36m Generate extLinuxBoot image start\e[0m"

	# 100 Mb
	mkfs.vfat -n "boot" -S 512 -C ${BOOT} $((20 * 1024))

    echo "label kernel-4.4" > temp.conf
    echo "    kernel /Image" >> temp.conf
    echo "    fdt /${RK_KERNEL_DTS}.dtb" >> temp.conf

	mmd -i ${BOOT} ::/extlinux
	mcopy -i ${BOOT} -s temp.conf ::/extlinux/extlinux.conf
	mcopy -i ${BOOT} -s ${TOP_DIR}/kernel/arch/${RK_ARCH}/boot/dts/rockchip/${RK_KERNEL_DTS}.dtb ::
	mcopy -i ${BOOT} -s ${TOP_DIR}/kernel/arch/${RK_ARCH}/boot/Image ::

    rm temp.conf

	echo -e "\e[36m Generate extLinux Boot image : ${BOOT} success! \e[0m"
}

function build_uboot(){
	# build uboot
	echo "============Start build uboot============"
	echo "TARGET_UBOOT_CONFIG=$RK_UBOOT_DEFCONFIG"
	echo "========================================="
	if [ -f u-boot/*_loader_*.bin ]; then
		rm u-boot/*_loader_*.bin
	fi
	cd u-boot && ./make.sh $RK_UBOOT_DEFCONFIG && cd -
	if [ $? -eq 0 ]; then
		echo "====Build uboot ok!===="
	else
		echo "====Build uboot failed!===="
		exit 1
	fi
}

function build_kernel(){
	# build kernel
	echo "============Start build kernel============"
	echo "TARGET_ARCH          =$RK_ARCH"
	echo "TARGET_KERNEL_CONFIG =$RK_KERNEL_DEFCONFIG"
	echo "TARGET_KERNEL_DTS    =$RK_KERNEL_DTS"
	echo "=========================================="
	cd $TOP_DIR/kernel && make ARCH=$RK_ARCH $RK_KERNEL_DEFCONFIG && make ARCH=$RK_ARCH $RK_KERNEL_DTS.img -j$RK_JOBS && cd -
	if [ $? -eq 0 ]; then
		echo "====Build kernel ok!===="
	else
		echo "====Build kernel failed!===="
		exit 1
	fi
}

function build_buildroot(){
	# build buildroot
	echo "==========Start build buildroot=========="
	echo "TARGET_BUILDROOT_CONFIG=$RK_CFG_BUILDROOT"
	echo "========================================="
	/usr/bin/time -f "you take %E to build builroot" $COMMON_DIR/mk-buildroot.sh $BOARD_CONFIG
	if [ $? -eq 0 ]; then
		echo "====Build buildroot ok!===="
	else
		echo "====Build buildroot failed!===="
		exit 1
	fi
}

function build_rootfs(){
	build_buildroot
}

function build_ros(){
	# build ros
	echo "======Start build yocto======"
	echo "YOCTO_MACHINE=$YOCTO_MACHINE"
	echo "============================="
	/usr/bin/time -f "you take %E to build ros" $COMMON_DIR/mk-ros.sh $BOARD_CONFIG
	if [ $? -eq 0 ]; then
		echo "====Build ros ok!===="
	else
		echo "====Build ros failed!===="
		exit 1
	fi
}

function build_yocto(){
	build_ros
}

function build_debian(){
        # build debian
        echo "====Start build debian===="
	echo "TARGET_ARCH          =$RK_ARCH"
        echo "RK_ENABLE_MODULE     =$RK_ENABLE_MODULE"
	/usr/bin/time -f "you take %E to build debian" $COMMON_DIR/mk-debian.sh $RK_ENABLE_MODULE
        if [ $? -eq 0 ]; then
                echo "====Build debian ok!===="
        else
                echo "====Build debian failed!===="
                exit 1
        fi
}

function build_recovery(){
	# build recovery
	echo "==========Start build recovery=========="
	echo "TARGET_RECOVERY_CONFIG=$RK_CFG_RECOVERY"
	echo "========================================"
	/usr/bin/time -f "you take %E to build recovery" $COMMON_DIR/mk-recovery.sh $BOARD_CONFIG
	if [ $? -eq 0 ]; then
		echo "====Build recovery ok!===="
	else
		echo "====Build recovery failed!===="
		exit 1
	fi
}

function build_pcba(){
	# build pcba
	echo "==========Start build pcba=========="
	echo "TARGET_PCBA_CONFIG=$RK_CFG_PCBA"
	echo "===================================="
	/usr/bin/time -f "you take %E to build pcba" $COMMON_DIR/mk-pcba.sh $BOARD_CONFIG
	if [ $? -eq 0 ]; then
		echo "====Build pcba ok!===="
	else
		echo "====Build pcba failed!===="
		exit 1
	fi
}

function build_all(){
	echo "============================================"
	echo "TARGET_ARCH=$RK_ARCH"
	echo "TARGET_PLATFORM=$RK_TARGET_PRODUCT"
	echo "TARGET_UBOOT_CONFIG=$RK_UBOOT_DEFCONFIG"
	echo "TARGET_KERNEL_CONFIG=$RK_KERNEL_DEFCONFIG"
	echo "TARGET_KERNEL_DTS=$RK_KERNEL_DTS"
	echo "TARGET_BUILDROOT_CONFIG=$RK_CFG_BUILDROOT"
	echo "TARGET_RECOVERY_CONFIG=$RK_CFG_RECOVERY"
	echo "TARGET_PCBA_CONFIG=$RK_CFG_PCBA"
	echo "============================================"
	build_uboot
	build_kernel
	build_rootfs
	build_recovery
}

function clean_all(){
	echo "clean uboot, kernel, rootfs, recovery"
	cd $TOP_DIR/u-boot/ && make distclean && cd -
	cd $TOP_DIR/kernel && make distclean && cd -
	rm -rf buildroot/out
}

function build_firmware(){
	# mkfirmware.sh to genarate image
	./mkfirmware.sh $BOARD_CONFIG
	if [ $? -eq 0 ]; then
	    echo "Make image ok!"
	else
	    echo "Make image failed!"
	    exit 1
	fi
}

function build_sdbootimg(){
	IMAGE_PATH=$TOP_DIR/rockdev
	PACK_TOOL_DIR=$TOP_DIR/tools/linux/Linux_Pack_Firmware
    
	echo "Make sdboot.img"
	cd $PACK_TOOL_DIR/rockdev && ./mksdbootimg.sh && cd -
	mv $PACK_TOOL_DIR/rockdev/sdboot.img $IMAGE_PATH
	if [ $? -eq 0 ]; then
	   echo "Make sdboot image ok!"
	   echo "Img_path:$IMAGE_PATH/sdboot.img"
	else
	   echo "Make sdboot image failed!"
	   exit 1
	fi
}

function build_updateimg(){
	IMAGE_PATH=$TOP_DIR/rockdev
	PACK_TOOL_DIR=$TOP_DIR/tools/linux/Linux_Pack_Firmware
    
	echo "Make update.img"
	cd $PACK_TOOL_DIR/rockdev && ./mkupdate.sh && cd -
	mv $PACK_TOOL_DIR/rockdev/update.img $IMAGE_PATH
	if [ $? -eq 0 ]; then
	   echo "Make update image ok!"
	   echo "Img_path:$IMAGE_PATH/update.img"
	else
	   echo "Make update image failed!"
	   exit 1
	fi
}

function build_sdupdateimg(){
	IMAGE_PATH=$TOP_DIR/rockdev
	PACK_TOOL_DIR=$TOP_DIR/tools/linux/Linux_Pack_Firmware
    	echo "Make sdupdate.img"
	if [ -f $SD_PARAMETER ]
	then
		echo -n "create parameter..."
		ln -s -f $SD_PARAMETER $ROCKDEV/parameter.txt
		echo "done."
	else
		echo -e "\e[31m error: $SD_PARAMETER not found! \e[0m"
		exit 1
	fi

	if [[ x"$RK_SD_PACKAGE_FILE" != x ]];then
		RK_PACK_TOOL_DIR=$TOP_DIR/tools/linux/Linux_Pack_Firmware/rockdev/
		cd $RK_PACK_TOOL_DIR
		rm -f package-file
		ln -sf $RK_SD_PACKAGE_FILE package-file
	fi

	MKSDUPDATE_FILE=${RK_TARGET_PRODUCT}-mksdupdate.sh
	if [[ x"$MKSDUPDATE_FILE" != x-mksdupdate.sh ]];then
		rm -f mksdupdate.sh
		ln -s $MKSDUPDATE_FILE mksdupdate.sh
	fi

	cd $PACK_TOOL_DIR/rockdev && ./mksdupdate.sh && cd -
	mv $PACK_TOOL_DIR/rockdev/sdupdate.img $IMAGE_PATH

	if [ $? -eq 0 ]; then
	   echo "Make sdupdate image ok!"
	   echo "Img_path:$IMAGE_PATH/sdupdate.img"
	else
	   echo "Make sdupdate image failed!"
	fi

	if [ -f $PARAMETER ]
	then
		ln -s -f $PARAMETER $ROCKDEV/parameter.txt
	fi

	if [[ x"$RK_PACKAGE_FILE" != x ]];then
		RK_PACK_TOOL_DIR=$TOP_DIR/tools/linux/Linux_Pack_Firmware/rockdev/
		cd $RK_PACK_TOOL_DIR
		rm -f package-file
		ln -sf $RK_PACKAGE_FILE package-file
	fi
}

function build_save(){
	IMAGE_PATH=$TOP_DIR/rockdev
	DATE=$(date  +%Y%m%d.%H%M)
	STUB_PATH=Image/"$RK_KERNEL_DTS"_"$DATE"_RELEASE_TEST
	STUB_PATH="$(echo $STUB_PATH | tr '[:lower:]' '[:upper:]')"
	export STUB_PATH=$TOP_DIR/$STUB_PATH
	export STUB_PATCH_PATH=$STUB_PATH/PATCHES
	mkdir -p $STUB_PATH

	#Generate patches
	$TOP_DIR/.repo/repo/repo forall -c "$TOP_DIR/device/rockchip/common/gen_patches_body.sh"

	#Copy stubs
	$TOP_DIR/.repo/repo/repo manifest -r -o $STUB_PATH/manifest_${DATE}.xml
	mkdir -p $STUB_PATCH_PATH/kernel
	cp $TOP_DIR/kernel/.config $STUB_PATCH_PATH/kernel
	cp $TOP_DIR/kernel/vmlinux $STUB_PATCH_PATH/kernel
	mkdir -p $STUB_PATH/IMAGES/
	cp $IMAGE_PATH/* $STUB_PATH/IMAGES/

	#Save build command info
	echo "UBOOT:  defconfig: $RK_UBOOT_DEFCONFIG" >> $STUB_PATH/build_cmd_info
	echo "KERNEL: defconfig: $RK_KERNEL_DEFCONFIG, dts: $RK_KERNEL_DTS" >> $STUB_PATH/build_cmd_info
	echo "BUILDROOT: $RK_CFG_BUILDROOT" >> $STUB_PATH/build_cmd_info

}

function build_all_save(){
	build_all
	build_firmware
	build_updateimg
	build_save
}
#=========================
# build target
#=========================
if [ $BUILD_TARGET == uboot ];then
    build_uboot
    exit 0
elif [ $BUILD_TARGET == kernel ];then
    build_kernel
    exit 0
elif [ $BUILD_TARGET == extboot ];then
    build_extboot_image
    exit 0
elif [ $BUILD_TARGET == rootfs ];then
    build_rootfs
    exit 0
elif [ $BUILD_TARGET == buildroot ];then
    build_buildroot
    exit 0
elif [ $BUILD_TARGET == recovery ];then
    build_recovery
    exit 0
elif [ $BUILD_TARGET == pcba ];then
    build_pcba
    exit 0
elif [ $BUILD_TARGET == yocto ];then
    build_yocto
    exit 0
elif [ $BUILD_TARGET == ros ];then
    build_ros
    exit 0
elif [ $BUILD_TARGET == debian ];then
    build_debian
    exit 0
elif [ $BUILD_TARGET == updateimg ];then
    build_updateimg
    exit 0
elif [ $BUILD_TARGET == sdbootimg ];then
    build_sdbootimg
    exit 0
elif [ $BUILD_TARGET == sdupdateimg ];then
    build_sdupdateimg
    exit 0
elif [ $BUILD_TARGET == all ];then
    build_all
    exit 0
elif [ $BUILD_TARGET == firmware ];then
    build_firmware
    exit 0
elif [ $BUILD_TARGET == save ];then
    build_save
    exit 0
elif [ $BUILD_TARGET == cleanall ];then
    clean_all
    exit 0
elif [ $BUILD_TARGET == --help ] || [ $BUILD_TARGET == help ] || [ $BUILD_TARGET == -h ];then
    usage
    exit 0
elif [ $BUILD_TARGET == allsave ];then
    build_all_save
    exit 0
elif [ -f $NEW_BOARD_CONFIG ];then
    if [ ! -n "$NEW_BOARD_CONFIG" ];then
	    echo "==============================="
	    echo "ERR:  $1 not found  "
    	    echo "Can't found build config, please check again"
	    echo "ls device/rockchip/rkxxxx"
	    usage
	    exit 1
	fi
    echo $NEW_BOARD_CONFIG
    rm -f $BOARD_CONFIG
    ln -s $NEW_BOARD_CONFIG $BOARD_CONFIG
	unset RK_PACKAGE_FILE
	unset RK_MKUPDATE_FILE
	source $NEW_BOARD_CONFIG
	if [[ x"$RK_PACKAGE_FILE" != x ]];then
		PACK_TOOL_DIR=$TOP_DIR/tools/linux/Linux_Pack_Firmware/rockdev/
        cd $PACK_TOOL_DIR
		rm -f package-file
        ln -sf $RK_PACKAGE_FILE package-file
	fi
    
    MKUPDATE_FILE=${RK_TARGET_PRODUCT}-mkupdate.sh 
    if [[ x"$MKUPDATE_FILE" != x-mkupdate.sh ]];then
		PACK_TOOL_DIR=$TOP_DIR/tools/linux/Linux_Pack_Firmware/rockdev/
        cd $PACK_TOOL_DIR
        rm -f mkupdate.sh
		ln -sf $MKUPDATE_FILE mkupdate.sh
	fi
    exit 0
fi

