# Odroid XU default BSP

include conf/machine/include/samsung-exynos.inc
include conf/machine/include/odroid-default-settings.inc

DEFAULTTUNE = "cortexa15hf-neon"
include conf/machine/include/tune-cortexa15.inc


UBOOT_FDT_LOADADDR ?= "0x40800000"
UBOOT_LOADADDR ?= "0x40007FC0"
UBOOT_CONSOLE ?= "console=ttySAC2,115200"
UBOOT_KENREL_NAME ?= "zimage"

IMAGE_ROOTFS_ALIGNMENT = "4096"

UBOOT_SCRIPT = "boot.scr"
