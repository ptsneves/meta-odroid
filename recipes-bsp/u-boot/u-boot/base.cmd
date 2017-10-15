setenv loaddtb     "${loadcmd} mmc ${mmcbootdev}:${mmcbootpart} ${fdtaddr} ${fdtfile}"
setenv loadinitrd  "${loadcmd} mmc ${mmcbootdev}:${mmcbootpart} ${initrdaddr} ${initrdname}"
setenv loadkernel  "${loadcmd} mmc ${mmcbootdev}:${mmcbootpart} ${kerneladdr} ${kernelname}"
setenv kernel_args "setenv bootargs ${console} root=/dev/mmcblk1p${mmcrootpart} rootfstype=${rootfstype} rootwait ${opts}"

#### Routine: check_dtb - check that target.dtb exists on boot partition
setenv check_dtb "
if test -e mmc '${mmcbootdev}':'${mmcbootpart}' '${fdtfile}'; then
	run loaddtb;
	setenv fdt_addr ${fdtaddr};
else
	echo Warning! Booting without DTB: '${fdtfile}'!;
	setenv fdt_addr;
fi;"

#### Routine: check_ramdisk - check that uInitrd exists on boot partition
setenv check_ramdisk "
if test -e mmc '${mmcbootdev}':'${mmcbootpart}' '${initrdname}'; then
	echo "Found ramdisk image.";
	run loadinitrd;
	setenv initrd_addr ${initrdaddr};
else
	echo Warning! Booting without RAMDISK: '${initrdname}'!;
	setenv initrd_addr -;
fi;"

#### Routine: boot_fit - check that env $boardname is set and boot proper config of ITB image
setenv setboot_fit "
if test -e '${boardname}'; then
	setenv fdt_addr ;
	setenv initrd_addr ;
	setenv kernelname  Image.itb;
	setenv itbcfg      "\"#${boardname}\"";
	setenv imgbootcmd  bootm;
else
	echo Warning! Variable: \$boardname is undefined!;
fi"

#### Routine: setboot_uimg - prepare env to boot uImage
setenv setboot_uimg "
	setenv kernelname uImage;
	setenv itbcfg     ;
	setenv imgbootcmd bootm;
	run check_dtb;
	run check_ramdisk;"

#### Routine: setboot_zimg - prepare env to boot zImage
setenv setboot_zimg "
	setenv kernelname zImage;
	setenv itbcfg     ;
	setenv imgbootcmd bootz;
	run check_dtb;
	run check_ramdisk;"

#### Routine: boot_img - boot the kernel after env setup
setenv boot_img "
	run loadkernel;
	run kernel_args;
	'${imgbootcmd}' '${kerneladdr}${itbcfg}' '${initrd_addr}' '${fdt_addr}';"

#### Routine: autoboot - choose proper boot path
setenv autoboot "
if test -e mmc 0:${mmcbootpart} Image.itb; then
	echo Found kernel image: Image.itb;
	run setboot_fit;
	run boot_img;
elif test -e mmc 0:${mmcbootpart} zImage; then
	echo Found kernel image: zImage;
	run setboot_zimg;
	run boot_img;
elif test -e mmc 0:${mmcbootpart} uImage; then
	echo Found kernel image: uImage;
	run setboot_uimg;
	run boot_img;
fi;"

#### Execute the defined autoboot macro
run autoboot
