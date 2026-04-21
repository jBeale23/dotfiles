#!/usr/bin/env bash
git --version >/dev/null 2>&1; HAS_GIT="$?"
if [ "$HAS_GIT" -ne 0 ]; then
  echo "WARNING: Git is not installed, additional tools will not be installed" >&2
fi

WORKING_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

# ------- #
# .bashrc #
# ------- #
if [ ! -f "$HOME/.bashrc" ]; then
  ln -s "$WORKING_DIR/shell/bashrc" "$HOME/.bashrc"
  . "$HOME/.bashrc" # .bashrc is sourced here to set ENV
else
  echo "WARNING: .bashrc already exists, not overwriting." >&2
fi

# ------------- #
# .bash_aliases #
# ------------- #
if [ ! -f "$HOME/.bash_aliases" ]; then
  ln -s "$WORKING_DIR/shell/bash_aliases" "$HOME/.bash_aliases"
else
  echo "WARNING: .bash_aliases already exists, not overwriting." >&2
fi

# -------- #
# .profile #
# -------- #
if [ ! -f "$HOME/.profile" ]; then
  ln -s "$WORKING_DIR/shell/profile" "$HOME/.profile"
else
  echo "WARNING: .profile already exists, not overwriting." >&2
fi

# -------- #
# .condarc #
# -------- #
if [ ! -f "$HOME/.condarc" ]; then
  if [ -f "$MAMBA_EXE" ]; then
    ln -s "$WORKING_DIR/shell/profile" "$HOME/.profile"
  else
    echo "WARNING: Mamba is not installed." >&2
  fi
else
  echo "WARNING: .condarc already exists, not overwriting." >&2
fi

# ---------------- #
# Additional Tools #
# ---------------- #
if [[ "$HAS_GIT" -eq 0 && -d "$REPOSITORY_DIR" ]]; then
  # ------------------ #
  # Directory Explorer #
  # ------------------ #
  if [ ! -d "$REPOSITORY_DIR/directory-explorer/" ]; then
    git clone https://github.com/jBeale23/directory-explorer "$REPOSITORY_DIR"
  else
    echo "INFO: Directory Explorer is already installed." >&2
  fi
fi

echo "Setup Complete. Please restart your shell or source ~/.bashrc for changes to take effect."
