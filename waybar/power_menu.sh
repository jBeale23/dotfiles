#!/bin/bash
entries=" Power Off\n Reboot\n Logout\n Suspend"

chosen=$(printf "%b" "$entries" | wofi --sort-order="default" --location=top_right --xoffset=-113 --yoffset=2 --dmenu --insensitive --width=3% --height=14% --prompt "Power Menu" 2> /dev/null)

case "$chosen" in
	*Power\ Off) systemctl poweroff ;;
	*Reboot) systemctl reboot ;;
	*Logout) swaymsg exit ;;
	*Suspend) systemctl suspend ;;
esac
