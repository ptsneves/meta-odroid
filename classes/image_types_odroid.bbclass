inherit image_types

# Heavly influenced by image_types_fsl.bblcass
# Construct buildable Odroid-c2 SD  image according to the partition table  suggested by Hardkernel  at http://odroid.com/dokuwiki/doku.php?id=en:c2_partition_table
# tested with Odroid-c2 with EMMC only

IMAGE_TYPEDEP_sdcard = "${SDIMG_ROOTFS_TYPE}"

IMAGE_BOOTLOADER ?= "u-boot"

# Handle u-boot suffixes
UBOOT_SUFFIX ?= "bin"
UBOOT_SUFFIX_SDCARD ?= "${UBOOT_SUFFIX}"

#BOOT components
#15k
UBOOT_B1_POS ?= "1"

# Boot partition volume id
BOOTDD_VOLUME_ID ?= "${MACHINE}"

# Set alignment to 1MB [in KiB]
#IMAGE_ROOTFS_ALIGNMENT_odroid-xu = "4096"
#IMAGE_ROOTFS_ALIGNMENT_odroid-xu3 = "${IMAGE_ROOTFS_ALIGNMENT_odroid-xu}"
#IMAGE_ROOTFS_ALIGNMENT_odroid-xu3-lite = "${IMAGE_ROOTFS_ALIGNMENT_odroid-xu}"
#IMAGE_ROOTFS_ALIGNMENT_odroid-xu4 = "${IMAGE_ROOTFS_ALIGNMENT_odroid-xu}"
#IMAGE_ROOTFS_ALIGNMENT_odroid-c1 = "4096"
IMAGE_ROOTFS_ALIGNMENT_odroid-c2 = "1024"

SDIMG_ROOTFS_TYPE ?= "ext4"
SDIMG_ROOTFS = "${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.${SDIMG_ROOTFS_TYPE}"

# Boot partition size [in KiB] to get boot partition with size of 128M
BOOT_SPACE ?= "131000"

do_image_sdcard[depends] += "\
			parted-native:do_populate_sysroot \
			dosfstools-native:do_populate_sysroot \
                       	mtools-native:do_populate_sysroot \
                       	coreutils-native:do_populate_sysroot \
                       	virtual/kernel:do_deploy \
			${IMAGE_BOOTLOADER}:do_deploy \
			${@bb.utils.contains('KERNEL_IMAGETYPE', 'uImage', 'u-boot:do_deploy', '',d)} \
			"

SDCARD = "${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.sdcard"
SDCARD_ROOTFS ?= "${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ext4"
SDCARD_GENERATION_COMMAND_odroid-xu3= "generate_odroid_xu_sdcard"
SDCARD_GENERATION_COMMAND_odroid-xu4= "generate_odroid_xu_sdcard"
SDCARD_GENERATION_COMMAND_odroid-xu3-lite= "generate_odroid_xu_sdcard"
SDCARD_GENERATION_COMMAND_odroid-c1= "generate_odroid_c1_sdcard"
SDCARD_GENERATION_COMMAND_odroid-c2= "generate_odroid_c2_sdcard"

generate_odroid_c1_sdcard () {
	case "${IMAGE_BOOTLOADER}" in
		u-boot)
#write u-boot and first bootloader as done by the Hardkernel script sd_fusing.sh at http://dn.odroid.com/S905/BootLoader/ODROID-C2/c2_bootloader.tar.gz
           	dd if=${DEPLOY_DIR_IMAGE}/bl1.bin.hardkernel of=${SDCARD} conv=notrunc bs=1 count=442
           	dd if=${DEPLOY_DIR_IMAGE}/bl1.bin.hardkernel of=${SDCARD} conv=notrunc bs=512 skip=1 seek=1
         	dd if=${DEPLOY_DIR_IMAGE}/u-boot.${UBOOT_SUFFIX} of=${SDCARD} conv=notrunc bs=512 seek=64
		;;

		*)
		bberror "Unknown IMAGE_BOOTLOADER value"
		exit 1
		;;
	esac
}

generate_odroid_c2_sdcard () {
	case "${IMAGE_BOOTLOADER}" in
		u-boot)
#write u-boot and first bootloader as done by the Hardkernel script sd_fusing.sh at http://dn.odroid.com/S905/BootLoader/ODROID-C2/c2_bootloader.tar.gz
           	dd if=${DEPLOY_DIR_IMAGE}/bl1.bin.hardkernel of=${SDCARD} conv=notrunc bs=1 count=442
           	dd if=${DEPLOY_DIR_IMAGE}/bl1.bin.hardkernel of=${SDCARD} conv=notrunc bs=512 skip=1 seek=1
         	dd if=${DEPLOY_DIR_IMAGE}/u-boot.${UBOOT_SUFFIX} of=${SDCARD} conv=notrunc bs=512 seek=97
		;;

		*)
		bberror "Unknown IMAGE_BOOTLOADER value"
		exit 1
		;;
	esac
}

#
# Create an image that can by written onto a SD card using dd for use
# with Odroid BSP family
#
#  -------------------------------------
# |  Binary   | Block offset| part type |
# |   name    | SD   | eMMC |(eMMC only)|
#  -------------------------------------
# | Bl1       | 1    | 0    |  1 (boot) |
# | Bl2       | 31   | 30   |  1 (boot) |
# | U-boot    | 63   | 62   |  1 (boot) |
# | Tzsw      | 2111 | 2110 |  1 (boot) |
# | Uboot Env | 2625 | 2560 |  0 (user) |
#  -------------------------------------
#
# External variables needed:
#   ${SDCARD_ROOTFS}    - the rootfs image to incorporate
#   ${IMAGE_BOOTLOADER} - bootloader to use {Bl1, Bl2, u-boot, Tzsw, u-boot-env}
#
# The disk layout used is:
#
#    0                      -> IMAGE_ROOTFS_ALIGNMENT         - reserved to bootloader (not partitioned)
#    IMAGE_ROOTFS_ALIGNMENT -> BOOT_SPACE                     - kernel, dtb, boot.ini (fat)
#    BOOT_SPACE             -> SDIMG_SIZE                     - rootfs
#
#    Default Free space = 1.3x
#    Use IMAGE_OVERHEAD_FACTOR to add more space
#            2MiB               100MiB           SDIMG_ROOTFS
# <-----------------------> <----------> <---------------------->
#  ------------------------ ------------ ------------------------
# | IMAGE_ROOTFS_ALIGNMENT | BOOT_SPACE | ROOTFS_SIZE            |
#  ------------------------ ------------ ------------------------
# ^                        ^            ^                        ^
# |                        |            |                        |
# 0                      2048     2MiB +  100MiB       2MiB +  100Mib + SDIMG_ROOTFS

generate_odroid_xu_sdcard () {
	case "${IMAGE_BOOTLOADER}" in
		u-boot)
            dd if=${DEPLOY_DIR_IMAGE}/bl1.bin.hardkernel of=${SDCARD} conv=notrunc seek=${UBOOT_B1_POS}
            dd if=${DEPLOY_DIR_IMAGE}/bl2.bin.hardkernel of=${SDCARD} conv=notrunc seek=${UBOOT_B2_POS}
            dd if=${DEPLOY_DIR_IMAGE}/u-boot-dtb.${UBOOT_SUFFIX} of=${SDCARD} conv=notrunc seek=${UBOOT_BIN_POS}
            dd if=${DEPLOY_DIR_IMAGE}/tzsw.bin.hardkernel of=${SDCARD} conv=notrunc seek=${UBOOT_TZSW_POS}
            dd if=/dev/zero of=${SDCARD} seek=${UBOOT_ENV_POS} conv=notrunc count=32 bs=512
		;;

		*)
		bberror "Unknown IMAGE_BOOTLOADER value"
		exit 1
		;;
	esac
}

IMAGE_CMD_sdcard () {
	if [ -z "${SDCARD_ROOTFS}" ]; then
		bberror "SDCARD_ROOTFS is undefined. To use sdcard image from Odroid BSP it needs to be defined."
		exit 1
	fi
    rm -f ${WORKDIR}/boot.img
    # Align partitions
    BOOT_SPACE_ALIGNED=$(expr ${BOOT_SPACE} + ${IMAGE_ROOTFS_ALIGNMENT} - 1)
    BOOT_SPACE_ALIGNED=$(expr ${BOOT_SPACE_ALIGNED} - ${BOOT_SPACE_ALIGNED} % ${IMAGE_ROOTFS_ALIGNMENT})
    ROOTFS_SIZE=`du -bks ${SDIMG_ROOTFS} | awk '{print $1}'`
    # Round up RootFS size to the alignment size as well
    ROOTFS_SIZE_ALIGNED=$(expr ${ROOTFS_SIZE} + ${IMAGE_ROOTFS_ALIGNMENT} - 1)
    ROOTFS_SIZE_ALIGNED=$(expr ${ROOTFS_SIZE_ALIGNED} - ${ROOTFS_SIZE_ALIGNED} % ${IMAGE_ROOTFS_ALIGNMENT})
    SDIMG_SIZE=$(expr ${IMAGE_ROOTFS_ALIGNMENT} + ${BOOT_SPACE_ALIGNED} + ${ROOTFS_SIZE_ALIGNED})

    echo "Creating filesystem with Boot partition ${BOOT_SPACE_ALIGNED} KiB and RootFS ${ROOTFS_SIZE_ALIGNED} KiB"
    echo "Creating filesystem total size ${SDIMG_SIZE} KiB"

    # Initialize sdcard image file
    echo "dd if=/dev/zero of=${SDCARD} bs=1 count=0 seek=$(expr 1024 \* ${SDIMG_SIZE})"
    dd if=/dev/zero of=${SDCARD} bs=1 count=0 seek=$(expr 1024 \* ${SDIMG_SIZE})

    # Create partition table
    parted -s ${SDCARD} mklabel msdos
    # Create boot partition and mark it as bootable
    parted -s ${SDCARD} unit KiB mkpart primary fat16 ${IMAGE_ROOTFS_ALIGNMENT} $(expr ${BOOT_SPACE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT})
    # Create rootfs partition to the end of disk
    parted -s ${SDCARD} -- unit KiB mkpart primary ext2 $(expr ${BOOT_SPACE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT}) -1s
    parted ${SDCARD} print

    ${SDCARD_GENERATION_COMMAND}

    # create Boot partition
    BOOT_BLOCKS=$(LC_ALL=C parted -s ${SDCARD} unit b print \
        | awk '/ 1 / { print substr($4, 1, length($4 -1)) / 1024 }')
    echo "boot.img blocks ${BOOT_BLOCKS}"

    mkfs.vfat -n "Odroid" -S 512 -C ${WORKDIR}/boot.img ${BOOT_BLOCKS}

    DTS_BASE_NAME=`basename ${KERNEL_DEVICETREE} | awk -F "." '{print $1}'`
    UBOOT_SCRIPT_KERNEL=`echo ${UBOOT_KENREL_NAME} | awk '{print tolower($0)}'`
    export MTOOLS_SKIP_CHECK=1
    mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${MACHINE}.bin ::/${UBOOT_SCRIPT_KERNEL}
    mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${DTS_BASE_NAME}.dtb ::/${DTS_BASE_NAME}.dtb
    mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/${UBOOT_SCRIPT} ::/${UBOOT_SCRIPT}

    # Burn Partitions
    dd if=${WORKDIR}/boot.img of=${SDCARD} conv=notrunc seek=1 bs=$(expr ${IMAGE_ROOTFS_ALIGNMENT} \* 1024) && sync && sync
    dd if=${SDIMG_ROOTFS} of=${SDCARD} conv=notrunc seek=1 bs=$(expr 1024 \* ${BOOT_SPACE_ALIGNED} + ${IMAGE_ROOTFS_ALIGNMENT} \* 1024) && sync && sync

}
