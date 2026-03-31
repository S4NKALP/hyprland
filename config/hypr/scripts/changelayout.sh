#!/usr/bin/env bash
#
# Dynamic Hyprland layout switcher (master, dwindle, scrolling, monocle)
# - Cycles layouts
# - Rebinds layout-specific keymaps
# - Sends desktop notifications
# - Supports init / toggle / explicit layout selection
#
# Usage:
#   layout-switcher.sh [toggle|next|init|master|dwindle|scrolling|monocle]
# ==================================================

set -Eeuo pipefail

# -----------------------------
# Configuration
# -----------------------------
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

# Layout order for toggle/next
readonly -a LAYOUTS=(
  master
  dwindle
  scrolling
  monocle
)

# Keys that this script manages dynamically
readonly -a MANAGED_BINDS=(
  "SUPER,j"
  "SUPER,k"
  "SUPER,left"
  "SUPER,right"
  "SUPER,up"
  "SUPER,down"
  "SUPER,O"
  "SUPER_SHIFT,M"
)

# -----------------------------
# Logging / UX helpers
# -----------------------------
log() {
  printf '[%s] %s\n' "$SCRIPT_NAME" "$*" >&2
}

die() {
  log "ERROR: $*"
  exit 1
}

usage() {
  cat >&2 <<EOF
Usage: $SCRIPT_NAME [toggle|next|init|master|dwindle|scrolling|monocle]

Commands:
  init        Re-apply bindings for the current Hyprland layout
  toggle      Switch to the next layout in the configured order
  next        Alias for toggle
  master      Switch to master layout
  dwindle     Switch to dwindle layout
  scrolling   Switch to scrolling layout
  monocle     Switch to monocle layout
EOF
  exit 1
}

notify() {
  local message="$1"

  if command -v notify-send >/dev/null 2>&1; then
      notify-send -e -u low "$message"
  fi
}

# -----------------------------
# Dependency checks
# -----------------------------
require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

check_dependencies() {
  require_cmd hyprctl
  require_cmd jq
}

# -----------------------------
# Hyprland helpers
# -----------------------------
hypr_keyword() {
  # Pass the full payload exactly as Hyprland expects
  hyprctl keyword "$@"
}

get_layout() {
  hyprctl -j getoption general:layout | jq -er '.str'
}

set_hypr_layout() {
  local layout="$1"
  hypr_keyword general:layout "$layout"
}

unbind_managed_keys() {
  local bind
  for bind in "${MANAGED_BINDS[@]}"; do
    hypr_keyword unbind "$bind" >/dev/null 2>&1 || true
  done
}

bind_many() {
  # Accepts bind payloads exactly as Hyprland expects, e.g.:
  #   "SUPER,j,cyclenext"
  #   "SUPER,left,movefocus,l"
  local payload
  for payload in "$@"; do
    hypr_keyword bind "$payload"
  done
}

# -----------------------------
# Layout helpers
# -----------------------------
is_valid_layout() {
  local candidate="$1"
  local layout

  for layout in "${LAYOUTS[@]}"; do
    [[ "$layout" == "$candidate" ]] && return 0
  done

  return 1
}

next_layout() {
  local current="$1"
  local i

  for i in "${!LAYOUTS[@]}"; do
    if [[ "${LAYOUTS[i]}" == "$current" ]]; then
      printf '%s\n' "${LAYOUTS[((i + 1) % ${#LAYOUTS[@]})]}"
      return 0
    fi
  done

  # Fallback if current layout is not found
  printf '%s\n' "${LAYOUTS[0]}"
}

apply_master_binds() {
  bind_many \
    "SUPER,j,layoutmsg,cyclenext" \
    "SUPER,k,layoutmsg,cycleprev" \
    "SUPER,left,movefocus,l" \
    "SUPER,right,movefocus,r" \
    "SUPER,up,movefocus,u" \
    "SUPER,down,movefocus,d"
}

apply_dwindle_binds() {
  bind_many \
    "SUPER,j,cyclenext" \
    "SUPER,k,cyclenext,prev" \
    "SUPER,left,cyclenext,prev" \
    "SUPER,right,cyclenext" \
    "SUPER,up,cyclenext,prev" \
    "SUPER,down,cyclenext" \
    "SUPER,O,layoutmsg,togglesplit"
}

apply_scrolling_binds() {
  bind_many \
    "SUPER,j,cyclenext" \
    "SUPER,k,cyclenext,prev" \
    "SUPER,left,cyclenext,prev" \
    "SUPER,right,cyclenext" \
    "SUPER,up,cyclenext,prev" \
    "SUPER,down,cyclenext"
}

apply_monocle_binds() {
  bind_many \
    "SUPER,j,layoutmsg,cyclenext" \
    "SUPER,k,layoutmsg,cycleprev" \
    "SUPER,left,layoutmsg,cycleprev" \
    "SUPER,right,layoutmsg,cyclenext" \
    "SUPER,up,layoutmsg,cycleprev" \
    "SUPER,down,layoutmsg,cyclenext" \
    "SUPER_SHIFT,M,layoutmsg,swapnext"
}

apply_layout_binds() {
  local layout="$1"

  case "$layout" in
    master)    apply_master_binds ;;
    dwindle)   apply_dwindle_binds ;;
    scrolling) apply_scrolling_binds ;;
    monocle)   apply_monocle_binds ;;
    *)
      # Safe fallback to master-style behavior
      log "Unknown layout '$layout', falling back to master bindings"
      apply_master_binds
      return 1
      ;;
  esac
}

set_layout() {
  local target="$1"

  set_hypr_layout "$target"
  unbind_managed_keys
  apply_layout_binds "$target"

  case "$target" in
    master)    notify " Master Layout" ;;
    dwindle)   notify " Dwindle Layout" ;;
    scrolling) notify " Scrolling Layout" ;;
    monocle)   notify " Monocle Layout" ;;
  esac
}

# -----------------------------
# Main
# -----------------------------
main() {
  check_dependencies

  local current
  local cmd="${1:-toggle}"

  case "$cmd" in
    init)
      current="$(get_layout)"
      set_layout "$current"
      ;;

    toggle|next)
      current="$(get_layout)"
      set_layout "$(next_layout "$current")"
      ;;

    master|dwindle|scrolling|monocle)
      set_layout "$cmd"
      ;;

    -h|--help|help)
      usage
      ;;

    *)
      usage
      ;;
  esac
}

main "$@"
