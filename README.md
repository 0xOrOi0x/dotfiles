# 🚀 dotfiles

> **Multi-Agent Dev Environment** for macOS · 단 한 줄로 모든 환경 복원
> Ghostty · tmux · Claude Code · Codex CLI · Gemini CLI · AeroSpace

[![macOS](https://img.shields.io/badge/macOS-15%2B-black?logo=apple)](https://www.apple.com/macos/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 🪄 한 줄 설치

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/0xOrOi0x/dotfiles/main/install)"
```

**소요 시간**: 약 25~40분 (네트워크 속도에 따라).
신선한 macOS에서 이 한 줄만 실행하면 — Xcode CLT 설치 → repo clone → Homebrew → 40+ 패키지 → AI 에이전트 3종 → chezmoi 적용 → macOS 기본값까지 모두 자동.

---

## 📦 설치되는 것들

<details>
<summary><b>🐚 Shell & Terminal (펼치기)</b></summary>

- **[Ghostty](https://ghostty.org)** — GPU 가속 터미널 (Zig 기반)
- **[tmux](https://github.com/tmux/tmux)** + resurrect/continuum — 영속 세션
- **[Starship](https://starship.rs)** — Rust 프롬프트 (Catppuccin Mocha)
- **Oh My Zsh** + **[Zinit](https://github.com/zdharma-continuum/zinit)** — 플러그인 매니저
- **[Atuin](https://atuin.sh)** — 암호화 동기화 셸 히스토리
- **[direnv](https://direnv.net)** — 프로젝트별 env 자동 로드
- **[mise](https://mise.jdx.dev)** — 런타임 버전 매니저 (nvm/pyenv 통합)
</details>

<details>
<summary><b>🛠️ Modern CLI</b></summary>

| 기존 | 대체 | 비고 |
|:---|:---|:---|
| `ls` | [lsd](https://github.com/lsd-rs/lsd) | 아이콘 |
| `cat` | [bat](https://github.com/sharkdp/bat) | 구문 강조 |
| `find` | [fd](https://github.com/sharkdp/fd) | 직관적 |
| `grep` | [ripgrep](https://github.com/BurntSushi/ripgrep) | 초고속 |
| `cd` | [zoxide](https://github.com/ajeetdsouza/zoxide) | 스마트 |
| `top` | [btop](https://github.com/aristocratos/btop) | 그래프 |
| `du`/`df` | dust/duf | 시각화 |
| `diff` | [delta](https://github.com/dandavison/delta) | side-by-side |
| Git UI | [lazygit](https://github.com/jesseduffield/lazygit) | TUI |
| MD viewer | [glow](https://github.com/charmbracelet/glow) | 터미널 렌더 |

추가: `tokei`, `hyperfine`, `jless`, `httpie`, `gron`, `jq`, `yq`, `navi`, `fzf`
</details>

<details>
<summary><b>🤖 AI Coding Agents</b></summary>

- **[Claude Code](https://claude.com/code)** — Anthropic 공식 CLI (Plan Mode + Subagents + Hooks)
- **[Codex CLI](https://github.com/openai/codex)** — OpenAI (multi_agent_v2 활성)
- **[Gemini CLI](https://github.com/google-gemini/gemini-cli)** — Google (1M context)
- **[OMC plugin](https://github.com/Yeachan-Heo/oh-my-claudecode)** — Claude Code 멀티 에이전트 워크플로우
</details>

<details>
<summary><b>🪟 Window Management</b></summary>

- **[AeroSpace](https://github.com/nikitabobko/AeroSpace)** — i3-스타일 타일링 (SIP 비활성화 X)
- **[Karabiner-Elements](https://karabiner-elements.pqrs.org)** — Caps Lock → Hyper Key
- **[Raycast](https://www.raycast.com)** — Spotlight + AI 런처
</details>

<details>
<summary><b>🔐 Security & Productivity</b></summary>

- **1Password CLI (`op`)** — API 키 안전 주입
- **[OrbStack](https://orbstack.dev)** — Docker Desktop 대체 (가벼움, 빠름)
- **[Bruno](https://www.usebruno.com)** — git-friendly API 테스트
- **[chezmoi](https://www.chezmoi.io)** — 선언적 dotfiles
- **[Marp CLI](https://marp.app)** + Pandoc + Mermaid CLI — 문서·발표
</details>

---

## 🎯 설치 후 첫 단계

```bash
# 1. 셸 재시작
exec zsh

# 2. AI 에이전트 인증
claude          # Anthropic
codex login     # OpenAI
gemini          # Google

# 3. tmux 플러그인
tmux            # then: Ctrl+Space → Shift+I

# 4. Atuin 동기화 (선택, 강추)
atuin register -u <USERNAME> -e <EMAIL>
atuin import auto && atuin sync
# ⚠️ 출력된 암호화 키를 1Password에 저장!

# 5. 권한 부여
# 시스템 설정 → 손쉬운 사용 → AeroSpace, Karabiner, Raycast 추가

# 6. 첫 콕핏 테스트
mkdir -p ~/Code/test && cd ~/Code/test
git init && touch AGENTS.md && git add . && git commit -m "init"
cockpit hello "Hello world test"
```

---

## ⌨️ 일상 명령어

```bash
# 🎼 멀티 에이전트
cockpit <feature> "<task>"     # 4-pane 콕핏 시작
status                          # 모든 워커 진행률
agents                          # fzf로 활성 세션 점프
review <PR번호>                  # 3-way 컨센서스 리뷰
plan "<요구사항>"                # Claude Plan Mode
cc-check                        # 헤들리스 빌드 검증
cleanup-wt <feature>            # 워크트리 정리

# 📜 dotfiles 관리
dot                             # cd ~/.dotfiles
dot-edit <file>                 # chezmoi edit
dot-apply                       # chezmoi apply
dot-update                      # 전체 업데이트
dot-verify                      # 헬스체크
```

### Ghostty 단축키
- `Cmd+D` / `Cmd+Shift+D` — 분할
- `Cmd+Alt+화살표` — 패널 이동
- `Cmd+Shift+Enter` — 줌
- `Cmd+1~5` — 탭(프로젝트) 전환

### tmux (Prefix = `Ctrl+Space`)
- `Prefix+S` — STATUS 팝업
- `Prefix+A` — AGENTS.md 팝업
- `Prefix+R` — 리뷰 결과
- `Prefix+W` — 워크트리 점프
- `Prefix+G` — lazygit 풀스크린

### AeroSpace (`Alt` = Option)
- `Alt+1~5` — 워크스페이스
- `Alt+H/J/K/L` — 포커스 이동
- `Alt+Shift+1~5` — 윈도우 이동
- `Alt+/` — 타일/액코디언
- `Alt+F` — 전체화면

---

## 🏗️ 아키텍처

```
┌─────────────────────────────────────────────────┐
│ L7  AeroSpace (워크스페이스 1~5)                  │
├─────────────────────────────────────────────────┤
│ L6  Ghostty (GPU 가속, Tabs, Splits)            │
├─────────────────────────────────────────────────┤
│ L5  tmux (영속 세션) + Atuin (히스토리 sync)     │
├─────────────────────────────────────────────────┤
│ L4  zsh + Oh My Zsh + Zinit + Starship          │
├─────────────────────────────────────────────────┤
│ L3  Modern CLI (lsd/bat/rg/fzf/lazygit/...)     │
├─────────────────────────────────────────────────┤
│ L2  Claude Code · Codex · Gemini                │
├─────────────────────────────────────────────────┤
│ L1  1Password CLI · direnv · gnupg              │
├─────────────────────────────────────────────────┤
│ L0  Homebrew · chezmoi · mise                   │
└─────────────────────────────────────────────────┘
```

자세한 방법론은 [블로그 포스트](https://github.com/0xOrOi0x/dotfiles/wiki) 참조.

---

## 🔄 일상 운영

```bash
# 매일 아침
dot-update      # repo pull + chezmoi apply + brew upgrade + AI agents update

# 새 머신 셋업
sh -c "$(curl -fsSL https://raw.githubusercontent.com/0xOrOi0x/dotfiles/main/install)"
atuin login -u <USERNAME>      # 히스토리 복원
op signin                       # 1Password
# 끝.

# 특정 단계만 재실행
bash ~/.dotfiles/bootstrap.sh --skip macos-defaults
bash ~/.dotfiles/bootstrap.sh --reset    # 처음부터
```

---

## 📁 Repo 구조

```
dotfiles/
├── install                       # 한 줄 설치 진입점
├── bootstrap.sh                  # 메인 설치 스크립트
├── Brewfile                      # 선언적 패키지 목록
├── .chezmoiroot                  # → home/
├── .chezmoi.toml.tmpl            # 머신별 변수
├── home/                         # chezmoi 관리 dotfiles
│   ├── dot_zshrc.tmpl
│   ├── dot_tmux.conf
│   ├── dot_gitconfig.tmpl
│   ├── dot_config/
│   │   ├── ghostty/config
│   │   ├── starship.toml
│   │   ├── aerospace/aerospace.toml
│   │   ├── karabiner/karabiner.json
│   │   ├── atuin/config.toml
│   │   ├── direnv/direnvrc
│   │   └── gemini/settings.json
│   ├── dot_claude/{settings.json, hooks/}
│   ├── dot_codex/config.toml
│   └── dot_agents/prompts/
├── scripts/
│   ├── verify.sh                 # 헬스체크
│   ├── update.sh                 # 일일 업데이트
│   ├── nuke.sh                   # 완전 초기화 (위험)
│   └── macos-defaults.sh         # macOS 기본값
└── .github/workflows/
    ├── shellcheck.yml            # bash 정적 분석
    └── macos-smoke-test.yml      # 주간 macOS 검증
```

---

## 🛡️ 보안

- **시크릿은 절대 commit 금지** — `.gitignore`에 `.env`, `*.pem`, `*.key` 등 등록됨
- **1Password 통합** — API 키는 `op read 'op://Vault/Item/field'` 로 동적 주입
- **direnv** — 프로젝트별 `.envrc`에서 1Password 호출
- **Claude Code hook** — 비밀키 패턴 자동 차단 (`home/dot_claude/hooks/`)

`.envrc.example` 위치: `~/.agents/prompts/envrc.example`

---

## 🐛 트러블슈팅

| 증상 | 해결 |
|:---|:---|
| `command not found: brew` | `eval "$(/opt/homebrew/bin/brew shellenv)"` |
| `cockpit` 함수 없음 | `exec zsh` |
| AeroSpace 동작 X | 시스템 설정 → 손쉬운 사용 권한 부여 |
| `claude` 명령 없음 | `curl -fsSL https://claude.ai/install.sh \| bash` |
| 한글 깨짐 | Ghostty config의 두 번째 `font-family` 확인 |
| 처음부터 다시 | `bash ~/.dotfiles/bootstrap.sh --reset` |

자세한 헬스체크: `dot-verify`

---

## 📝 라이선스

MIT © 2026 [박승호 (Liam Park)](https://github.com/0xOrOi0x)

---

## 🙏 영감받은 곳

- [DND 기술 블로그 — 2026 Mac 터미널 완벽 세팅](https://blog.dnd.ac/settings-mac-terminal-2026/)
- [agents.md](https://agents.md) — AI 에이전트 인스트럭션 표준
- [Anthropic 2026 Agentic Coding Trends](https://www.anthropic.com)

---

> *"환경 셋업은 한 번만 하는 게 아니라, 시스템화해야 한다.*
> *새 머신을 사도, 초기화해도, 30분이면 어제와 같은 환경."*
