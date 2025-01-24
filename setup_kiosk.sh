#!/bin/bash

# --- User Input ---
# Replace 'pi' with your actual username if different
USERNAME="pi"
# The URL to display in the kiosk
KIOSK_URL="http://localhost:9876"
# --- End User Input ---

# Update package lists
sudo apt update

# Install necessary packages
sudo apt install -y xorg matchbox-window-manager lightdm chromium-browser unclutter

# Configure autologin
sudo sed -i 's/#autologin-user=/autologin-user='"$USERNAME"'/g' /etc/lightdm/lightdm.conf
sudo sed -i 's/#autologin-user-timeout=0/autologin-user-timeout=0/g' /etc/lightdm/lightdm.conf

# Create autostart script
mkdir -p /home/"$USERNAME"/.config/lxsession/LXDE-pi/
cat << EOF | sudo tee /home/"$USERNAME"/.config/lxsession/LXDE-pi/autostart
@matchbox-window-manager
@xset s off
@xset -dpms
@xset s noblank
@unclutter -idle 1 -root
@chromium-browser --kiosk --disable-infobars --disable-session-crashed-bubble --no-first-run --disable-restore-session-state "$KIOSK_URL"
EOF

# Disable screen blanking (alternative method using xorg.conf.d - if the xset method above isn't sufficient)
# The xset method in the autostart is generally preferred, but this is a backup
if [ ! -f /etc/X11/xorg.conf.d/99-screensaver.conf ]; then
cat << EOF | sudo tee /etc/X11/xorg.conf.d/99-screensaver.conf
Section "Device"
    Identifier "Screen0"
    Option "DPMS" "false"
EndSection
EOF
fi

# Remove xscreensaver (optional but recommended)
sudo apt remove -y xscreensaver

echo "Kiosk setup complete."
echo "Rebooting in 5 seconds..."
sleep 5
sudo reboot
