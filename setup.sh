#!/usr/bin/env bash
git --version > /dev/null 2>&1
HAS_GIT="$?"
if [ "$HAS_GIT" -ne 0 ]; then
	printf "WARNING: Git is not installed, additional tools will not be installed.\n" >&2
fi

WORKING_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

# ------- #
# .bashrc #
# ------- #
if [ ! -f "$HOME/.bashrc" ]; then
	ln -s "$WORKING_DIR/shell/bashrc" "$HOME/.bashrc"
	. "$HOME/.bashrc" # .bashrc is sourced here to set ENV
else
	printf "WARNING: .bashrc already exists, not overwriting.\n" >&2
fi

# ------------- #
# .bash_aliases #
# ------------- #
if [ ! -f "$HOME/.bash_aliases" ]; then
	ln -s "$WORKING_DIR/shell/bash_aliases" "$HOME/.bash_aliases"
else
	printf "WARNING: .bash_aliases already exists, not overwriting.\n" >&2
fi

# -------- #
# .profile #
# -------- #
if [ ! -f "$HOME/.profile" ]; then
	ln -s "$WORKING_DIR/shell/profile" "$HOME/.profile"
else
	printf "WARNING: .profile already exists, not overwriting.\n" >&2
fi

# -------- #
# .condarc #
# -------- #
if [ ! -f "$HOME/.condarc" ]; then
	if [ -f "$MAMBA_EXE" ]; then
		ln -s "$WORKING_DIR/conda/condarc" "$HOME/.condarc"
	else
		printf "WARNING: Mamba is not installed.\n" >&2
	fi
else
	printf "WARNING: .condarc already exists, not overwriting.\n" >&2
fi

# ---------------- #
# Additional Tools #
# ---------------- #
if [[ $HAS_GIT -eq 0 && -d $REPOSITORY_DIR ]]; then
	# ------------------ #
	# Directory Explorer #
	# ------------------ #
	if [ ! -d "$REPOSITORY_DIR/directory-explorer/" ]; then
		git clone https://github.com/jBeale23/directory-explorer "$REPOSITORY_DIR"
	else
		printf "INFO: Directory Explorer is already installed.\n" >&2
	fi
fi

# --- #
# Vim #
# --- #
if command -v vim &> /dev/null; then
	if [ ! -f "${HOME}"/.vimrc ]; then
		ln -s "${WORKING_DIR}/vim/vimrc" "${HOME}/.vimrc"
	else
		printf "WARNING: .vimrc already exists, not overwriting.\n" >&2
	fi
fi

# --------- #
# Alacritty #
# --------- #
if [[ ! -f "${HOME}/.config/alacritty/alacritty.toml" ]]; then
	mkdir -p "${HOME}/.config/alacritty"
	ln -s "${WORKING_DIR}/alacritty/alacritty.toml" "${HOME}/.config/alacritty/alacritty.toml"
else
	printf "WARNING: alacritty.toml already exists, not overwriting.\n" >&2
fi

# ---- #
# Sway #
# ---- #
if command -v sway &> /dev/null; then
	mkdir -p "${HOME}/.config/sway"
	if [[ ! -f "${HOME}/.config/sway/config" ]]; then
		ln -s "${WORKING_DIR}/sway/config" "${HOME}/.config/sway/config"
	else
		printf "WARNING: sway config already exists, not overwriting.\n" >&2
	fi
fi

# ------ #
# Waybar #
# ------ #
if command -v waybar &> /dev/null; then
	mkdir -p "${HOME}/.config/waybar"
	for file in "${WORKING_DIR}"/waybar/*; do
		if [[ ! -f "${HOME}/.config/waybar/${file##*/}" ]]; then
			ln -s "${file}" "${HOME}/.config/waybar"
		else
			printf "WARNING: waybar %s already exists, not overwriting.\n" "${file##*/}" >&2
		fi
	done
fi

# ---- #
# Mako #
# ---- #
if command -v mako &> /dev/null; then
	mkdir -p "${HOME}/.config/mako"
	if [[ ! -f "${HOME}/.config/mako/config" ]]; then
		ln -s "${WORKING_DIR}/mako/config" "${HOME}/.config/mako/config"
	else
		printf "WARNING: mako config already exists, not overwriting.\n" >&2
	fi
fi

if command -v wofi &> /dev/null; then
	mkdir -p "${HOME}/.config/wofi"
	if [[ ! -f "${HOME}/.config/wofi/style.css" ]]; then
		ln -s "${WORKING_DIR}/wofi/style.css" "${HOME}/.config/wofi/style.css"
	else
		printf "WARNING: wofi style.css already exists, not overwriting.\n" >&2
	fi
fi

printf "Setup Complete. Please restart your shell or source ~/.bashrc for changes to take effect.\n"
