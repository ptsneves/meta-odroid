SECTION = "kernel"
LICENSE = "GPLv2"
inherit kernel
require recipes-kernel/linux/linux-yocto.inc
LINUX_VERSION ?= "4.4.9"
PV = "4.9.57"
#KERNEL_VERSION_SANITY_SKIP="1"

SRCREV = "4e456eabc3be85aa8c3fe55cae757cd3a6544611"
SRC_URI = "git://github.com/hardkernel/linux.git;branch=odroidxu4-4.9.y;nocheckout=1 \
  file://0001-Removed-odroid-defconfigs-from-the-kernel-tree.patch \
  file://odroidxu4_modules_defconfig.cfg \
"

KERNEL_DEFCONFIG_odroid-xu4 = "odroidxu4_modules_defconfig"
COMPATIBLE_MACHINE = "(odroid-xu4)"
