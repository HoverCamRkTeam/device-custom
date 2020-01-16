#!/bin/bash

CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/firefly-rk1808-buildroot.mk

# Kernel dts
export RK_KERNEL_DTS=rk1808-firefly-jd4
# Buildroot config
export RK_CFG_BUILDROOT=rockchip_rk1808_jd4
