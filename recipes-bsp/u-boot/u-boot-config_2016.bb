DESCRIPTION = "Create u-boot boot config file"
SECTION = "bootloaders"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
DEPENDS += "u-boot u-boot-mkimage-native"

inherit deploy

S = "${WORKDIR}"

SRC_URI = "file://autoboot.cmd"

do_patch[noexec] = "1"
do_configure[noexec] = "1"

do_compile (){
	sed -i 's/FDTADDR/${UBOOT_FDTADDR}/' ${S}/autoboot.cmd
	sed -i 's/INITADDR/${UBOOT_INITADDR}/' ${S}/autoboot.cmd
	sed -i 's/KERNEL_DEVICETREE/${KERNEL_DEVICETREE}/' ${S}/autoboot.cmd
        mkimage -C none -A arm -T script -d ${S}/autoboot.cmd ${S}/boot.scr
}

do_deploy() {
	install -d ${DEPLOYDIR}
	install  ${S}/boot.scr ${DEPLOYDIR}
}

addtask deploy before do_build after do_compile

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(odroid-xu3|odroid-xu4|odroid-xu3-lite)"