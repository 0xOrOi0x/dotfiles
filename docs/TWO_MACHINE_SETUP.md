# 🔀 Two-Machine Sync Guide

This guide explains how to keep two Macs (e.g., MacBook Air M5 + MacBook Pro Intel) in sync.

## Architecture

```
┌─────────────────────┐    ┌─────────────────────┐
│   air-m5 (Apple)    │    │  pro-intel (Intel)  │
│   - Full profile    │    │  - Lite profile     │
│   - 4 AI concurrent │    │  - 2 AI concurrent  │
└──────────┬──────────┘    └──────────┬──────────┘
           │                          │
           └──────────┬───────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
┌───────▼────────┐   ┌────────────▼─────────┐
│   GitHub       │   │   Atuin Sync Server  │
│ - dotfiles     │   │ - Encrypted history  │
│ - your code    │   │ - Cross-device       │
└────────────────┘   └──────────────────────┘
        │
┌───────▼─────────┐
│   1Password     │
│ - SSH keys      │
│ - API secrets   │
│ - Atuin keys    │
└─────────────────┘
```

## Sync Layers

### Layer 1: dotfiles (via chezmoi + GitHub)

Both machines clone the same repo. chezmoi auto-detects each machine's profile.

```bash
# On both machines (auto-detects):
sh -c "$(curl -fsSL https://raw.githubusercontent.com/0xOrOi0x/dotfiles/main/install)"

# Daily updates:
dot-update
```

### Layer 2: Shell history (via Atuin)

```bash
# First machine (e.g., air-m5):
atuin register -u liam-park -e your@email.com
# ⚠️ SAVE THE ENCRYPTION KEY in 1Password immediately

# Second machine (e.g., pro-intel):
atuin login -u liam-park
# Enter password + encryption key from 1Password
atuin sync

# Now: Ctrl+R on either machine searches global history
```

### Layer 3: Secrets (via 1Password)

Both machines use the same vault. SSH keys live in 1Password too.

```bash
# Both machines:
op signin
# In 1Password app: Settings → Developer → Use SSH Agent

# Verify:
ssh-add -l    # Shows keys from 1Password
```

`.envrc` example using 1Password:
```bash
export ANTHROPIC_API_KEY="$(op read 'op://Private/Anthropic/api_key')"
export OPENAI_API_KEY="$(op read 'op://Private/OpenAI/api_key')"
```

### Layer 4: Code (via GitHub)

Standard git workflow. With 1Password SSH agent, both machines authenticate seamlessly.

```bash
git push   # Touch ID prompt on both machines
```

## Optional: Home Server Mode

Make `pro-intel` always-available for remote ssh:

```bash
# On pro-intel:
bash ~/.dotfiles/scripts/enable-home-server.sh

# This installs Tailscale and enables sshd.
# Then from air-m5:
ssh pro-intel
# or attach to a tmux session:
ssh -t pro-intel tmux attach
```

## Daily Workflow Examples

### Scenario A: Morning at home, afternoon at cafe

1. **Morning (pro-intel)**: 
   ```bash
   cd ~/Code/STELLAR && plan "ISP draft for Q2"
   # Plan saved, work in progress
   git add . && git commit -m "wip: Q2 plan" && git push
   ```

2. **Afternoon (air-m5)**: 
   ```bash
   cd ~/Code/STELLAR && git pull
   cockpit q2-isp "Continue ISP work from morning"
   # Atuin Ctrl+R shows your morning commands
   ```

### Scenario B: Heavy review needs full profile

```bash
# On air-m5 (full profile):
review 341    # 3-way consensus

# On pro-intel (auto-warns):
$ review 341
⚠️ Lite profile: using single-agent review (Claude only)
```

### Scenario C: External monitor work

```bash
# pro-intel connected to 27" external:
# - Use AeroSpace workspaces 1-5 across two screens
# - Run 'plan' for design (single agent, light load)
# - Use VS Code or Cursor for actual coding
# - Push at end of day for air-m5 to pick up
```

## Troubleshooting

| Problem | Solution |
|:---|:---|
| Atuin not syncing | `atuin sync` then `atuin status` |
| 1Password SSH not working | App → Settings → Developer → Enable SSH agent |
| chezmoi shows wrong machine | `chezmoi init --source ~/.dotfiles` and re-prompt |
| Different behavior on machines | Run `dot-info` on each, compare profiles |
| Brewfile picked wrong on Intel | `cat ~/.bootstrap-markers/brewfile` and check |
