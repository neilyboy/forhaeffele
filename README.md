# Raspberry Pi Full Setup: Docker, Dockwatch, Posterr, and Kiosk Mode

This script automates the full setup of a Raspberry Pi (running Raspbian Lite or similar) for running Docker, Docker Compose, Dockwatch (as a Docker container), Posterr (as a systemd service), and configuring it to boot directly into a fullscreen kiosk mode displaying a specified website.

## Prerequisites

*   A Raspberry Pi running Raspbian Lite (or a similar Debian-based OS).
*   Internet connectivity.
*   SSH access to the Raspberry Pi (recommended).

## Usage

1.  Save the script to a file (e.g., `full_setup.sh`).
2.  Make the script executable: `chmod +x full_setup.sh`.
3.  **Crucially:** Edit the script:
    *   Change `USERNAME="pi"` if your username is different.
    *   Change `KIOSK_URL="http://localhost:9876"` to the actual URL you want to display in the kiosk.
4.  Run the script with sudo: `sudo ./full_setup.sh`.

## What the script does

*   Updates the package lists.
*   Installs dependencies for Docker, Posterr, and the kiosk environment.
*   Sets the timezone to America/Chicago.
*   Adds Docker's official GPG key and repository.
*   Installs Docker Engine, containerd, and Docker Compose.
*   Adds the current user to the `docker` group.
*   Verifies the Docker installation.
*   Creates `/home/docker/dockwatch` and `/home/docker/posterr` directories for persistent data.
*   Installs Dockwatch as a Docker container, mounting the `/home/docker/dockwatch` directory and exposing it on port 8080.
*   Installs Posterr from the GitHub repository, placing the executable in `/opt/posterr`.
*   Creates a systemd service for Posterr to run on boot.
*   Installs Xorg, Matchbox Window Manager, LightDM, Chromium, and unclutter.
*   Configures autologin.
*   Creates an autostart script to launch Chromium in kiosk mode with the specified URL, disables screen blanking, and hides the cursor.
*   Optionally disables the screensaver.
*   Reboots the Raspberry Pi.

## Accessing Dockwatch

After the script completes and the Raspberry Pi reboots, you can access Dockwatch by opening a web browser and navigating to: http://<your_raspberry_pi_ip>:8080

Replace `<your_raspberry_pi_ip>` with the actual IP address of your Raspberry Pi. You can find this by running `hostname -I` on the Raspberry Pi.

## Accessing Posterr (if applicable)

Posterr runs as a background service. If it has a web interface or other access method, consult the Posterr documentation for instructions.

## Important Considerations

*   You **must** edit the script to set the correct `USERNAME` and `KIOSK_URL`.
*   This setup is optimized for resource efficiency by using Raspbian Lite and minimal components.
*   It is highly recommended to set a static IP address for your Raspberry Pi on your router.

## Troubleshooting (Kiosk)

*   **Black Screen or Login Loop:** Double-check the autologin settings in `/etc/lightdm/lightdm.conf`. Ensure the username is correct.
*   **Chromium Not Starting:** Check the `autostart` file for typos. Try running the Chromium command directly from the terminal to see if there are any errors. You can also check `/var/log/Xorg.0.log` for X server errors.
*   **Website Not Loading:** Make sure your web server is running and accessible on the specified URL.

## Troubleshooting (Docker/Dockwatch)

*   If Dockwatch is not accessible, check if the Docker container is running: `docker ps`.
*   Check the Dockwatch container logs for errors: `docker logs dockwatch`.

## Troubleshooting (Posterr)

*   Check if the Posterr service is running: `sudo systemctl status posterr`.
*   Check the system logs for Posterr errors: `sudo journalctl -u posterr`.

## Script Contents (`full_setup.sh`)

```bash
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
```
