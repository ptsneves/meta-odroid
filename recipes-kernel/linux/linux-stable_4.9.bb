FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:"

LINUX_VERSION ?= "4.9.56"

SRCREV ?= "9d36d3eff2f85efad0a3b0c6031081654ae33928"
SRC_URI = "git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git;branch=linux-4.9.y"

O_KERNEL_CONFIG_odroid-xu3  = "odroid-xu3"
O_KERNEL_CONFIG_odroid-xu4  = "odroid-xu3"
O_KERNEL_CONFIG_odroid-xu3-lite  = "odroid-xu3"
O_KERNEL_CONFIG_odroid-xu4s  = "odroid-xu4s"

require linux-stable.inc

COMPATIBLE_MACHINE = "(odroid-xu3|odroid-xu4|odroid-xu3-lite|odroid-xu4s)"
