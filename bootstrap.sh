#!/usr/bin/env bash
# =============================================================================
# 🚀 bootstrap.sh — Multi-Agent Dev Environment v3.4 (repo-aware)
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
                   (xcode-clt|homebrew|oss-cleanup|brewfile|ohmyzsh|
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
  │   🚀 0xOrOi0x/dotfiles · Bootstrap v3.4               │
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

  # === Machine profile detection ===
  if [[ -x "$DOTFILES_DIR/scripts/machine-detect.sh" ]]; then
    local machine_id profile chip ram_gb
    machine_id=$("$DOTFILES_DIR/scripts/machine-detect.sh" machine_id)
    profile=$("$DOTFILES_DIR/scripts/machine-detect.sh" profile)
    chip=$("$DOTFILES_DIR/scripts/machine-detect.sh" chip)
    ram_gb=$("$DOTFILES_DIR/scripts/machine-detect.sh" ram_gb)

    printf "\n${C_BOLD}━━━ Machine Profile ━━━${C_RESET}\n"
    printf "  ${C_GREEN}🏷  ID:${C_RESET}      %s\n" "$machine_id"
    printf "  ${C_GREEN}💻 Chip:${C_RESET}    %s\n" "$chip"
    printf "  ${C_GREEN}🧠 RAM:${C_RESET}     %s GB\n" "$ram_gb"
    printf "  ${C_GREEN}🎯 Profile:${C_RESET} %s\n" "$profile"

    export DETECTED_MACHINE_ID="$machine_id"
    export DETECTED_PROFILE="$profile"
  fi
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
# Phase 2.5: OSS Cleanup — Remove proprietary tools (idempotent)
# =============================================================================
phase_oss_cleanup() {
  log "Removing proprietary tools (1Password, Raycast)..."

  # 1Password
  if [[ -d /Applications/1Password.app ]] || command -v op &>/dev/null; then
    log "  Uninstalling 1Password..."
    brew uninstall --cask 1password 2>/dev/null || true
    brew uninstall --cask 1password-cli 2>/dev/null || true
    brew uninstall 1password-cli 2>/dev/null || true

    # Remove all 1Password data
    rm -rf "$HOME/.config/op"            "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password"            "$HOME/Library/Application Support/1Password"            "$HOME/Library/Caches/com.1password"*            "$HOME/Library/Preferences/com.1password"*            "$HOME/Library/Saved Application State/com.1password.1password.savedState" 2>/dev/null

    # Remove launch agents/daemons
    rm -f "$HOME/Library/LaunchAgents/com.1password"* 2>/dev/null
    sudo rm -f /Library/LaunchAgents/com.1password* 2>/dev/null
    sudo rm -f /Library/LaunchDaemons/com.1password* 2>/dev/null

    ok "  1Password removed"
  else
    ok "  1Password not present"
  fi

  # Raycast
  if [[ -d /Applications/Raycast.app ]]; then
    log "  Uninstalling Raycast..."
    brew uninstall --cask raycast 2>/dev/null || true

    # Remove all Raycast data
    rm -rf "$HOME/.config/raycast"            "$HOME/Library/Application Support/com.raycast.macos"            "$HOME/Library/Caches/com.raycast.macos"            "$HOME/Library/Preferences/com.raycast.macos.plist"            "$HOME/Library/Saved Application State/com.raycast.macos.savedState"            "$HOME/Library/HTTPStorages/com.raycast.macos"            "$HOME/Library/WebKit/com.raycast.macos" 2>/dev/null

    # Remove launch agents
    rm -f "$HOME/Library/LaunchAgents/com.raycast"* 2>/dev/null

    ok "  Raycast removed"
  else
    ok "  Raycast not present"
  fi

  # Bruno (replaced by Hoppscotch)
  if [[ -d /Applications/Bruno.app ]]; then
    log "  Uninstalling Bruno..."
    brew uninstall --cask bruno 2>/dev/null || true
    rm -rf "$HOME/Library/Application Support/bruno"            "$HOME/Library/Preferences/com.usebruno"* 2>/dev/null
    ok "  Bruno removed"
  else
    ok "  Bruno not present"
  fi

  # Docker Desktop (replaced by Colima)
  if [[ -d /Applications/Docker.app ]]; then
    log "  Uninstalling Docker Desktop (replaced by Colima)..."
    # Stop Docker first
    osascript -e 'quit app "Docker"' 2>/dev/null || true
    sleep 2
    brew uninstall --cask docker 2>/dev/null || true

    # Remove Docker Desktop data (keep Docker config in ~/.docker)
    rm -rf "$HOME/Library/Containers/com.docker.docker"            "$HOME/Library/Application Support/Docker Desktop"            "$HOME/Library/Caches/com.docker.docker"            "$HOME/Library/Group Containers/group.com.docker"            "$HOME/Library/Preferences/com.docker.docker.plist" 2>/dev/null

    # Privileged helper
    sudo rm -f /Library/PrivilegedHelperTools/com.docker.vmnetd 2>/dev/null
    sudo rm -f /Library/LaunchDaemons/com.docker.vmnetd.plist 2>/dev/null

    ok "  Docker Desktop removed (use 'colima start' instead)"
  else
    ok "  Docker Desktop not present"
  fi

  # OrbStack (proprietary, replaced by Colima)
  if [[ -d /Applications/OrbStack.app ]]; then
    log "  Uninstalling OrbStack..."
    osascript -e 'quit app "OrbStack"' 2>/dev/null || true
    sleep 2
    brew uninstall --cask orbstack 2>/dev/null || true
    rm -rf "$HOME/.orbstack"            "$HOME/Library/Application Support/dev.kdrag0n.MacVirt"            "$HOME/Library/Group Containers/HUAQ24HBR6.dev.kdrag0n.MacVirt" 2>/dev/null
    ok "  OrbStack removed"
  fi

  log "OSS cleanup complete"
}

# =============================================================================
# Phase 3: Brewfile install
# =============================================================================
phase_brewfile() {
  local arch=$(uname -m)
  local brewfile

  # Apple Silicon vs Intel 자동 선택
  if [[ "$arch" == "arm64" ]]; then
    brewfile="$DOTFILES_DIR/Brewfile"
    log "Apple Silicon detected → using Brewfile"
  else
    brewfile="$DOTFILES_DIR/Brewfile.intel"
    log "Intel Mac detected → using Brewfile.intel"
  fi

  # Brewfile 존재 확인
  [[ -f "$brewfile" ]] || die "Brewfile not found: $brewfile"

  log "Installing packages from $(basename $brewfile)..."
  if brew bundle install --file="$brewfile" 2>&1 | tee "$LOG_FILE.brewfile"; then
    ok "Brewfile install complete"
  else
    warn "Brewfile install had issues — checking critical packages"
  fi

  # SELF-HEAL: ensure critical packages are installed
  local critical=(chezmoi tmux starship git gh atuin direnv mise lsd bat fd ripgrep fzf)
  local missing=()

  for pkg in "${critical[@]}"; do
    if ! brew list --formula "$pkg" &>/dev/null && ! command -v "$pkg" &>/dev/null; then
      missing+=("$pkg")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    log "Installing missing critical packages: ${missing[*]}"
    for pkg in "${missing[@]}"; do
      brew install "$pkg" 2>&1 | tail -2 || warn "Failed: $pkg"
    done
    hash -r
  fi

  ok "Brewfile phase complete"
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
  # Self-heal: ensure Node.js is available (mise → brew fallback)
  if ! command -v npm &>/dev/null; then
    log "Node.js not found — installing..."

    if command -v mise &>/dev/null; then
      eval "$(mise activate bash)" 2>/dev/null || true
      mise install node@24 2>/dev/null || true
      mise use --global node@24 2>/dev/null || true
      hash -r
    fi

    if ! command -v npm &>/dev/null; then
      brew install node 2>&1 | tail -3 || true
      hash -r
    fi

    if ! command -v npm &>/dev/null; then
      err "Failed to install Node.js. Run: brew install node"
      return 1
    fi
    ok "Node.js: $(node --version)"
  else
    ok "Node.js: $(node --version)"
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

  # Gemini CLI (npm package, install if missing)
  if ! command -v gemini &>/dev/null; then
    log "Installing Gemini CLI (npm)..."
    npm install -g @google/gemini-cli 2>&1 | tail -3 || warn "Gemini install failed (continuing)"
    hash -r
  fi
  command -v gemini &>/dev/null && ok "Gemini CLI" || warn "Gemini not installed (optional)"

  return 0  # gemini optional — never fail phase
}

# =============================================================================
# Phase 7: chezmoi apply (manage all dotfiles)
# =============================================================================
phase_chezmoi() {
  # Self-heal: install chezmoi if missing
  if ! command -v chezmoi &>/dev/null; then
    warn "chezmoi not found — installing now"
    brew install chezmoi || die "Failed to install chezmoi. Run: brew install chezmoi"
    hash -r
  fi
  ok "chezmoi: $(chezmoi --version | head -1)"

  # Ensure machine-detect.sh is executable
  chmod +x "$DOTFILES_DIR/scripts/machine-detect.sh" 2>/dev/null || true

  # Backup existing dotfiles
  local backup_dir="$HOME/.bootstrap-backup-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$backup_dir"
  for f in .zshrc .tmux.conf .gitconfig; do
    if [[ -f "$HOME/$f" ]] && [[ ! -L "$HOME/$f" ]]; then
      cp "$HOME/$f" "$backup_dir/" && log "Backup: $f"
    fi
  done

  # Initialize chezmoi pointing to the repo
  if [[ ! -d "$HOME/.local/share/chezmoi" ]] || \
     [[ -z "$(ls -A "$HOME/.local/share/chezmoi" 2>/dev/null)" ]]; then
    log "Initializing chezmoi from $DOTFILES_DIR..."
    chezmoi init --source "$DOTFILES_DIR" 2>/dev/null || true
  fi

  # SELF-HEAL: If chezmoi init didn't create data file, generate from machine-detect
  if [[ ! -f "$HOME/.config/chezmoi/chezmoi.toml" ]]; then
    warn "chezmoi data file missing — auto-generating"
    mkdir -p "$HOME/.config/chezmoi"

    local detect="$DOTFILES_DIR/scripts/machine-detect.sh"
    local d_machine d_arch d_chip d_ram d_profile d_ai
    d_machine=$("$detect" machine_id 2>/dev/null || echo "personal")
    d_arch=$("$detect" arch 2>/dev/null || uname -m)
    d_chip=$("$detect" chip 2>/dev/null || sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "unknown")
    d_ram=$("$detect" ram_gb 2>/dev/null || echo "8")
    d_profile=$("$detect" profile 2>/dev/null || echo "lite")
    d_ai=$("$detect" ai_concurrent 2>/dev/null || echo "2")
    local is_arm=false
    [[ "$d_arch" == "arm64" ]] && is_arm=true

    cat > "$HOME/.config/chezmoi/chezmoi.toml" <<TOML
[data]
    name = "박승호"
    email = "0xOrOi0x@users.noreply.github.com"
    github_user = "0xOrOi0x"
    machine = "${d_machine}"
    arch = "${d_arch}"
    chip = "${d_chip}"
    ram_gb = "${d_ram}"
    profile = "${d_profile}"
    ai_concurrent = "${d_ai}"
    is_apple_silicon = ${is_arm}
TOML
    ok "Auto-generated chezmoi data (machine=${d_machine}, profile=${d_profile})"
  else
    ok "chezmoi data file present"
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
  run_phase "oss-cleanup"    phase_oss_cleanup
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
