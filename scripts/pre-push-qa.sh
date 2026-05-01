#!/usr/bin/env bash
# =============================================================================
# Pre-push QA — 30 seconds of sanity before pushing to GitHub
# =============================================================================
set -uo pipefail

C_GREEN='\033[0;32m'
C_RED='\033[0;31m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[0;34m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

printf "${C_BOLD}━━━ Pre-Push QA ━━━${C_RESET}\n\n"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

fail=0
pass=0

ok()    { printf "  ${C_GREEN}✓${C_RESET} %s\n" "$*"; pass=$((pass+1)); }
bad()   { printf "  ${C_RED}✗${C_RESET} %s\n" "$*"; fail=$((fail+1)); }
section() { printf "\n${C_BLUE}▸ %s${C_RESET}\n" "$*"; }

# ─── 1. Required files exist ────────────────────────────────────────────────
section "Required files"
required_files=(
  "install"
  "bootstrap.sh"
  "Brewfile"
  "Brewfile.intel"
  "README.md"
  "LICENSE"
  ".chezmoiroot"
  ".chezmoi.toml.tmpl"
  ".chezmoiignore"
  ".gitignore"
  "home/dot_zshrc.tmpl"
  "home/dot_tmux.conf.tmpl"
  "home/dot_gitconfig.tmpl"
  "home/dot_config/ghostty/config.tmpl"
  "home/dot_config/starship.toml"
  "home/dot_config/aerospace/aerospace.toml"
  "home/dot_claude/settings.json"
  "home/private_dot_ssh/config.tmpl"
  "scripts/machine-detect.sh"
  "scripts/verify.sh"
  "scripts/update.sh"
  "scripts/macos-defaults.sh"
  "scripts/enable-home-server.sh"
  "docs/INTEL_MAC_GUIDE.md"
  "docs/TWO_MACHINE_SETUP.md"
)

for f in "${required_files[@]}"; do
  [[ -f "$f" ]] && ok "$f" || bad "$f (missing)"
done

# ─── 2. Bash syntax ─────────────────────────────────────────────────────────
section "Bash syntax"
for f in install bootstrap.sh scripts/*.sh \
         home/dot_claude/hooks/*.sh \
         home/dot_tmux/scripts/*.sh; do
  [[ -f "$f" ]] || continue
  if bash -n "$f" 2>/dev/null; then
    ok "$f"
  else
    bad "$f (syntax error)"
  fi
done

# ─── 3. Executables ─────────────────────────────────────────────────────────
section "Executable bits"
executable_files=(
  "install"
  "bootstrap.sh"
  "scripts/verify.sh"
  "scripts/update.sh"
  "scripts/nuke.sh"
  "scripts/macos-defaults.sh"
)
for f in "${executable_files[@]}"; do
  if [[ -x "$f" ]]; then
    ok "$f (+x)"
  else
    bad "$f (not executable — run: chmod +x $f)"
  fi
done

# ─── 4. JSON validity ───────────────────────────────────────────────────────
section "JSON files"
if command -v python3 &>/dev/null; then
  while IFS= read -r f; do
    if python3 -c "import json; json.load(open('$f'))" 2>/dev/null; then
      ok "$f"
    else
      bad "$f (invalid JSON)"
    fi
  done < <(find . -name "*.json" -not -path './.git/*')
else
  printf "  ${C_YELLOW}⚠${C_RESET} python3 not found, skipping JSON validation\n"
fi

# ─── 5. TOML validity ───────────────────────────────────────────────────────
section "TOML files (non-template)"
if command -v python3 &>/dev/null; then
  while IFS= read -r f; do
    if python3 -c "import tomllib; tomllib.loads(open('$f').read())" 2>/dev/null; then
      ok "$f"
    elif python3 -c "import tomli; tomli.loads(open('$f').read())" 2>/dev/null; then
      ok "$f"
    else
      bad "$f (invalid TOML)"
    fi
  done < <(find . -name "*.toml" -not -name "*.tmpl" -not -path './.git/*')
fi

# ─── 6. YAML validity ───────────────────────────────────────────────────────
section "YAML files"
if command -v python3 &>/dev/null; then
  while IFS= read -r f; do
    if python3 -c "import yaml; yaml.safe_load(open('$f'))" 2>/dev/null; then
      ok "$f"
    else
      bad "$f (invalid YAML)"
    fi
  done < <(find . \( -name "*.yml" -o -name "*.yaml" \) -not -path './.git/*')
fi

# ─── 7. Secrets check ───────────────────────────────────────────────────────
section "Secret leak check"
secret_patterns=(
  'sk-[a-zA-Z0-9]{20,}'
  'AKIA[A-Z0-9]{16}'
  'ghp_[a-zA-Z0-9]{36}'
  'xoxb-[a-zA-Z0-9]'
  'BEGIN [A-Z]+ PRIVATE KEY'
)
leaks=0
for pattern in "${secret_patterns[@]}"; do
  matches=$(grep -rE "$pattern" . \
    --exclude-dir=.git \
    --exclude="pre-push-qa.sh" \
    --exclude="secret-scan.sh" 2>/dev/null | head -3)
  if [[ -n "$matches" ]]; then
    bad "Pattern '$pattern' found:"
    echo "$matches" | sed 's/^/      /'
    ((leaks++))
  fi
done
[[ $leaks -eq 0 ]] && ok "No secret patterns detected"

# ─── 8. .gitignore protection ───────────────────────────────────────────────
section ".gitignore coverage"
gitignore_must=(
  ".env"
  "*.pem"
  "*.key"
  ".bootstrap-markers"
)
for pattern in "${gitignore_must[@]}"; do
  if grep -qF "$pattern" .gitignore; then
    ok "$pattern"
  else
    bad "$pattern (missing in .gitignore)"
  fi
done

# ─── 9. Repo URL consistency ────────────────────────────────────────────────
section "Repo URL consistency"
expected="0xOrOi0x/dotfiles"
files_with_url=(install bootstrap.sh README.md home/dot_zshrc.tmpl)
for f in "${files_with_url[@]}"; do
  if [[ -f "$f" ]]; then
    if grep -q "$expected" "$f"; then
      ok "$f references $expected"
    else
      bad "$f does not reference $expected"
    fi
  fi
done

# ─── 10. chezmoi structure ──────────────────────────────────────────────────
section "chezmoi structure"
[[ "$(cat .chezmoiroot 2>/dev/null)" == "home" ]] \
  && ok ".chezmoiroot → home" \
  || bad ".chezmoiroot incorrect"

# Critical chezmoi naming
chezmoi_rules=(
  "home/dot_zshrc.tmpl:dot_ prefix + .tmpl → ~/.zshrc"
  "home/dot_gitconfig.tmpl:dot_ + .tmpl → ~/.gitconfig"
  "home/dot_tmux.conf.tmpl:dot_ + .tmpl → ~/.tmux.conf"
  "home/dot_config/ghostty/config.tmpl:nested + .tmpl"
  "home/dot_claude/hooks/executable_secret-scan.sh:executable_ prefix"
  "home/dot_tmux/scripts/executable_agent-status.sh:executable_ prefix"
  "home/private_dot_ssh/config.tmpl:private_ prefix → 600 perms"
)
for rule in "${chezmoi_rules[@]}"; do
  IFS=: read -r path desc <<< "$rule"
  if [[ -f "$path" ]]; then
    ok "$desc"
  else
    bad "$path (chezmoi naming issue)"
  fi
done


# ─── 11. Machine detection script test ──────────────────────────────────────
section "Machine detection script"
if [[ -x "scripts/machine-detect.sh" ]]; then
  for cmd in machine_id arch profile ai_concurrent; do
    if bash scripts/machine-detect.sh "$cmd" &>/dev/null; then
      ok "machine-detect.sh $cmd"
    else
      bad "machine-detect.sh $cmd failed"
    fi
  done
else
  bad "scripts/machine-detect.sh not executable"
fi

# ─── 12. v3.2 specific: profile-aware files ─────────────────────────────────
section "v3.2 profile-aware files"
v32_files=(
  "Brewfile.intel"
  "scripts/machine-detect.sh"
  "scripts/enable-home-server.sh"
  "home/dot_tmux.conf.tmpl"
  "home/dot_config/ghostty/config.tmpl"
  "home/private_dot_ssh/config.tmpl"
  "docs/INTEL_MAC_GUIDE.md"
  "docs/TWO_MACHINE_SETUP.md"
)
for f in "${v32_files[@]}"; do
  if [[ -f "$f" ]]; then
    ok "$f"
  else
    bad "$f (missing v3.2 file)"
  fi
done

# ─── Summary ────────────────────────────────────────────────────────────────
printf "\n${C_BOLD}━━━ Summary ━━━${C_RESET}\n"
printf "  Passed: ${C_GREEN}%d${C_RESET}\n" "$pass"
printf "  Failed: ${C_RED}%d${C_RESET}\n" "$fail"

if [[ $fail -eq 0 ]]; then
  printf "\n${C_GREEN}${C_BOLD}✓ READY TO PUSH${C_RESET}\n\n"
  cat <<NEXT
다음 명령으로 푸시:

  ${C_BOLD}gh repo create 0xOrOi0x/dotfiles \\
    --public \\
    --source=. \\
    --remote=origin \\
    --description="Multi-Agent Dev Environment for macOS · One-line install" \\
    --push${C_RESET}

NEXT
  exit 0
else
  printf "\n${C_RED}${C_BOLD}✗ NOT READY${C_RESET} — fix the failures above first.\n\n"
  exit 1
fi
