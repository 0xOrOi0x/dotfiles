#!/usr/bin/env bash
# DANGER: complete reset of the dev environment
set -uo pipefail

echo "⚠️  DANGER: This will remove the multi-agent dev environment."
echo "    Backups will be preserved at ~/.bootstrap-backup-*"
echo ""
read -p "Type 'NUKE' to confirm: " confirm
[[ "$confirm" == "NUKE" ]] || { echo "Aborted."; exit 1; }

# Remove markers
rm -rf "$HOME/.bootstrap-markers"

# Remove agent workspace
rm -rf "$HOME/.agents"

# Remove worktrees
rm -rf "$HOME/Code/.worktrees"

# Restore backups
latest_backup=$(ls -dt "$HOME"/.bootstrap-backup-* 2>/dev/null | head -1)
if [[ -n "$latest_backup" ]]; then
  echo "Restoring from: $latest_backup"
  cp -v "$latest_backup"/.zshrc    "$HOME/" 2>/dev/null || true
  cp -v "$latest_backup"/.tmux.conf "$HOME/" 2>/dev/null || true
fi

# Optional: remove brew packages (commented for safety)
# brew bundle cleanup --file=~/.dotfiles/Brewfile --force

echo ""
echo "✓ Reset complete. Run bootstrap.sh again to reinstall."
