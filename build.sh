#!/bin/sh

TARGET=$1
UBOOT_VERSION=2015.10

case "$TARGET" in
    rpi_2)
        CROSS_COMPILE=arm-linux-gnueabi- ;;
    rpi_3)
        CROSS_COMPILE=aarch64-linux-gnu- ;;
    *)
        echo "Target not found"
        exit 1
esac

if ! curl -sSL https://github.com/u-boot/u-boot/archive/v$UBOOT_VERSION.tar.gz | tar zx; then
    echo "Failed to download u-boot source code"
    exit 1
fi

docker build -t connectedos/rpi-uboot-builder . || exit 1

docker run \
       --rm \
       -v /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro \
       -u $(id -u $USER):$(id -g $USER) \
       -v $PWD/u-boot-$UBOOT_VERSION:/usr/local/src/u-boot \
       -w /usr/local/src/u-boot \
       -e CROSS_COMPILE=$CROSS_COMPILE \
       -e TARGET=$TARGET \
       connectedos/rpi-uboot-builder \
       /bin/sh -c \
       'make ${TARGET}_defconfig && make -j$(nproc)'

if ! cp u-boot-$UBOOT_VERSION/u-boot.bin u-boot.$TARGET.bin; then
    echo "Failed to copy u-boot.bin"
    exit 1
fi

rm -rf u-boot-$UBOOT_VERSION
