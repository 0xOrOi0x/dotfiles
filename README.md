# 🚀 dotfiles

> **100% OSS Multi-Agent Dev Environment** for macOS · Single-line setup
> Auto-detects Apple Silicon (M1~M5+) **and** Intel Macs
> Ghostty · tmux · Claude Code · Codex CLI · Gemini CLI · AeroSpace

[![ShellCheck](https://img.shields.io/badge/ShellCheck-passing-brightgreen?logo=gnu-bash&logoColor=white)](scripts/pre-push-qa.sh)
[![macOS Tested](https://img.shields.io/badge/macOS-tested-success?logo=apple&logoColor=white)](https://github.com/0xOrOi0x/dotfiles)
[![macOS](https://img.shields.io/badge/macOS-13%2B-black?logo=apple)](https://www.apple.com/macos/)
[![100% OSS](https://img.shields.io/badge/100%25-OSS-success)](docs/OSS_ALTERNATIVES.md)
[![Apple Silicon](https://img.shields.io/badge/Apple%20Silicon-✓-success)](https://en.wikipedia.org/wiki/Apple_silicon)
[![Intel Mac](https://img.shields.io/badge/Intel%20Mac-✓-success)](docs/INTEL_MAC_GUIDE.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 🆓 100% OSS 약속

이 dotfiles는 **모든 도구가 OSS 또는 진정한 freeware**입니다.

| 카테고리 | 도구 | 라이선스 |
|:---|:---|:---:|
| 비밀번호 관리 | **Bitwarden** | GPL-3 |
| 런처 | **Hammerspoon** + **Alfred** (free) | MIT/Freeware |
| 컨테이너 | **Colima** + Docker CLI | MIT/Apache-2.0 |
| API 클라이언트 | **Hoppscotch** | MIT |
| 윈도우 매니저 | **AeroSpace** | MIT |
| 키보드 | **Karabiner-Elements** | Public Domain |
| 터미널 | **Ghostty** | MIT |

> ⚠️ AI 에이전트 (Claude/Codex/Gemini)는 사용자의 자체 구독을 사용하며, dotfiles 자체는 어떤 유료 서비스에도 의존하지 않습니다.

---

## 🪄 한 줄 설치

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/0xOrOi0x/dotfiles/main/install)"
```

**그게 다입니다.** 같은 명령어가 모든 머신에서 작동:

| 머신 | 자동 감지 결과 |
|:---|:---|
| 🪶 MacBook Air M5 (24GB) | `air-m5` profile=`full`, AI=4 concurrent |
| 💪 MacBook Pro 2019 (Intel i9 16GB) | `pro-intel` profile=`lite`, AI=2 concurrent |
| 🪶 MacBook Pro M3 Max (36GB) | `pro-m3` profile=`full`, AI=4 concurrent |
| 🪶 Mac mini M4 (16GB) | `mini-m4` profile=`full`, AI=4 concurrent |

설치 시간:
- Apple Silicon: **~22분**
- Intel: **~50분**

자동 적용:
- ✅ proprietary 도구 자동 제거 (1Password, Raycast, Bruno, Docker Desktop, OrbStack)
- ✅ OSS 대체 도구 자동 설치 (Bitwarden, Hammerspoon, Alfred, Hoppscotch, Colima)
- ✅ 머신별 차등 설정 (full/lite profile)

---

## 📦 설치되는 것들

<details>
<summary><b>🐚 Shell & Terminal</b></summary>

- **Ghostty** (MIT) — GPU-accelerated terminal
- **tmux** with resurrect/continuum (ISC)
- **Starship** (ISC) — Rust prompt
- **Oh My Zsh** + **Zinit** (MIT)
- **Atuin** (MIT) — encrypted shell history sync
- **direnv** + **mise** (MIT)
</details>

<details>
<summary><b>🛠️ Modern CLI (20+ tools, all OSS)</b></summary>

`lsd` `bat` `fd` `ripgrep` `fzf` `zoxide` `lazygit` `delta` `glow` `btop` `tokei` `hyperfine` `jless` `httpie` `gron` `jq` `yq` `navi` `marp-cli` `pandoc` `mermaid-cli`
</details>

<details>
<summary><b>🤖 AI Coding Agents (사용자 구독 필요)</b></summary>

- **Claude Code** — Plan Mode + Subagents + Hooks
- **Codex CLI** — multi_agent_v2
- **Gemini CLI** — 1M context (free tier 1,000/day)
- **OMC plugin** — multi-agent workflow modes
</details>

<details>
<summary><b>🔐 Security (100% OSS)</b></summary>

- **Bitwarden** (GPL-3) — password manager + SSH key storage
- **Bitwarden CLI** (`bw`) — replaces 1Password's `op`
- **standard ssh-agent** — replaces 1Password SSH Agent
- **GnuPG** (GPL-3) — encryption
</details>

<details>
<summary><b>🪟 Window & Productivity (100% OSS)</b></summary>

- **AeroSpace** (MIT) — i3-style tiling
- **Hammerspoon** (MIT) — Lua scripting (replaces Raycast)
- **Alfred** (free tier) — launcher
- **Karabiner-Elements** (Public Domain) — Hyper Key
</details>

<details>
<summary><b>🐳 Containers (100% OSS)</b></summary>

- **Colima** (MIT) — replaces Docker Desktop
- **Docker CLI** (Apache-2.0)
- **Docker Compose** (Apache-2.0)
</details>

---

## 🎯 설치 후 첫 단계

```bash
# 1. 셸 재시작
exec zsh

# 2. 머신 프로필 확인
dot-info

# 3. AI 에이전트 인증
claude          # Anthropic
codex login     # OpenAI
gemini          # Google
gh auth login   # GitHub

# 4. Bitwarden 로그인 (1Password 대체)
bw login your@email.com
bw-unlock       # 세션 잠금해제 helper

# 5. Colima 컨테이너 런타임 시작
colima start

# 6. tmux 플러그인
tmux            # then Ctrl+Space → Shift+I

# 7. Atuin 동기화
atuin register -u <USER> -e <EMAIL>     # 첫 머신
atuin login -u <USER>                   # 다른 머신

# 8. macOS 권한
# 시스템 설정 → 손쉬운 사용 → AeroSpace, Karabiner, Hammerspoon, Alfred

# 9. 검증
dot-verify
```

---

## ⌨️ 일상 명령어

```bash
# 🎼 Multi-agent
cockpit <feature> "<task>"     # 4-pane cockpit (full) / 3-pane (lite)
status                          # all worker progress
agents                          # fzf jump to active sessions
review <PR>                     # 3-way consensus (full) / single-agent (lite)
plan "<idea>"                   # Claude Plan Mode

# 🔐 Bitwarden (replaces op)
bw-unlock                       # 세션 잠금해제
bw-get <item>                   # 비밀번호 가져오기
bw-field <item> <field>         # 커스텀 필드

# 📜 Dotfiles
dot                             # cd ~/.dotfiles
dot-info                        # 머신 프로필
dot-verify                      # 헬스체크
dot-update                      # 업데이트
```

### Hammerspoon Hyper Key (Caps Lock)

| 단축키 | 동작 |
|:---|:---|
| `Hyper+G` | Ghostty |
| `Hyper+B` | Browser |
| `Hyper+C` | VS Code |
| `Hyper+V` | Bitwarden |
| `Hyper+H` | Hoppscotch |
| `Hyper+←/→/↑/↓` | Window halves |
| `Hyper+Return` | Maximize |
| `Hyper+Space` | Center |
| `Hyper+L` | Lock screen |
| `Hyper+R` | Reload Hammerspoon |

### Ghostty
- `Cmd+D` / `Cmd+Shift+D` — split
- `Cmd+Alt+arrows` — navigate
- `Cmd+1~5` — tabs

### tmux (Prefix = `Ctrl+Space`)
- `Prefix+S/A/R/W/G/I` — popups

### AeroSpace (`Alt`)
- `Alt+1~5` — workspaces
- `Alt+H/J/K/L` — focus
- `Alt+/` — layout

---

## 🆓 OSS Migration Notes

전 버전(v3.2 이하)에서 사용된 proprietary 도구들은 자동으로 제거됩니다:

| 제거 (proprietary) | 대체 (OSS) |
|:---|:---|
| 1Password | **Bitwarden** (GPL-3) |
| 1Password CLI (`op`) | **Bitwarden CLI** (`bw`, GPL-3) |
| 1Password SSH Agent | **standard ssh-agent** |
| Raycast | **Hammerspoon** (MIT) + **Alfred** (free) |
| Bruno | **Hoppscotch** (MIT) |
| Docker Desktop | **Colima** (MIT) + Docker CLI (Apache-2.0) |
| OrbStack | **Colima** (MIT) |

자세한 내용: [`docs/OSS_ALTERNATIVES.md`](docs/OSS_ALTERNATIVES.md)

---

## 🏗️ 아키텍처

```
┌──────────────────────────────────────────────────┐
│ L7  AeroSpace (workspaces 1-5) [MIT]            │
├──────────────────────────────────────────────────┤
│ L6  Ghostty (GPU-accelerated) [MIT]              │
├──────────────────────────────────────────────────┤
│ L5  tmux + Atuin [ISC + MIT]                     │
├──────────────────────────────────────────────────┤
│ L4  zsh + Oh My Zsh + Zinit + Starship [MIT/ISC]│
├──────────────────────────────────────────────────┤
│ L3  Modern CLI (20+ OSS tools)                   │
├──────────────────────────────────────────────────┤
│ L2  Claude · Codex · Gemini (사용자 구독)        │
├──────────────────────────────────────────────────┤
│ L1  ssh-agent + Bitwarden + GPG [OSS]            │
├──────────────────────────────────────────────────┤
│ L0  Homebrew + chezmoi + mise [OSS]              │
├──────────────────────────────────────────────────┤
│ Auto-Detect: machine-detect.sh                   │
└──────────────────────────────────────────────────┘
```

---

## 📁 Repo 구조

```
dotfiles/
├── install                    # 한 줄 진입점
├── bootstrap.sh               # 메인 설치 (10 phases, OSS-aware)
├── Brewfile                   # Apple Silicon (100% OSS)
├── Brewfile.intel             # Intel Mac (100% OSS)
├── home/                      # chezmoi-managed dotfiles
│   ├── dot_zshrc.tmpl
│   ├── dot_tmux.conf.tmpl
│   ├── dot_gitconfig.tmpl
│   ├── dot_config/
│   │   ├── ghostty/config.tmpl
│   │   └── ...
│   ├── dot_hammerspoon/init.lua    # Raycast 대체
│   └── private_dot_ssh/config.tmpl  # 표준 ssh-agent
├── scripts/
│   ├── machine-detect.sh
│   ├── verify.sh
│   ├── update.sh
│   ├── nuke.sh
│   └── enable-home-server.sh
├── docs/
│   ├── INTEL_MAC_GUIDE.md
│   ├── TWO_MACHINE_SETUP.md
│   └── OSS_ALTERNATIVES.md
└── README.md
```

---

## 🛡️ 보안

- **시크릿 절대 commit 금지** — `.gitignore` 보호
- **Bitwarden** — 비밀번호 + SSH 키 (GPL-3, self-host 가능)
- **standard ssh-agent** — 표준 OpenSSH 도구
- **Atuin history filter** — API 키 패턴 자동 필터링
- **Claude Code hook** — 비밀키 자동 차단

---

## 📝 라이선스

MIT © 2026 [박승호 (Liam Park)](https://github.com/0xOrOi0x)

---

> *"Two machines, one command, zero proprietary lock-in."*
