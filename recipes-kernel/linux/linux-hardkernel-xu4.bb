SECTION = "kernel"
LICENSE = "GPLv2"
inherit kernel
require recipes-kernel/linux/linux-yocto.inc

#LINUX_VERSION ?= "4.14.8"
#PV = "4.14.8"
#SRCREV ?= "${AUTOREV}"
#SRC_URI = "git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git;branch=linux-4.14.y"

LINUX_VERSION ?= "4.14.24"
PV = "4.14.24"
SRCREV ?= "9b2015711d8d76fc29d473e4db4e2f653b47f653"
SRC_URI = "git://github.com/hardkernel/linux.git;branch=odroidxu4-4.14.y;nocheckout=1"

#PV = "4.9.57"
#SRCREV = "4e456eabc3be85aa8c3fe55cae757cd3a6544611"
#SRC_URI = "git://github.com/hardkernel/linux.git;branch=odroidxu4-4.9.y;nocheckout=1 
#file://0001-Removed-odroid-defconfigs-from-the-kernel-tree.patch 
#"

#SRC_URI += "   file://odroidxu4_modules_defconfig.cfg \
#  file://rndis_defconfig.cfg \
#"


KBUILD_DEFCONFIG_odroid-xu4 = "odroidxu4_defconfig"
COMPATIBLE_MACHINE = "(odroid-xu4)"
