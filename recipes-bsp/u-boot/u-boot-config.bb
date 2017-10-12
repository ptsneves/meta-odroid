DESCRIPTION = "Create u-boot boot config file"
SECTION = "bootloaders"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

inherit uboot-boot-scr

DEPENDS = "u-boot u-boot-mkimage-native"

USE_BOOTSRC ?= "0"

SRC_URI = "file://base.cmd"

S = "${WORKDIR}"

do_patch[noexec] = "1"
do_configure[noexec] = "1"

do_compile () {
    if [ "${UBOOT_ENV_SUFFIX}" = "scr" ]; then
        mkimage -C none -A arm -T script -d ${UBOOT_ENV_CONFIG} ${B}/${UBOOT_ENV_BINARY}
    else
        cp ${UBOOT_ENV_CONFIG} ${B}/${UBOOT_ENV_BINARY}
    fi
}

do_install () {
    if [ -n "${UBOOT_ENV}" ]
    then
        install -m 644 ${B}/${UBOOT_ENV_BINARY} ${D}/${UBOOT_ENV_IMAGE}
        ln -sf ${UBOOT_ENV_IMAGE} ${D}/${UBOOT_ENV_BINARY}
    fi
}

inherit deploy
addtask deploy before do_package after do_install

do_deploy () {
    install -d  ${DEPLOYDIR}
    if [ -n "${UBOOT_ENV}" ]
    then
        install -m 644 ${D}/${UBOOT_ENV_BINARY} ${DEPLOYDIR}/${UBOOT_ENV_IMAGE}
        ln -sf ${DEPLOYDIR}/${UBOOT_ENV_IMAGE} ${DEPLOYDIR}/boot.scr
    fi
}

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(odroid-c1|odroid-c2|odroid-xu3|odroid-xu4|odroid-xu3-lite)"
