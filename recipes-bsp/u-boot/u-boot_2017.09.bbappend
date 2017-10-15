FILESEXTRAPATHS_prepend := "${THISDIR}/u-boot:"
USE_BOOTSRC ?= "0"

inherit uboot-boot-scr

SRC_URI_append = " file://base.cmd"

do_compile_prepend () {
    if [ "${UBOOT_ENV_SUFFIX}" = "scr" ]; then
        mkimage -C none -A arm -T script -d ${UBOOT_ENV_CONFIG} ${WORKDIR}/${UBOOT_ENV_BINARY}
    else
        cp ${UBOOT_ENV_CONFIG} ${WORKDIR}/${UBOOT_ENV_BINARY}
    fi
}

COMPATIBLE_MACHINE = "(odroid-c1|odroid-c2|odroid-xu3|odroid-xu4|odroid-xu3-lite|odroid-xu4s)"
