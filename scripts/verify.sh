#!/usr/bin/env bash
# Health check — verify all key tools are installed
# Robust function check via static .zshrc grep (works in bash subprocess)
set -uo pipefail

C_GREEN='\033[0;32m'
C_RED='\033[0;31m'
C_YELLOW='\033[1;33m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

echo "━━━ Health Check ━━━"

fail=0
warn=0

check() {
  local name="$1"; local cmd="${2:-$1}"
  if command -v "$cmd" &>/dev/null; then
    printf "${C_GREEN}✓${C_RESET} %s\n" "$name"
  else
    printf "${C_RED}✗${C_RESET} %s ${C_YELLOW}(not installed)${C_RESET}\n" "$name"
    fail=$((fail+1))
  fi
}

check_app() {
  local name="$1"
  if [[ -d "/Applications/$name.app" ]] || [[ -d "$HOME/Applications/$name.app" ]]; then
    printf "${C_GREEN}✓${C_RESET} %s.app\n" "$name"
  else
    printf "${C_YELLOW}⚠${C_RESET} %s.app ${C_YELLOW}(not in Applications)${C_RESET}\n" "$name"
    warn=$((warn+1))
  fi
}

check_func() {
  # Static check: function defined in .zshrc?
  local fn="$1"
  if grep -qE "^(function +)?${fn}[ \t]*\(\)" "$HOME/.zshrc" 2>/dev/null; then
    printf "${C_GREEN}✓${C_RESET} function: %s\n" "$fn"
  else
    printf "${C_RED}✗${C_RESET} function: %s ${C_YELLOW}(missing in ~/.zshrc)${C_RESET}\n" "$fn"
    fail=$((fail+1))
  fi
}

check_file() {
  local path="$1"; local label="${2:-$1}"
  if [[ -f "$path" ]]; then
    printf "${C_GREEN}✓${C_RESET} file: %s\n" "$label"
  else
    printf "${C_RED}✗${C_RESET} file: %s ${C_YELLOW}(missing)${C_RESET}\n" "$label"
    fail=$((fail+1))
  fi
}

echo "── Core ──"
check brew
check git
check zsh
check tmux
check starship

echo "── Modern CLI ──"
check lsd
check bat
check ripgrep rg
check fd
check fzf
check zoxide
check lazygit
check delta git-delta
check glow
check jq

echo "── AI Agents ──"
check "Claude Code" claude
check "Codex CLI" codex
check "Gemini CLI" gemini

echo "── Persistence & Secrets ──"
check atuin
check direnv
check mise
check chezmoi
check op            # 1Password CLI

echo "── GUI Apps ──"
check_app Ghostty
check_app AeroSpace
check_app Raycast
check_app Karabiner-Elements
check_app 1Password
check_app OrbStack

echo "── Config files ──"
check_file "$HOME/.zshrc" "~/.zshrc"
check_file "$HOME/.tmux.conf" "~/.tmux.conf"
check_file "$HOME/.config/ghostty/config" "Ghostty config"
check_file "$HOME/.config/starship.toml" "Starship config"
check_file "$HOME/.config/aerospace/aerospace.toml" "AeroSpace config"
check_file "$HOME/.claude/settings.json" "Claude Code settings"

echo "── Multi-agent helper functions (~/.zshrc) ──"
for fn in cockpit aclaude acodex agemini status agents review plan cleanup-wt tools; do
  check_func "$fn"
done

echo ""
echo "━━━ Summary ━━━"
if [[ $fail -eq 0 ]]; then
  printf "${C_GREEN}${C_BOLD}✓ All checks passed${C_RESET}"
  [[ $warn -gt 0 ]] && printf " ${C_YELLOW}(%d warnings)${C_RESET}" "$warn"
  echo ""
  echo ""
  echo "Run: ${C_BOLD}cockpit test \"smoke test\"${C_RESET} to try the cockpit"
  exit 0
else
  printf "${C_RED}${C_BOLD}✗ %d failures${C_RESET}, ${C_YELLOW}%d warnings${C_RESET}\n" "$fail" "$warn"
  echo ""
  echo "Try: ${C_BOLD}exec zsh${C_RESET} (reload shell) then re-run verify"
  echo "Or:  ${C_BOLD}bash ~/.dotfiles/bootstrap.sh${C_RESET} (re-run installer)"
  exit 1
fi
