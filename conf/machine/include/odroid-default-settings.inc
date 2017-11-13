# Odroid BSP default settings

PREFERRED_PROVIDER_virtual/xserver ?= "xserver-xorg"
XSERVER ?= "xserver-xorg \
           xf86-input-evdev \
           xf86-input-mouse \
           xf86-video-fbdev \
           xf86-input-keyboard"

PREFERRED_PROVIDER_virtual/kernel ?= "linux-stable"
PREFERRED_VERSION_linux-stable ?= "4.14%"
LINUX_VERSION_EXTENSION ?= "-odroid"

KERNEL_IMAGETYPE ?= "zImage"

PREFERRED_PROVIDER_virtual/bootloader ?= "u-boot"
PREFERRED_PROVIDER_u-boot ?= "u-boot"
PREFERRED_VERSION_u-boot ?= "2017.09"

UBOOT_ENV  ?= "boot"
UBOOT_BINARY ?= "u-boot-dtb.bin"
UBOOT_ENV_SUFFIX ?= "scr"

MACHINE_FEATURES = "serial usbgadget usbhost vfat ext2 alsa screen"
MACHINE_EXTRA_RRECOMMENDS += " kernel-modules kernel-devicetree"

IMAGE_FSTYPES_append = " ext4 sdcard"
