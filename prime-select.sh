#!/usr/bin/env bash
#
# prime-select.sh
#
# Minimal compatibility wrapper that provides a `prime-select`
# interface using `envycontrol` so that the TUXEDO Control Center
# can expose GPU switching options on distributions where
# Ubuntu's `nvidia-prime` is not available.
#
# Installation:
#   sudo install -m 755 prime-select.sh /usr/local/bin/prime-select
#   sudo mkdir -p /var/lib/ubuntu-drivers-common
#   sudo touch /var/lib/ubuntu-drivers-common/requires_offloading
#
# After installation the TUXEDO Control Center should detect
# GPU switching support and show the options in the tray icon.
#
# https://github.com/canonical/nvidia-prime/
# https://github.com/bayasdev/envycontrol
# https://github.com/tuxedocomputers/tuxedo-control-center/
#


set -euo pipefail

# ------------------------------------------------------------
# Translate envycontrol query output to prime-select format
# ------------------------------------------------------------
map_envycontrol_to_prime() {
    local mode

    # Query current GPU mode from envycontrol
    mode="$(envycontrol --query 2>/dev/null || true)"

    case "$mode" in
        integrated) echo "intel" ;;      # integrated GPU
        nvidia)     echo "nvidia" ;;     # dedicated NVIDIA GPU
        hybrid)     echo "on-demand" ;;  # hybrid / offloading mode
        *)          echo ""; return 1 ;;
    esac
}

# ------------------------------------------------------------
# Switch GPU mode via envycontrol
# ------------------------------------------------------------
set_envycontrol_mode() {
    local target="$1"

    case "$target" in
        intel)
            envycontrol --switch integrated
            ;;

        nvidia)
            envycontrol --switch nvidia
            ;;

        on-demand)
            # hybrid mode with runtime power management
            envycontrol --switch hybrid --rtd3 2
            ;;

        *)
            echo "prime-select: invalid mode: $target" >&2
            return 1
            ;;
    esac
}

# ------------------------------------------------------------
# Main command dispatcher
# ------------------------------------------------------------
cmd="${1:-}"

case "${cmd}" in

  # Show current GPU mode
  query)
    map_envycontrol_to_prime
    ;;

  # Switch modes
  intel|nvidia|on-demand)
    set_envycontrol_mode "${cmd}"
    ;;

  # Help output
  -h|--help|help|"")
    cat <<'EOF'
Usage:
  prime-select query
  prime-select intel|nvidia|on-demand

Compatibility wrapper for envycontrol.

query
    Shows current GPU mode.

intel | nvidia | on-demand
    Switch GPU mode via envycontrol.
EOF
    exit 0
    ;;

  # Unknown command
  *)
    echo "prime-select: unknown command: ${cmd}" >&2
    exit 2
    ;;
esac
