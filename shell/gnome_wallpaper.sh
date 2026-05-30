#!/usr/bin/env bash

# ---------------------------------------------------------------------------------------------- #
# Basic script to find a wallpaper and set it as the desktop background and screensaver in Gnome #
# Set to run in crontab every 15 minutes on the hour                                             #
# ---------------------------------------------------------------------------------------------- #
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"
wallpaper_dir="${HOME}/.config/wallpapers"
if [[ -d ${wallpaper_dir} ]]; then
	wallpaper=$(find "${wallpaper_dir}" -maxdepth 1 -type f -print0 \( -name "*.png" -o -name "*.jpg" \) | shuf -z -n 1 | tr '\0' '\n')
	gsettings set org.gnome.desktop.background picture-uri-dark "file://${wallpaper}"
	gsettings set org.gnome.desktop.screensaver picture-uri "file://${wallpaper}"
fi
