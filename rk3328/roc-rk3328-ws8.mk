#!/bin/bash
# Target arch
export RK_ARCH=arm64
# Uboot defconfig
export RK_UBOOT_DEFCONFIG=firefly-rk3328
# Kernel defconfig
export RK_KERNEL_DEFCONFIG=rk3328-roc-ws8_defconfig
# Kernel dts
export RK_KERNEL_DTS=rk3328-roc-ws8
# boot image type
export RK_BOOT_IMG=boot.img
# parameter for GPT table
export RK_PARAMETER=parameter-ubuntu.txt
# recovery parameter for GPT table
export RK_SD_PARAMETER=parameter-recovery.txt
# packagefile for make update image 
export RK_PACKAGE_FILE=rk3328-ubuntu-package-file
# packagefile for make recovery image
export RK_SD_PACKAGE_FILE=rk3328-recovery-package-file
# Buildroot config
export RK_CFG_BUILDROOT=rockchip_rk3328_ws8
# Recovery config
export RK_CFG_RECOVERY=rockchip_rk3328_recovery
# Pcba config
export RK_CFG_PCBA=rockchip_rk3328_pcba
# Build jobs
export RK_JOBS=12
# target chip
export RK_TARGET_PRODUCT=rk3328
# Set rootfs type, including ext2 ext4 squashfs
export RK_ROOTFS_TYPE=ext4
# rootfs image path
export RK_ROOTFS_IMG=buildroot/output/$RK_CFG_BUILDROOT/images/rootfs.$RK_ROOTFS_TYPE
# Set oem partition type, including ext2 squashfs
export RK_OEM_FS_TYPE=ext2
# Set userdata partition type, including ext2, fat
export RK_USERDATA_FS_TYPE=ext2
# Set flash type. support <emmc, nand, spi_nand, spi_nor>
export RK_STORAGE_TYPE=emmc
#OEM config: /oem/dueros/aispeech/iflytekSDK/CaeDemo_VAD/smart_voice
export RK_OEM_DIR=oem_normal
#userdata config
export RK_USERDATA_DIR=userdata_normal
