#!/usr/bin/env bash

# ----------------------------------------------------------------------------- #
# Basic script to find a wallpaper and set it as the desktop background in sway #
# Set to run in crontab every 15 minutes on the hour                            #
# ----------------------------------------------------------------------------- #
wallpaper_dir="${HOME}/.config/wallpapers"
SWAYSOCK=$(find /run/user/1000/sway*sock)
if [[ -d ${wallpaper_dir} ]]; then
	wallpaper=$(find "${wallpaper_dir}" -maxdepth 1 -type f -print0 \( -name "*.png" -o -name "*.jpg" \) | shuf -z -n 1 | tr '\0' '\n')
	ln -fs "$(realpath "${wallpaper}")" "${HOME}/.config/wallpapers/.wallpaper"
	swaymsg -s "${SWAYSOCK}" output '*' bg "${HOME}/.config/wallpapers/.wallpaper" fill
fi
