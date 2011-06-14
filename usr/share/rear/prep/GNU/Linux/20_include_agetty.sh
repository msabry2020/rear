# For serial support we need to include the agetty binary, but Debian distro's
# use getty instead of agetty.

# Enable serial console if possible, when not specified
if [[ -z "$USE_SERIAL_CONSOLE" ]]; then
    for devnode in $(ls /dev/ttyS[0-9]* | sort); do
        if stty -F $devnode >&8 2>&1; then
            USE_SERIAL_CONSOLE=y
        fi
    done
fi

# Unless explicitly disabled
if [[ ! "$USE_SERIAL_CONSOLE" =~ ^[yY1] ]]; then
    return
fi

if has_binary getty; then
    # Debian, Ubuntu,...
    GETTY=getty
elif has_binary agetty; then
    # Fedora, RHEL, SLES,...
    GETTY=agetty
else
    # being desperate (not sure this is the best choice?)
    BugError "Could not find a suitable (a)getty for serial console. Please fix
$SHARE_DIR/prep/GNU/Linux/20_include_agetty.sh"
fi
Log "Serial Console support requested - adding required program '$GETTY'"

REQUIRED_PROGS=(
"${REQUIRED_PROGS[@]}"
"${GETTY}"
)
