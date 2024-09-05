#! @bash@/bin/sh

# This can end up being called disregarding the shebang.
set -e

shopt -s nullglob

export PATH=/empty
for i in @path@; do PATH=$PATH:$i/bin; done

usage() {
    echo "usage: $0 -f <firmware-dir> -d <boot-dir> -c <path-to-default-configuration>" >&2
    exit 1
}

default=               # Default configuration, needed for extlinux
fwtarget=/boot/firmware  # firmware target directory
boottarget=/boot         # boot configuration target directory

echo "uboot-builder: $@"
while getopts "c:d:f:" opt; do
    case "$opt" in
        c) default="$OPTARG" ;;
        d) boottarget="$OPTARG" ;;
        f) fwtarget="$OPTARG" ;;
        \?) usage ;;
    esac
done
# # process arguments for this builder, then pass the remainder to extlinux'
# while getopts ":f:" opt; do
#     case "$opt" in
#         f) target="$OPTARG" ;;
#         *) ;;
#     esac
# done
# shift $((OPTIND-2))
# extlinuxBuilderExtraArgs="$@"

copyForced() {
    local src="$1"
    local dst="$2"
    cp $src $dst.tmp
    mv $dst.tmp $dst
}

echo "copying firmware..."
@firmwareBuilder@ -c $default -d $fwtarget

echo "generating extlinux configuration..."
# Call the extlinux builder
@extlinuxConfBuilder@ -c $default -d $boottarget

# # Add the firmware files
# # fwdir=@firmware@/share/raspberrypi/boot/
# SRC_FIRMWARE_DIR=@firmware@/share/raspberrypi/boot

# DTBS=("$SRC_FIRMWARE_DIR"/*.dtb)
# for dtb in "${DTBS[@]}"; do
# # for dtb in $dtb_path/broadcom/*.dtb; do
#     dst="$target/$(basename $dtb)"
#     copyForced $dtb "$dst"
# done

# SRC_OVERLAYS_DIR="$SRC_FIRMWARE_DIR/overlays"
# SRC_OVERLAYS=("$SRC_OVERLAYS_DIR"/*)
# mkdir -p $target/overlays
# for ovr in "${SRC_OVERLAYS[@]}"; do
# # for ovr in $dtb_path/overlays/*; do
#     dst="$target/overlays/$(basename $ovr)"
#     copyForced $ovr "$dst"
# done

# STARTFILES=("$SRC_FIRMWARE_DIR"/start*.elf)
# BOOTCODE="$SRC_FIRMWARE_DIR/bootcode.bin"
# FIXUPS=("$SRC_FIRMWARE_DIR"/fixup*.dat)
# for SRC in "${STARTFILES[@]}" "$BOOTCODE" "${FIXUPS[@]}"; do
#     dst="$target/$(basename $SRC)"
#     copyForced "$SRC" "$dst"
# done

# # Add the config.txt
# copyForced @configTxt@ $target/config.txt

# Add the uboot file
copyForced @uboot@/u-boot.bin $fwtarget/@ubootBinName@
