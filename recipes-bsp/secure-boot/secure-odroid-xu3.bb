FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

require secure-odroid.inc

SRC_URI += "\
    file://bl2.bin.hardkernel \
    file://tzsw.bin.hardkernel \
    "

do_install_append () {
    	install -m 755  ${S}/bl2.bin.hardkernel ${D}/boot
    	install -m 755  ${S}/tzsw.bin.hardkernel ${D}/boot
}

do_deploy_append () {
    install -m 755  ${S}/bl2.bin.hardkernel ${DEPLOYDIR}
    install -m 755  ${S}/tzsw.bin.hardkernel ${DEPLOYDIR}
}

COMPATIBLE_MACHINE  = "(odroid-xu3|odroid-xu4|odroid-xu3-lite|odroid-xu4s)"
