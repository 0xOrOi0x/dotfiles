# 💪 Intel Mac Guide

## Supported Intel Macs

This dotfiles configuration supports Intel Macs through automatic detection and a separate `Brewfile.intel` package list.

### Tested Configurations
- **MacBook Pro 16" 2019** (Intel Core i9, 16GB RAM, macOS 15) ✅
- MacBook Pro 13" 2020 (Intel) — should work
- iMac 2019/2020 (Intel) — should work

### macOS Version Support
- ✅ macOS 15 Sequoia (recommended)
- ✅ macOS 14 Sonoma
- ⚠️  macOS 13 Ventura (Ghostty may have minor issues)
- ❌ macOS 12 or older (not supported)

## Differences from Apple Silicon

The bootstrap automatically detects Intel and applies these changes:

| Component | Apple Silicon | Intel |
|:---|:---|:---|
| Homebrew prefix | `/opt/homebrew` | `/usr/local` |
| Brewfile | `Brewfile` | `Brewfile.intel` |
| Container runtime | OrbStack | Docker Desktop |
| AI agents (max concurrent) | 4 | 2 |
| Ghostty transparency | 0.85 | 0.92 |
| tmux history | 500K | 100K |
| 3-way consensus review | Enabled | Disabled (warns) |
| Cockpit panes | 4 (with Gemini) | 3 (without Gemini) |

## Performance Expectations

| Operation | M5 (24GB) | Intel i9 2019 (16GB) |
|:---|:---:|:---:|
| Bootstrap | ~22 min | ~50 min |
| Brewfile install | ~12 min | ~30 min |
| Cold zsh start | < 1s | < 1.5s |
| Claude response | network-bound | network-bound |
| Multi-agent (3-way) | smooth | thermal throttling |

## Recommended Workflows on Intel

### ✅ Good fit
- Single-agent Plan Mode (`plan` command)
- Single-agent code review (`review-light` command)
- Reading/researching with Claude
- Sequential workflow (Plan → Implement → Test)

### ⚠️ Use sparingly
- 4-pane cockpit (omits Gemini automatically)
- Long-running multi-agent sessions
- Battery-only operation (>30 min)

### ❌ Avoid
- 3-way consensus review (disabled, use full-profile machine)
- Multiple cockpits simultaneously
- Heavy LLM workloads while battery <50%

## Thermal Management

```bash
# Always run before heavy work
sysmon

# If memory >80% or active_agents >2:
# 1. Close non-essential cockpits
# 2. Connect AC adapter
# 3. Use 'plan' instead of 'cockpit'
```

## Two-Machine Workflow Recommendation

If you have both Apple Silicon (e.g., M5 Air) and Intel (e.g., 2019 Pro):

| Task | Best Machine |
|:---|:---|
| Multi-agent development | Apple Silicon |
| 3-way code reviews | Apple Silicon |
| Mobile/cafe work | Apple Silicon (better battery) |
| Large screen + external monitor | Intel Pro 16" |
| Long-running compile/test | Intel Pro (with AC) |
| Home server (sshd + Tailscale) | Intel Pro (always plugged in) |

See `docs/TWO_MACHINE_SETUP.md` for synchronization details.
