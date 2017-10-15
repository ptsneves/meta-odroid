DESCRIPTION = "Samsung secure bootloader for Odroid XU3 devices supported by the hardkernel product"
SECTION = "bootloaders"
LICENSE = "GPLv2"

LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

DEPENDS = "u-boot atf-native"

SRC_URI = "\
    file://aml_encrypt_gxb \
    file://bl2.package  \
    file://bl301.bin \
    file://bl30.bin \
    file://bl31.bin \
    file://bl1.bin.hardkernel \
    "


S = "${WORKDIR}"

do_patch[noexec] = "1"
do_configure[noexec] = "1"

do_compile[depends] += "u-boot:do_deploy"


do_compile () {
	cp ${DEPLOY_DIR_IMAGE}/u-boot-odroid-c2.bin ${S}/bl33.bin

	fip_create --bl30 ${WORKDIR}/bl30.bin --bl301 ${WORKDIR}/bl301.bin --bl31 ${WORKDIR}/bl31.bin --bl33 ${S}/bl33.bin ${B}/fip.bin
	fip_create --dump ${B}/fip.bin

	cat ${WORKDIR}/bl2.package fip.bin > ${B}/boot_new.bin
	${WORKDIR}/aml_encrypt_gxb --bootsig --input ${B}/boot_new.bin --output ${S}/u-boot.bin
	dd if=${S}/u-boot.bin of=${B}/u-boot.bin_signed bs=512 skip=96
}

do_install () {
        install -d ${D}/boot
        install -m 755  ${S}/bl1.bin.hardkernel ${D}/boot
}

FILES_${PN} = "/boot"

inherit deploy
do_deploy () {
    install -d ${DEPLOYDIR}
    install -m 755  ${S}/bl1.bin.hardkernel ${DEPLOYDIR}
    install -m 755  ${B}/u-boot.bin_signed ${DEPLOYDIR}/u-boot.bin
}

addtask deploy before do_build after do_compile

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE  = "odroid-c2"
