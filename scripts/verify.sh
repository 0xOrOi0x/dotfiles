#!/usr/bin/env bash
# Health check v3.2 — verify all key tools + machine profile
set -uo pipefail

C_GREEN='\033[0;32m'
C_RED='\033[0;31m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[0;34m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

# Show machine profile first
echo "━━━ Health Check v3.2 ━━━"
echo ""

if [[ -x "$HOME/.dotfiles/scripts/machine-detect.sh" ]]; then
  printf "${C_BLUE}🏷  Machine Profile${C_RESET}\n"
  eval "$("$HOME/.dotfiles/scripts/machine-detect.sh" all)"
  printf "  Machine ID:    ${C_BOLD}%s${C_RESET}\n" "$MACHINE_ID"
  printf "  Chip:          %s\n" "$CHIP"
  printf "  Arch:          %s\n" "$ARCH"
  printf "  RAM:           %s GB\n" "$RAM_GB"
  printf "  macOS:         %s\n" "$MACOS_VERSION"
  printf "  Profile:       ${C_BOLD}%s${C_RESET}\n" "$PROFILE"
  printf "  AI concurrent: %s\n" "$AI_CONCURRENT"
  echo ""
fi

fail=0
warn=0
pass=0

check() {
  local name="$1"; local cmd="${2:-$1}"
  if command -v "$cmd" &>/dev/null; then
    printf "${C_GREEN}✓${C_RESET} %s\n" "$name"
    pass=$((pass+1))
  else
    printf "${C_RED}✗${C_RESET} %s ${C_YELLOW}(not installed)${C_RESET}\n" "$name"
    fail=$((fail+1))
  fi
}

check_app() {
  local name="$1"
  if [[ -d "/Applications/$name.app" ]] || [[ -d "$HOME/Applications/$name.app" ]]; then
    printf "${C_GREEN}✓${C_RESET} %s.app\n" "$name"
    pass=$((pass+1))
  else
    printf "${C_YELLOW}⚠${C_RESET} %s.app ${C_YELLOW}(not in Applications)${C_RESET}\n" "$name"
    warn=$((warn+1))
  fi
}

check_func() {
  local fn="$1"
  if grep -qE "^(function +)?${fn}[ \t]*\(\)" "$HOME/.zshrc" 2>/dev/null; then
    printf "${C_GREEN}✓${C_RESET} function: %s\n" "$fn"
    pass=$((pass+1))
  else
    printf "${C_RED}✗${C_RESET} function: %s\n" "$fn"
    fail=$((fail+1))
  fi
}

check_file() {
  local path="$1"; local label="${2:-$1}"
  if [[ -f "$path" ]]; then
    printf "${C_GREEN}✓${C_RESET} file: %s\n" "$label"
    pass=$((pass+1))
  else
    printf "${C_RED}✗${C_RESET} file: %s\n" "$label"
    fail=$((fail+1))
  fi
}

echo "── Core ──"
check brew; check git; check zsh; check tmux; check starship

echo "── Modern CLI ──"
check lsd; check bat; check ripgrep rg; check fd; check fzf
check zoxide; check lazygit; check delta; check glow; check jq

echo "── AI Agents ──"
check "Claude Code" claude
check "Codex CLI" codex
check "Gemini CLI" gemini

echo "── Persistence & Secrets ──"
check atuin; check direnv; check mise; check chezmoi; check bw

echo "── GUI Apps ──"
check_app Ghostty
check_app AeroSpace
check_app Hammerspoon
check_app Karabiner-Elements
check_app Bitwarden

# Container runtime — Colima (OSS, both arch)
check colima
check docker

echo "── Config files ──"
check_file "$HOME/.zshrc" "~/.zshrc"
check_file "$HOME/.tmux.conf" "~/.tmux.conf"
check_file "$HOME/.config/ghostty/config" "Ghostty config"
check_file "$HOME/.config/starship.toml" "Starship config"
check_file "$HOME/.config/aerospace/aerospace.toml" "AeroSpace config"
check_file "$HOME/.claude/settings.json" "Claude Code settings"
check_file "$HOME/.ssh/config" "SSH config (ssh-agent)"

echo "── Multi-agent helper functions ──"
for fn in cockpit aclaude acodex agemini status agents review plan cleanup-wt tools dot-info sysmon; do
  check_func "$fn"
done

echo ""
echo "━━━ Summary ━━━"
printf "  Passed: ${C_GREEN}%d${C_RESET}\n" "$pass"
printf "  Failed: ${C_RED}%d${C_RESET}\n" "$fail"
printf "  Warn:   ${C_YELLOW}%d${C_RESET}\n" "$warn"

if [[ $fail -eq 0 ]]; then
  printf "\n${C_GREEN}${C_BOLD}✓ All checks passed${C_RESET}\n"
  echo ""
  echo "Try: ${C_BOLD}cockpit test \"smoke test\"${C_RESET}"
  echo "Or:  ${C_BOLD}dot-info${C_RESET} to see machine profile"
  exit 0
else
  printf "\n${C_RED}${C_BOLD}✗ %d failures${C_RESET}\n" "$fail"
  echo "Try: ${C_BOLD}exec zsh${C_RESET} (reload shell)"
  exit 1
fi
