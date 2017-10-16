# uboot-boot-scr.bbclass
#
# This provides a method to create a boot.ini or boot.scr files to help
# configure u-boot at boot up time
#
# UBOOT_LOADADDR: default kernel image load address, e.g., "0x01080000"
#
# UB_FDT_FILE: default device tree. e.g., "KERNEL_DEVICETREE"
#
# UBOOT_FDT_LOADADDR: default Device tree load address, e.g., "0x01000000"
#
# UB_INITRD_NAME: default initrd image name, e.g., "uInitrd"
#
# UB_INITRD_ADDR: default initrd image load address, e.g., "0x2000000"
#
# UBOOT_CONSOLE: default console, e.g.,  "ttyttySAC2,115200"
#
# UB_LOAD_CMD: default partition, e.g., "load"
#
# UBOOT_BOOTDEV: default boot device #
#
# UBOOT_BOOTPART: default boot partition #
#
# UBOOT_ROOTDEV: default root device #
#
# UBOOT_ROOTPART: default root device #
#
# UB_FILE_TITLE: default partition, e.g., "UBOOT-CONFIG"
#
# UB_EXTRA_ENV: default add extra env vars , e.g., "vout,'vga'"
#
# Copyright (C) 2017, Armin Kuster <akuster808@gmail.com> 
# All Rights Reserved Released under the MIT license (see packages/COPYING)
#

DEPENDS += "u-boot-mkimage-native"

# enable by default
USE_BOOTSCR ?=  '1'

UBOOT_ENV_SUFFIX ??= "scr"
UBOOT_ENV ?= "boot"
UBOOT_ENV_BINARY ?= "${UBOOT_ENV}.${UBOOT_ENV_SUFFIX}"
UBOOT_ENV_IMAGE ?= "${UBOOT_ENV}-${MACHINE}-${PV}-${PR}.${UBOOT_ENV_SUFFIX}"
UBOOT_ENV_SYMLINK ?= "${UBOOT_ENV}-${MACHINE}.${UBOOT_ENV_SUFFIX}"

UBOOT_ENV_CONFIG ?= "${B}/${UBOOT_ENV}.txt"

UBOOT_LOADADDR ?= "0x40007FC0"
UBOOT_FDT_LOADADDR ?= "0x40800000"
UBOOT_KENREL_NAME ?= "zimage"
UB_INITRD_NAME ?= ""
UB_INITRD_ADDR ?= ""

UBOOT_CONSOLE ?= "console=ttySAC2,115200"
UBOOT_BOOTDEV  ?= "0"
UBOOT_BOOTPART ?= "1"
UBOOT_ROOTDEV ?= ""
UBOOT_ROOTPART ?= "2"
UBOOT_BOOT_CMD ?= "bootz"

UB_LOAD_CMD ?= "load"
UB_EXTRA_ENV ?= ""
UB_FILE_TITLE ?= "#"

BASE_ENV_CONFIG = "${S}/base.cmd"

python create_uboot_boot_txt() {
    if d.getVar("USE_BOOTSCR", True) != "1":
      return

    if not d.getVar('WORKDIR', True):
        bb.error("WORKDIR not defined, unable to package")

    cfile = d.getVar('UBOOT_ENV_CONFIG', True)
    if not cfile:
        bb.fatal('Unable to read UBOOT_ENV_CONFIG')

    basefile = d.getVar('BASE_ENV_CONFIG', True)
    if not basefile:
        bb.fatal('Unable to read BASE_ENV_CONFIG')

    localdata = bb.data.createCopy(d)

    try:
        with open(cfile, 'w') as cfgfile:

            # Title for boot.ini on some boards
            title = localdata.getVar('UB_FILE_TITLE', True)
            if title:
                cfgfile.write('%s\n' % title)

            console = localdata.getVar('UBOOT_CONSOLE', True)
            if console:
                cfgfile.write('setenv console \"%s\" \n' % console) 
           
            loadcmd = localdata.getVar('UB_LOAD_CMD', True)
            cfgfile.write('setenv loadcmd \"%s\" \n' % loadcmd) 

            mmcbootdev = localdata.getVar('UBOOT_BOOTDEV', True)
            if mmcbootdev:
                cfgfile.write('setenv mmcbootdev %s\n' % mmcbootdev )

            mmcbootpart = localdata.getVar('UBOOT_BOOTPART', True)
            if mmcbootpart:
                cfgfile.write('setenv mmcbootpart %s\n' % mmcbootpart )

            mmcrootdev = localdata.getVar('UBOOT_ROOTDEV', True)
            if mmcrootdev:
                cfgfile.write('setenv mmcrootdev %s\n' % mmcrootdev)

            mmcrootpart = localdata.getVar('UBOOT_ROOTPART', True)
            if mmcrootpart :
                cfgfile.write('setenv mmcrootpart %s\n' % mmcrootpart )

            # initrd
            initrdaddr = localdata.getVar('UB_INITRD_ADDR', True)
            if initrdaddr:
                cfgfile.write('setenv initrdaddr  %s\n' % initrdaddr)

            initrd = localdata.getVar('UB_INITRD_NAME', True)
            if initrd:
                cfgfile.write('setenv initrdname  \"%s\"\n' % initrd) 

            kerneladdr = localdata.getVar('UBOOT_LOADADDR', True)
            cfgfile.write('setenv kerneladdr \"%s\"\n' % kerneladdr)

            fdtaddr = localdata.getVar('UBOOT_FDT_LOADADDR', True)
            cfgfile.write('setenv fdtaddr %s\n' % fdtaddr)

            fdtfile = os.path.basename(localdata.getVar('KERNEL_DEVICETREE', True))
            cfgfile.write('setenv fdtfile \"%s\"\n' % fdtfile)


            imgbootcmd = localdata.getVar('UBOOT_BOOT_CMD', True)
            cfgfile.write('setenv imgbootcmd \"%s\" \n' % imgbootcmd) 

            kernelname = localdata.getVar('UBOOT_KENREL_NAME', True)
            cfgfile.write('setenv kernelname %s\n' % kernelname)

            cfgfile.write('setenv loaddtb     \"${loadcmd} mmc ${mmcbootdev}:${mmcbootpart} ${fdtaddr} ${fdtfile}\"\n')
            cfgfile.write('setenv loadkernel  \"${loadcmd} mmc ${mmcbootdev}:${mmcbootpart} ${kerneladdr} ${kernelname}\"\n')

            if initrd:
                cfgfile.write('setenv loadinitrd  \"${loadcmd} mmc ${mmcbootdev}:${mmcbootpart} ${initrdaddr} ${initrdname}"\n')

            cfgfile.write('setenv bootargs \"${console} root=/dev/mmcblk1p${mmcrootpart} rw rootwait\"\n')
            cfgfile.write('run loaddtb\n')
            cfgfile.write('run loadkernel\n')

            if initrd:
                cfgfile.write('run loadinitrd\n')
                cfgfile.write('%s %s %s %s" %(imgbootcmd, kerneladdr, initrd_addr, fdtaddr))\n')
            else:
                cfgfile.write('%s %s - %s\n' % (imgbootcmd, kerneladdr, fdtaddr))

    except OSError:
        bb.fatal('Unable to open %s' % (cfile))
}

FILES_${PN} += "/*.${UBOOT_ENV_SUFFIX}"

do_compile[prefuncs] += "create_uboot_boot_txt"
