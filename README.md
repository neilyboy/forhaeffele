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

```bash
#!/bin/bash
# ... (The full script code goes here)
