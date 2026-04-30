#!/usr/bin/env bash
# =============================================================================
# 🚀 bootstrap.sh — Multi-Agent Dev Environment v3.1 (repo-aware)
# -----------------------------------------------------------------------------
# Called by `install` after repo is cloned to $DOTFILES_DIR
# Idempotent · Resumable · Verified
# =============================================================================
set -euo pipefail

readonly DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
readonly SCRIPTS_DIR="$DOTFILES_DIR/scripts"
readonly MARKER_DIR="$HOME/.bootstrap-markers"
mkdir -p "$MARKER_DIR"

# ─── Colors ─────────────────────────────────────────────────────────────────
C_RESET='\033[0m'; C_BOLD='\033[1m'; C_DIM='\033[2m'
C_BLUE='\033[0;34m'; C_GREEN='\033[0;32m'; C_YELLOW='\033[1;33m'
C_RED='\033[0;31m'; C_MAGENTA='\033[0;35m'; C_CYAN='\033[0;36m'

log()    { printf "${C_BLUE}▸${C_RESET} %s\n" "$*"; }
ok()     { printf "${C_GREEN}✓${C_RESET} %s\n" "$*"; }
warn()   { printf "${C_YELLOW}⚠${C_RESET} %s\n" "$*"; }
err()    { printf "${C_RED}✗${C_RESET} %s\n" "$*" >&2; }
die()    { err "$*"; exit 1; }
title()  { printf "\n${C_BOLD}${C_MAGENTA}━━━ %s ━━━${C_RESET}\n" "$*"; }

# ─── Options ────────────────────────────────────────────────────────────────
DRY_RUN=false
SKIP_LIST=()
RESET_MARKERS=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --skip)    SKIP_LIST+=("$2"); shift 2 ;;
    --reset)   RESET_MARKERS=true; shift ;;
    -h|--help)
      cat <<EOF
Usage: bash bootstrap.sh [options]

Options:
  --dry-run        Simulate without installing
  --skip <phase>   Skip specific phase
                   (xcode-clt|homebrew|brewfile|ohmyzsh|zinit-tpm|
                    scm-breeze|ai-agents|chezmoi|macos-defaults)
  --reset          Clear progress markers (start from scratch)
  -h, --help       Show this help

Phases:
  0. Pre-flight checks
  1. Xcode Command Line Tools
  2. Homebrew
  3. Brewfile (40+ packages)
  4. Oh My Zsh + Zinit + tmux TPM
  5. SCM Breeze (conditional)
  6. AI agents (Claude / Codex / Gemini)
  7. chezmoi apply (all dotfiles)
  8. macOS sensible defaults
  9. Verification + next-steps wizard

Estimated time: 25-40 minutes
EOF
      exit 0
      ;;
    *) die "Unknown option: $1 (use --help)" ;;
  esac
done

[[ "$RESET_MARKERS" == "true" ]] && rm -f "$MARKER_DIR"/*

run_phase() {
  local name="$1"; shift
  local marker="$MARKER_DIR/$name"

  for skip in "${SKIP_LIST[@]:-}"; do
    [[ "$skip" == "$name" ]] && { warn "[$name] --skip"; return 0; }
  done

  if [[ -f "$marker" ]]; then
    ok "[$name] already complete (skip)"
    return 0
  fi

  log "[$name] starting..."
  if [[ "$DRY_RUN" == "true" ]]; then
    warn "  (dry-run)"
    return 0
  fi

  if "$@"; then
    touch "$marker"
    ok "[$name] complete"
  else
    die "[$name] failed"
  fi
}

# =============================================================================
# Banner
# =============================================================================
print_banner() {
  cat <<EOF

${C_MAGENTA}${C_BOLD}
  ╭───────────────────────────────────────────────────────╮
  │   🚀 0xOrOi0x/dotfiles · Bootstrap v3.1               │
  │   Ghostty + tmux + Claude/Codex/Gemini + AeroSpace   │
  ╰───────────────────────────────────────────────────────╯
${C_RESET}
${C_DIM}Dotfiles dir: $DOTFILES_DIR${C_RESET}
${C_DIM}ETA: 25-40 minutes (depending on network)${C_RESET}

EOF
}

# =============================================================================
# Phase 0: Pre-flight
# =============================================================================
phase_check() {
  title "Phase 0: Pre-flight checks"

  [[ "$(uname)" == "Darwin" ]] || die "macOS only"
  log "macOS $(sw_vers -productVersion)"

  ping -c 1 -W 2 1.1.1.1 &>/dev/null || die "Internet required"
  ok "Network OK"

  local free_gb
  free_gb=$(df -g / | awk 'NR==2 {print $4}')
  [[ "$free_gb" -ge 10 ]] || warn "Free disk: ${free_gb}GB (10GB+ recommended)"
  ok "Disk: ${free_gb}GB free"

  if [[ "$(uname -m)" == "arm64" ]]; then
    ok "Apple Silicon detected"
    export HOMEBREW_PREFIX="/opt/homebrew"
  else
    warn "Intel Mac detected"
    export HOMEBREW_PREFIX="/usr/local"
  fi

  [[ -d "$DOTFILES_DIR" ]] || die "Dotfiles repo not found at $DOTFILES_DIR"
  ok "Dotfiles repo present"
}

# =============================================================================
# Phase 1: Xcode CLT (already installed by `install`, just verify)
# =============================================================================
phase_xcode() {
  xcode-select -p &>/dev/null && return 0
  log "Installing Xcode CLT..."
  xcode-select --install || true
  until xcode-select -p &>/dev/null; do
    printf "."
    sleep 5
  done
  echo
}

# =============================================================================
# Phase 2: Homebrew
# =============================================================================
phase_homebrew() {
  if command -v brew &>/dev/null; then
    ok "Homebrew installed"
    brew update
    return 0
  fi
  log "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -d "/opt/homebrew" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

# =============================================================================
# Phase 3: Brewfile install
# =============================================================================
phase_brewfile() {
  log "Installing from Brewfile (10-20 min)..."
  brew bundle install --file="$DOTFILES_DIR/Brewfile" --no-lock || \
    warn "Some packages may have failed — review output above"
}

# =============================================================================
# Phase 4: Oh My Zsh + Zinit + tmux TPM
# =============================================================================
phase_zsh() {
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  else
    ok "Oh My Zsh already installed"
  fi

  if [[ ! -d "$HOME/.local/share/zinit/zinit.git" ]]; then
    log "Installing Zinit..."
    mkdir -p "$HOME/.local/share/zinit"
    git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git"
  else
    ok "Zinit already installed"
  fi

  if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    log "Installing tmux TPM..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  else
    ok "tmux TPM already installed"
  fi
}

# =============================================================================
# Phase 5: SCM Breeze
# =============================================================================
phase_scm_breeze() {
  if [[ ! -d "$HOME/.scm_breeze" ]]; then
    log "Installing SCM Breeze..."
    git clone https://github.com/scmbreeze/scm_breeze.git "$HOME/.scm_breeze"
    "$HOME/.scm_breeze/install.sh" || true
  else
    ok "SCM Breeze already installed"
  fi
}

# =============================================================================
# Phase 6: AI agents
# =============================================================================
phase_ai_agents() {
  if command -v mise &>/dev/null; then
    eval "$(mise activate bash)"
    mise use --global node@24 || true
  fi

  if ! command -v claude &>/dev/null; then
    log "Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
  else
    ok "Claude Code installed"
  fi

  if ! command -v codex &>/dev/null; then
    log "Installing Codex CLI..."
    npm install -g @openai/codex
  else
    ok "Codex CLI installed"
  fi

  command -v gemini &>/dev/null && ok "Gemini CLI installed (via Brewfile)"
}

# =============================================================================
# Phase 7: chezmoi apply (manage all dotfiles)
# =============================================================================
phase_chezmoi() {
  command -v chezmoi &>/dev/null || die "chezmoi not found (Brewfile should have installed it)"

  # Backup existing dotfiles
  local backup_dir="$HOME/.bootstrap-backup-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$backup_dir"
  for f in .zshrc .tmux.conf .gitconfig; do
    if [[ -f "$HOME/$f" ]] && [[ ! -L "$HOME/$f" ]]; then
      cp "$HOME/$f" "$backup_dir/" && log "Backup: $f"
    fi
  done

  # Initialize chezmoi pointing to the repo (uses .chezmoiroot inside)
  if [[ ! -d "$HOME/.local/share/chezmoi" ]] || \
     [[ -z "$(ls -A "$HOME/.local/share/chezmoi" 2>/dev/null)" ]]; then
    log "Initializing chezmoi from $DOTFILES_DIR..."
    chezmoi init --source "$DOTFILES_DIR"
  fi

  log "Applying dotfiles via chezmoi..."
  chezmoi apply --source "$DOTFILES_DIR" -v
}

# =============================================================================
# Phase 8: macOS defaults
# =============================================================================
phase_macos_defaults() {
  if [[ -x "$SCRIPTS_DIR/macos-defaults.sh" ]]; then
    bash "$SCRIPTS_DIR/macos-defaults.sh"
  else
    warn "scripts/macos-defaults.sh not executable — skipping"
  fi
}

# =============================================================================
# Phase 9: Verification
# =============================================================================
phase_verify() {
  if [[ -x "$SCRIPTS_DIR/verify.sh" ]]; then
    bash "$SCRIPTS_DIR/verify.sh"
  fi
}

# =============================================================================
# Next steps wizard
# =============================================================================
print_next_steps() {
  cat <<EOF

${C_BOLD}${C_GREEN}╭─────────────────────────────────────────────────────────╮${C_RESET}
${C_BOLD}${C_GREEN}│${C_RESET}  🎉 ${C_BOLD}Setup complete!${C_RESET}                                     ${C_BOLD}${C_GREEN}│${C_RESET}
${C_BOLD}${C_GREEN}╰─────────────────────────────────────────────────────────╯${C_RESET}

${C_CYAN}${C_BOLD}NEXT STEPS${C_RESET} ${C_DIM}(approximately 10 minutes)${C_RESET}

${C_BOLD}1. Restart your shell${C_RESET}
   ${C_YELLOW}exec zsh${C_RESET}

${C_BOLD}2. Open Ghostty${C_RESET}
   ${C_YELLOW}open -a Ghostty${C_RESET}

${C_BOLD}3. Authenticate AI agents${C_RESET}
   ${C_YELLOW}claude${C_RESET}                  ${C_DIM}# Anthropic login${C_RESET}
   ${C_YELLOW}codex login${C_RESET}             ${C_DIM}# OpenAI login${C_RESET}
   ${C_YELLOW}gemini${C_RESET}                  ${C_DIM}# Google login${C_RESET}

${C_BOLD}4. Install tmux plugins${C_RESET}
   ${C_YELLOW}tmux${C_RESET}                    ${C_DIM}# start tmux${C_RESET}
   ${C_DIM}then press ${C_YELLOW}Ctrl+Space → Shift+I${C_RESET}

${C_BOLD}5. Set up Atuin sync (optional, recommended)${C_RESET}
   ${C_YELLOW}atuin register -u <USERNAME> -e <EMAIL>${C_RESET}
   ${C_YELLOW}atuin import auto && atuin sync${C_RESET}
   ${C_RED}IMPORTANT: Save the encryption key in 1Password!${C_RESET}

${C_BOLD}6. Grant macOS permissions${C_RESET}
   ${C_DIM}System Settings → Privacy & Security → Accessibility:${C_RESET}
   ${C_DIM}  Add: AeroSpace, Karabiner-Elements, Raycast${C_RESET}
   ${C_DIM}System Settings → Privacy & Security → Input Monitoring:${C_RESET}
   ${C_DIM}  Add: Karabiner-Elements${C_RESET}

${C_BOLD}7. Launch window manager${C_RESET}
   ${C_YELLOW}open -a AeroSpace${C_RESET}

${C_BOLD}8. GitHub auth${C_RESET}
   ${C_YELLOW}gh auth login${C_RESET}

${C_BOLD}9. Test the cockpit${C_RESET}
   ${C_YELLOW}cd ~/Code && mkdir test && cd test && git init${C_RESET}
   ${C_YELLOW}cockpit hello "Hello world test"${C_RESET}

${C_DIM}─────────────────────────────────────────────────────────${C_RESET}
${C_DIM}Repo:    https://github.com/0xOrOi0x/dotfiles${C_RESET}
${C_DIM}Updates: bash ~/.dotfiles/scripts/update.sh${C_RESET}
${C_DIM}Verify:  bash ~/.dotfiles/scripts/verify.sh${C_RESET}
${C_DIM}Reset:   bash ~/.dotfiles/bootstrap.sh --reset${C_RESET}

EOF
}

# =============================================================================
# Main
# =============================================================================
main() {
  print_banner
  phase_check
  run_phase "xcode-clt"      phase_xcode
  run_phase "homebrew"       phase_homebrew
  run_phase "brewfile"       phase_brewfile
  run_phase "ohmyzsh"        phase_zsh
  run_phase "scm-breeze"     phase_scm_breeze
  run_phase "ai-agents"      phase_ai_agents
  run_phase "chezmoi"        phase_chezmoi
  run_phase "macos-defaults" phase_macos_defaults
  phase_verify
  print_next_steps
}

main "$@"
