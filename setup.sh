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
	if [[ ${HAS_GIT} -eq 0 && ! -d "${HOME}/.vim/pack/airblade/start" ]]; then
		mkdir -p "${HOME}/.vim/pack/airblade/start"
		cd "${HOME}"/.vim/pack/airblade/start || exit 1
		git clone https://github.com/airblade/vim-gitgutter.git
		vim -u NONE -c "helptags vim-gitgutter/doc" -c q
		cd "${WORKING_DIR}" || exit 1
	fi
	if [[ ${HAS_GIT} -eq 0 && ! -d "${HOME}/.vim/pack/tpope/start" ]]; then
		mkdir -p "${HOME}/.vim/pack/tpope/start"
		cd "${HOME}/.vim/pack/tpope/start" || exit 1
		git clone https://tpope.io/vim/fugitive.git
		vim -u NONE -c "helptags fugitive/doc" -c q
		cd "${WORKING_DIR}" || exit 1
	fi
	if [[ ${HAS_GIT} -eq 0 && ! -d "${HOME}/.vim/pack/statox/start" ]]; then
		mkdir -p "${HOME}/.vim/pack/statox/start"
		cd "${HOME}/.vim/pack/statox/start" || exit 1
		git clone https://github.com/statox/FYT.vim.git
		vim -u NONE -c "helptags FYT/doc" -c q
		cd "${WORKING_DIR}" || exit 1
	fi
	if command -v curl &> /dev/null && [[ ! -f "${HOME}/.vim/colors/gruvbox8.vim" ]]; then
		cd "${HOME}/.vim/colors/" || exit 1
		curl -O https://codeberg.org/lifepillar/vim-gruvbox8/raw/commit/ee054a75163bdfcbbc98c19a9e70ec4ff8af5aee/colors/gruvbox8.vim
		cd "${WORKING_DIR}" || exit 1
	fi
fi

# --------- #
# Alacritty #
# --------- #
if [[ ! -f "${HOME}/.config/alacritty/alacritty.toml" ]]; then
	ln -s "${WORKING_DIR}/alacritty/alacritty.toml" "${HOME}/.config/alacritty/alacritty.toml"
else
	printf "WARNING: alacritty.toml already exists, not overwriting.\n" >&2
fi

printf "Setup Complete. Please restart your shell or source ~/.bashrc for changes to take effect.\n"
