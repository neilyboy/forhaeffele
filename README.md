**README-kiosk.md (Kiosk Setup)**

```markdown
# Raspberry Pi Kiosk Mode Setup

This script configures a Raspberry Pi (running Raspbian Lite or similar) to boot directly into a fullscreen kiosk mode displaying a specified website.

## Prerequisites

*   A Raspberry Pi running Raspbian Lite (or a similar Debian-based OS).
*   Internet connectivity.
*   SSH access to the Raspberry Pi (recommended).

## Usage

1.  Save the script to a file (e.g., `setup_kiosk.sh`).
2.  Make the script executable: `chmod +x setup_kiosk.sh`.
3.  **Crucially:** Edit the script:
    *   Change `USERNAME="pi"` if your username is different.
    *   Change `KIOSK_URL="http://localhost:9876"` to the actual URL you want to display.
4.  Run the script with sudo: `sudo ./setup_kiosk.sh`.

## What the script does

*   Installs necessary packages (Xorg, Matchbox Window Manager, LightDM, Chromium, unclutter).
*   Configures autologin for the specified user.
*   Creates an autostart script to launch Chromium in kiosk mode with the specified URL, disables screen blanking, and hides the cursor.
*   Optionally disables the screensaver.
*   Reboots the Raspberry Pi.

## Important Considerations

*   You **must** edit the script to set the correct `USERNAME` and `KIOSK_URL`.
*   This setup is optimized for resource efficiency by using Raspbian Lite and minimal components.
*   It is highly recommended to set a static IP address for your Raspberry Pi on your router.

## Troubleshooting

*   **Black Screen or Login Loop:** Double-check the autologin settings in `/etc/lightdm/lightdm.conf`. Ensure the username is correct.
*   **Chromium Not Starting:** Check the `autostart` file for typos. Try running the Chromium command directly from the terminal to see if there are any errors. You can also check `/var/log/Xorg.0.log` for X server errors.
*   **Website Not Loading:** Make sure your web server is running and accessible on the specified URL.

## Script Contents (`setup_kiosk.sh`)








# Install Docker, Docker Compose, and Dockwatch on Raspberry Pi

This script automates the installation of Docker, Docker Compose, and Dockwatch (as a Docker container) on a Raspberry Pi running Raspbian Lite (or similar Debian-based distributions).

## Prerequisites

*   A Raspberry Pi running Raspbian Lite (or a similar Debian-based OS).
*   Internet connectivity.
*   SSH access to the Raspberry Pi (recommended).

## Usage

1.  Save the script to a file (e.g., `install_docker_dockwatch.sh`).
2.  Make the script executable: `chmod +x install_docker_dockwatch.sh`.
3.  Run the script with sudo: `sudo ./install_docker_dockwatch.sh`.

## What the script does

*   Updates the package lists.
*   Installs necessary dependencies for Docker.
*   Adds Docker's official GPG key and repository.
*   Installs Docker Engine, containerd, and Docker Compose.
*   Adds the current user to the `docker` group (so you don't need `sudo` for `docker` commands).
*   Verifies the Docker installation with `docker run hello-world`.
*   Installs Dockwatch as a Docker container, exposing it on port 8080.
*   Prints instructions on how to access Dockwatch.

## Accessing Dockwatch

After the script completes and the Raspberry Pi reboots (if you rebooted), you can access Dockwatch by opening a web browser and navigating to:

```bash
#!/bin/bash
# ... (The full script code goes here)
