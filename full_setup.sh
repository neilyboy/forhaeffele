#!/bin/bash

# --- User Input ---
USERNAME="pi"             # Replace with your actual username if different
KIOSK_URL="http://localhost:9876" # The URL to display in the kiosk
# --- End User Input ---

# Update package lists
sudo apt update

# Install dependencies
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release git unzip

# Set timezone
sudo timedatectl set-timezone America/Chicago

# Install Docker dependencies
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package lists again after adding the repo
sudo apt update

# Install Docker Engine, containerd, and Docker Compose
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add the current user to the docker group
sudo usermod -aG docker "$USERNAME"
newgrp docker

# Verify Docker installation
docker run hello-world

# Create Docker volume directories
sudo mkdir -p /home/docker/dockwatch
sudo mkdir -p /home/docker/posterr

# Install Dockwatch as a Docker container
docker run -d \
  --name dockwatch \
  --restart always \
  -p 8080:8080 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /home/docker/dockwatch:/config \
  ghcr.io/notifiarr/dockwatch:latest

echo "Docker, Docker Compose, and Dockwatch have been installed."
echo "Dockwatch is accessible at http://<your_raspberry_pi_ip>:8080"

# Install Posterr
git clone https://github.com/petersem/posterr /tmp/posterr
cd /tmp/posterr
unzip posterr-linux-armv7.zip
sudo mv posterr-linux-armv7 /opt/posterr
sudo chown -R root:root /opt/posterr
sudo chmod +x /opt/posterr/posterr

# Create a systemd service for Posterr
sudo cat << EOF | sudo tee /etc/systemd/system/posterr.service
[Unit]
Description=Posterr Service
After=network.target

[Service]
User=root
WorkingDirectory=/opt/posterr
ExecStart=/opt/posterr/posterr
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the Posterr service
sudo systemctl daemon-reload
sudo systemctl enable posterr.service
sudo systemctl start posterr.service

# Install Kiosk dependencies
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
if [ ! -f /etc
