#!/usr/bin/env bash
# Daily/weekly update routine
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

C_BLUE='\033[0;34m'
C_GREEN='\033[0;32m'
C_RESET='\033[0m'

log() { printf "${C_BLUE}▸${C_RESET} %s\n" "$*"; }
ok()  { printf "${C_GREEN}✓${C_RESET} %s\n" "$*"; }

echo "━━━ Updating Dev Environment ━━━"

# 1. dotfiles repo
log "Pulling dotfiles..."
git -C "$DOTFILES_DIR" pull --ff-only
ok "dotfiles up to date"

# 2. Apply chezmoi
log "Applying dotfiles via chezmoi..."
chezmoi apply --source "$DOTFILES_DIR"

# 3. Brewfile
log "Updating Homebrew packages..."
brew update
brew bundle install --file="$DOTFILES_DIR/Brewfile" --no-lock --upgrade
brew cleanup
ok "Homebrew updated"

# 4. mise runtimes
if command -v mise &>/dev/null; then
  log "Updating mise runtimes..."
  mise upgrade
  ok "mise updated"
fi

# 5. AI agents
log "Updating AI agents..."
command -v claude &>/dev/null && claude update 2>/dev/null || true
command -v codex &>/dev/null && npm install -g @openai/codex 2>/dev/null || true
ok "AI agents updated"

# 6. tmux plugins
if [[ -f "$HOME/.tmux/plugins/tpm/bin/update_plugins" ]]; then
  log "Updating tmux plugins..."
  "$HOME/.tmux/plugins/tpm/bin/update_plugins" all
fi

# 7. Atuin sync
command -v atuin &>/dev/null && atuin sync 2>/dev/null || true

echo ""
ok "All updates complete"
