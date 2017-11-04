require recipes-bsp/u-boot/u-boot-common_2017.01.inc
require recipes-bsp/u-boot/u-boot.inc
DEPENDS += "dtc-native"

# This revision corresponds to the tag "v2017.05"
# We use the revision in order to avoid having to fetch it from the
# repo during parse
SRC_URI = "git://github.com/hardkernel/u-boot.git;branch=odroidxu4-v2017.05 \
  file://0001-Enable-NETCONSOLE.patch \
"
SRCREV = "88af53fbcef8386cb4d5f04c19f4b2bcb69e90ca"
#SRCREV = "64c4ffa9fa223f7ae8640f9c8f3044bfa0e3bfda"
