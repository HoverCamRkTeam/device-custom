#!/bin/bash

# Target arch
export RK_ARCH=arm64
# Uboot defconfig
export RK_UBOOT_DEFCONFIG=evb-rk3308
# Kernel defconfig
export RK_KERNEL_DEFCONFIG=rk3308_linux_defconfig
# Kernel dts
export RK_KERNEL_DTS=rk3308-evb-dmic-pdm-v11
# boot image type
export RK_BOOT_IMG=boot.img
# parameter for GPT table
export RK_PARAMETER=parameter-nand-64bit-dueros.txt
# Buildroot config
export RK_CFG_BUILDROOT=rockchip_rk3308_release
# Recovery config
export RK_CFG_RECOVERY=rockchip_rk3308_recovery
# Pcba config
export RK_CFG_PCBA=rockchip_rk3308_pcba
# Build jobs
export RK_JOBS=12
# target chip
export RK_TARGET_PRODUCT=rk3308
# Set rootfs type, including ext2 ext4 squashfs
export RK_ROOTFS_TYPE=squashfs
# rootfs image path
export RK_ROOTFS_IMG=buildroot/output/$RK_CFG_BUILDROOT/images/rootfs.$RK_ROOTFS_TYPE
# Set oem partition type, including ext2 squashfs
export RK_OEM_FS_TYPE=ext2
# Set userdata partition type, including ext2, fat
export RK_USERDATA_FS_TYPE=ext2
# Set flash type. support <emmc, nand, spi_nand, spi_nor>
export RK_STORAGE_TYPE=emmc
#OEM config: /oem/dueros/aispeech/iflytekSDK/CaeDemo_VAD/smart_voice
export RK_OEM_DIR=baidu_spil_rk3308_64bit_6mic
#userdata config
export RK_USERDATA_DIR=userdata_empty
MIC_NUM=6