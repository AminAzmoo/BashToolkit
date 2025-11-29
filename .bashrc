########################
#  Smart Bash Profile  #
########################

# ---- Theme / Prompt ----
if [ -n "$TERM" ] && [ "$TERM" != "dumb" ]; then
  RESET='\[\e[0m\]'
  BOLD='\[\e[1m\]'
  FG_USER='\[\e[38;5;81m\]'
  FG_HOST='\[\e[38;5;141m\]'
  FG_DIR='\[\e[38;5;214m\]'
  FG_GIT='\[\e[38;5;118m\]'

  _git_branch() {
    git rev-parse --abbrev-ref HEAD 2>/dev/null | sed 's/^/ (/;s/$/)/'
  }

  PS1="${FG_USER}\u${RESET}@${FG_HOST}\h ${FG_DIR}\w${FG_GIT}\$(_git_branch)${RESET}\n\$ "
fi

# Color for ls
if command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b 2>/dev/null || dircolors)"
  alias ls='ls --color=auto'
fi

# ---- Package manager detection ----
PKG_MGR=""
PKG_INSTALL=""
PKG_UPDATE=""
PKG_UPGRADE=""

_detect_pkg_mgr() {
  if command -v dnf >/dev/null 2>&1; then
    PKG_MGR="dnf"
    PKG_INSTALL="sudo dnf install -y"
    PKG_UPDATE="sudo dnf check-update || true"
    PKG_UPGRADE="sudo dnf upgrade -y"
  elif command -v yum >/dev/null 2>&1; then
    PKG_MGR="yum"
    PKG_INSTALL="sudo yum install -y"
    PKG_UPDATE="sudo yum check-update || true"
    PKG_UPGRADE="sudo yum update -y"
  elif command -v pacman >/dev/null 2>&1; then
    PKG_MGR="pacman"
    PKG_INSTALL="sudo pacman -S --noconfirm"
    PKG_UPDATE="sudo pacman -Sy"
    PKG_UPGRADE="sudo pacman -Syu --noconfirm"
  elif command -v apt >/dev/null 2>&1; then
    PKG_MGR="apt"
    PKG_INSTALL="sudo apt install -y"
    PKG_UPDATE="sudo apt update"
    PKG_UPGRADE="sudo apt full-upgrade -y"
  elif command -v zypper >/dev/null 2>&1; then
    PKG_MGR="zypper"
    PKG_INSTALL="sudo zypper install -y"
    PKG_UPDATE="sudo zypper refresh"
    PKG_UPGRADE="sudo zypper dist-upgrade -y"
  elif command -v xbps-install >/dev/null 2>&1; then
    PKG_MGR="xbps"
    PKG_INSTALL="sudo xbps-install -y"
    PKG_UPDATE="sudo xbps-install -S"
    PKG_UPGRADE="sudo xbps-install -Su -y"
  fi
}
_detect_pkg_mgr

# ---- High-level helpers ----
pkg_install() {
  if [ -z "$PKG_INSTALL" ]; then
    printf 'No supported package manager detected.\n' >&2
    return 1
  fi
  eval "$PKG_INSTALL $*"
}

pkg_update() {
  [ -n "$PKG_UPDATE" ] && eval "$PKG_UPDATE"
}

pkg_upgrade() {
  [ -n "$PKG_UPGRADE" ] && eval "$PKG_UPGRADE"
}

# Shortcuts
alias sys-up='pkg_update && pkg_upgrade'
alias sys-update='pkg_update'
alias sys-upgrade='pkg_upgrade'
alias sys-install='pkg_install'

# ---- Auto install missing commands ----
command_not_found_handle() {
  local cmd="$1"
  shift

  # Only simple command names, no paths or weird chars
  if ! [[ "$cmd" =~ ^[a-zA-Z0-9_.+-]+$ ]]; then
    printf 'Command not found: %s\n' "$cmd" >&2
    return 127
  fi

  if [ -z "$PKG_INSTALL" ]; then
    printf 'Command not found: %s (no package manager detected)\n' "$cmd" >&2
    return 127
  fi

  printf "Auto-installing '%s' using %s...\n" "$cmd" "$PKG_MGR"

  if pkg_install "$cmd"; then
    if command -v "$cmd" >/dev/null 2>&1; then
      command "$cmd" "$@"
      return $?
    fi
  fi

  printf 'Failed to install or run: %s\n' "$cmd" >&2
  return 127
}
