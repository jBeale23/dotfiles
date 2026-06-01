#!/usr/bin/env bash

# ---------------------------------------- #
# Script wrapper for waybar launched nmtui #
# Used as it doesn't read from .bashrc     #
# ---------------------------------------- #
export NEWT_COLORS='root=black,default; window=lightgray,default; border=darkgray,default; title=lightgray,default; button=black,green; button_active=black,yellow; actbutton=black,yellow; checkbox=yellow,default; actlistbox=yellow,black; sellistbox=white,green; entry=yellow,default; label=lightgray,default; textbox=lightgray,default; acttextbox=yellow,black;'
nmtui
