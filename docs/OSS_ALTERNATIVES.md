# 🆓 OSS Alternatives Guide

This dotfiles uses 100% Open Source Software alternatives for all proprietary tools.

## Migration Map

| Proprietary | OSS Alternative | License | Migration Notes |
|:---|:---|:---:|:---|
| 1Password | **Bitwarden** | GPL-3 | Desktop app + CLI + SSH key storage |
| 1Password CLI (`op`) | **Bitwarden CLI** (`bw`) | GPL-3 | Helper functions: `bw-unlock`, `bw-get`, `bw-field` |
| 1Password SSH Agent | **standard ssh-agent** | OSS | Auto-loaded in `.zshrc` |
| Raycast | **Hammerspoon** + **Alfred** | MIT/Freeware | Lua scripting + free launcher |
| Bruno | **Hoppscotch** | MIT | Same git-friendly workflow |
| Docker Desktop | **Colima** + Docker CLI | MIT/Apache-2.0 | `colima start` to begin |
| OrbStack | **Colima** | MIT | Same use case |

## Bitwarden Setup (replaces 1Password)

### First-time setup
```bash
# 1. Install (auto-installed by bootstrap)
brew install --cask bitwarden
brew install bitwarden-cli

# 2. Sign up at https://vault.bitwarden.com
# (Free tier is generous and unlimited for personal use)

# 3. Login via CLI
bw login your@email.com

# 4. Unlock session
bw-unlock                # ✅ Bitwarden vault unlocked

# 5. Test
bw list items | head -5
```

### Helper Functions (in .zshrc)
```bash
bw-unlock                # 세션 시작
bw-get "GitHub API"      # 비밀번호 가져오기
bw-field "AWS" api_key   # 커스텀 필드
```

### SSH Key Storage in Bitwarden
1. Bitwarden 앱 → "+" → "SSH Key" 타입
2. Public/Private 키 페어 붙여넣기
3. 사용 시:
```bash
# Bitwarden CLI로 키 가져와서 ssh-agent에 추가
bw get item "GitHub SSH" | jq -r '.sshKey.privateKey' > /tmp/key
chmod 600 /tmp/key
ssh-add /tmp/key
shred -u /tmp/key   # 즉시 안전 삭제
```

## Hammerspoon (replaces Raycast)

### Hyper Key (Caps Lock)
Karabiner가 Caps Lock을 `⌃⌥⇧⌘` (Hyper)로 변환합니다.

### 기본 단축키
| 키 | 동작 |
|:---|:---|
| `Hyper+G` | Ghostty |
| `Hyper+B` | Browser |
| `Hyper+C` | VS Code |
| `Hyper+V` | Bitwarden |
| `Hyper+H` | Hoppscotch |
| `Hyper+←/→` | Window left/right half |
| `Hyper+↑/↓` | Window top/bottom half |
| `Hyper+Return` | Maximize |
| `Hyper+Space` | Center |
| `Hyper+L` | Lock screen |
| `Hyper+R` | Reload Hammerspoon config |

### 설정 편집
```bash
nvim ~/.hammerspoon/init.lua
# 변경 후 Hyper+R로 자동 reload
```

### Alfred (free tier 보완)
- Spotlight 대체 launcher
- 무료 티어로 기본 검색/계산기/파일 검색 OK
- Powerpack ($) 없이도 충분

## Colima (replaces Docker Desktop)

### 시작
```bash
# 컨테이너 런타임 시작
colima start

# 자동 시작 설정 (선택)
brew services start colima
```

### 사용
```bash
# 일반 docker 명령 그대로
docker run hello-world
docker-compose up
```

### 리소스 설정
```bash
# CPU 4, Memory 8GB로 시작
colima start --cpu 4 --memory 8 --disk 60

# 또는 영구 설정
colima start --edit  # YAML 편집기 열림
```

## Hoppscotch (replaces Bruno)

웹 또는 데스크탑 앱:
- 웹: https://hoppscotch.io
- 데스크탑: `brew install --cask hoppscotch`

기능:
- ✅ REST/GraphQL/WebSocket
- ✅ Collections (git-friendly JSON)
- ✅ Environment variables
- ✅ 100% MIT 라이선스

## VSCodium (선택적, VS Code 대체)

> 본 dotfiles는 사용자 선택에 따라 VS Code 유지.
> 더 순수한 OSS를 원한다면:

```bash
brew uninstall --cask visual-studio-code
brew install --cask vscodium
# 설정 마이그레이션
cp -r ~/Library/Application\ Support/Code/User/* \
      ~/Library/Application\ Support/VSCodium/User/
```

VSCodium는 같은 codebase의 100% OSS 빌드 (Microsoft 텔레메트리 X).

## Self-Hosting Options (선택적, ultimate OSS)

진정한 self-hosting을 원한다면:

| Service | Self-host | Setup |
|:---|:---|:---|
| Bitwarden | **Vaultwarden** (Rust impl) | docker compose |
| Atuin Sync | **Atuin self-hosted** | docker compose |
| GitHub | **Gitea** / **Forgejo** | Brewfile에 추가 |

`docs/SELF_HOSTING.md` 참조 (예정).
