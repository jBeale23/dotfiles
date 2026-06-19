#!/usr/bin/env bash

# ----------------------------------------------------------------------------------- #
# Basic script to run swaylock with a blurred version of the screen as the lockscreen #
# ----------------------------------------------------------------------------------- #
grimshot save output - | magick - -blur 0x9 "${TMPDIR:-/tmp}/lockscreen.png"
swaylock --daemonize --image "${TMPDIR:-/tmp}/lockscreen.png" --no-unlock-indicator --ignore-empty-password
