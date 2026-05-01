#!/usr/bin/env bash
# =============================================================================
# enable-home-server.sh — Optional: Turn this Intel Mac into a home server
# -----------------------------------------------------------------------------
# What this does:
#   1. Install Tailscale (zero-config VPN)
#   2. Enable sshd
#   3. Configure auto-login for tmux sessions to persist
#   4. Print connection info
#
# Run only if you want to ssh into this machine from elsewhere.
# =============================================================================
set -euo pipefail

C_BLUE='\033[0;34m'; C_GREEN='\033[0;32m'; C_YELLOW='\033[1;33m'
C_RESET='\033[0m'
log()  { printf "${C_BLUE}▸${C_RESET} %s\n" "$*"; }
ok()   { printf "${C_GREEN}✓${C_RESET} %s\n" "$*"; }
warn() { printf "${C_YELLOW}⚠${C_RESET} %s\n" "$*"; }

echo "🌐 Home Server Setup"
echo ""
echo "This will:"
echo "  1. Install Tailscale (private VPN)"
echo "  2. Enable Remote Login (sshd)"
echo "  3. Print SSH connection details"
echo ""
read -p "Continue? [y/N] " ans
[[ "$ans" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

# 1. Tailscale
if ! command -v tailscale &>/dev/null; then
  log "Installing Tailscale..."
  brew install --cask tailscale
fi
log "Starting Tailscale (you'll need to authenticate in browser)..."
open -a Tailscale
echo ""
echo "→ Sign in to Tailscale in the menu bar app, then press Enter to continue..."
read

# 2. sshd
log "Enabling Remote Login (sshd)..."
sudo systemsetup -setremotelogin on
ok "sshd enabled"

# 3. Print info
echo ""
echo "━━━ Connection Info ━━━"
local_user=$(whoami)
hostname=$(scutil --get LocalHostName)
ts_ip=$(tailscale ip -4 2>/dev/null | head -1 || echo "<run: tailscale up>")

cat <<INFO

✅ Home server enabled!

From your other Mac (e.g. air-m5):
  ${C_GREEN}ssh ${local_user}@${ts_ip}${C_RESET}     # via Tailscale (recommended)
  ${C_GREEN}ssh ${local_user}@${hostname}.local${C_RESET}     # via local network

To attach to a tmux session remotely:
  ${C_GREEN}ssh -t ${local_user}@${ts_ip} tmux attach${C_RESET}

To disable later:
  sudo systemsetup -setremotelogin off

INFO
