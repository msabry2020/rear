set_syslinux_features

cp -L "$ISO_ISOLINUX_BIN" $BUILD_DIR/boot/isolinux.bin

make_syslinux_config $BUILD_DIR/boot isolinux >$BUILD_DIR/boot/isolinux.cfg

Log "Created isolinux configuration"

# add all files that we need for booting to ISO_FILES
ISO_FILES=( "${ISO_FILES[@]}" $BUILD_DIR/boot/* )


