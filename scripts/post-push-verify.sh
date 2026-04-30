#!/usr/bin/env bash
# =============================================================================
# Post-push verification — confirm one-line install will work
# =============================================================================
set -uo pipefail

C_GREEN='\033[0;32m'
C_RED='\033[0;31m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[0;34m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

REPO="0xOrOi0x/dotfiles"
BRANCH="${BRANCH:-main}"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}"

printf "${C_BOLD}━━━ Post-Push Verification ━━━${C_RESET}\n"
printf "Repo:   https://github.com/%s\n" "$REPO"
printf "Branch: %s\n\n" "$BRANCH"

fail=0
ok()  { printf "  ${C_GREEN}✓${C_RESET} %s\n" "$*"; }
bad() { printf "  ${C_RED}✗${C_RESET} %s\n" "$*"; fail=$((fail+1)); }

# ─── 1. Raw URL 접근 ────────────────────────────────────────────────────────
printf "${C_BLUE}▸ Critical files reachable via HTTPS${C_RESET}\n"
critical=(
  "install"
  "bootstrap.sh"
  "Brewfile"
  ".chezmoiroot"
  "home/dot_zshrc.tmpl"
  "home/dot_config/ghostty/config"
  "scripts/verify.sh"
)
for f in "${critical[@]}"; do
  url="$RAW_BASE/$f"
  if curl -fsSL --head "$url" >/dev/null 2>&1; then
    ok "$f"
  else
    bad "$f (HTTP error: $(curl -s -o /dev/null -w '%{http_code}' "$url"))"
  fi
done

# ─── 2. install 스크립트 첫 줄 검증 ─────────────────────────────────────────
printf "\n${C_BLUE}▸ install script content${C_RESET}\n"
first_line=$(curl -fsSL "$RAW_BASE/install" 2>/dev/null | head -1)
if [[ "$first_line" == "#!/usr/bin/env bash" ]]; then
  ok "Shebang correct"
else
  bad "First line: $first_line"
fi

if curl -fsSL "$RAW_BASE/install" 2>/dev/null | grep -q "$REPO"; then
  ok "References $REPO"
else
  bad "Doesn't reference $REPO"
fi

# ─── 3. GitHub Actions ──────────────────────────────────────────────────────
printf "\n${C_BLUE}▸ GitHub Actions${C_RESET}\n"
if command -v gh &>/dev/null; then
  if gh run list --repo "$REPO" --limit 1 &>/dev/null; then
    latest=$(gh run list --repo "$REPO" --limit 1 --json status,conclusion,name -q '.[0]')
    name=$(echo "$latest" | python3 -c "import json,sys; print(json.load(sys.stdin)['name'])")
    status=$(echo "$latest" | python3 -c "import json,sys; print(json.load(sys.stdin)['status'])")
    conclusion=$(echo "$latest" | python3 -c "import json,sys; print(json.load(sys.stdin)['conclusion'] or 'pending')")
    if [[ "$conclusion" == "success" ]] || [[ "$status" == "in_progress" ]]; then
      ok "Latest workflow: $name ($status/$conclusion)"
    else
      bad "Latest workflow: $name ($status/$conclusion)"
    fi
  else
    printf "  ${C_YELLOW}⚠${C_RESET} gh CLI unauthenticated (run: gh auth login)\n"
  fi
else
  printf "  ${C_YELLOW}⚠${C_RESET} gh CLI not installed\n"
fi

# ─── 4. The ULTIMATE TEST — dry-run download ────────────────────────────────
printf "\n${C_BLUE}▸ Simulated install (dry-run)${C_RESET}\n"
tmp_install=$(mktemp)
if curl -fsSL "$RAW_BASE/install" -o "$tmp_install"; then
  if bash -n "$tmp_install"; then
    ok "Install script downloads and parses cleanly"
  else
    bad "Install script has syntax errors"
  fi
  rm -f "$tmp_install"
else
  bad "Could not download install script"
fi

# ─── Summary ────────────────────────────────────────────────────────────────
printf "\n${C_BOLD}━━━ Summary ━━━${C_RESET}\n"
if [[ $fail -eq 0 ]]; then
  printf "${C_GREEN}${C_BOLD}✓ ONE-LINE INSTALL IS LIVE${C_RESET}\n\n"
  cat <<NEXT
어디서든 한 줄:

  ${C_BOLD}sh -c "\$(curl -fsSL ${RAW_BASE}/install)"${C_RESET}

이 명령을 1Password 노트에 저장하세요. 🎉

NEXT
  exit 0
else
  printf "${C_RED}${C_BOLD}✗ %d failures${C_RESET} — push를 다시 확인하세요.\n" "$fail"
  exit 1
fi
