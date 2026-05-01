-- Hammerspoon Configuration — OSS replacement for Raycast
-- Managed by chezmoi from 0xOrOi0x/dotfiles

-- ─── Hyper Key (Caps Lock via Karabiner-Elements) ───────────────────────────
local hyper = {"cmd", "alt", "ctrl", "shift"}

-- ─── App Launcher (Hyper + Letter) ──────────────────────────────────────────
local apps = {
  G = "Ghostty",
  B = "Safari",
  S = "Slack",
  C = "Visual Studio Code",
  V = "Bitwarden",          -- OSS password manager
  H = "Hoppscotch",         -- OSS API client
  F = "Finder",
  M = "Mail",
  N = "Notes",
}

for key, app in pairs(apps) do
  hs.hotkey.bind(hyper, key, function()
    hs.application.launchOrFocus(app)
  end)
end

-- ─── Window Management (replaces Raycast Window Management) ─────────────────

-- Left half
hs.hotkey.bind(hyper, "Left", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local f = win:frame()
  local s = win:screen():frame()
  f.x = s.x; f.y = s.y; f.w = s.w/2; f.h = s.h
  win:setFrame(f)
end)

-- Right half
hs.hotkey.bind(hyper, "Right", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local f = win:frame()
  local s = win:screen():frame()
  f.x = s.x + s.w/2; f.y = s.y; f.w = s.w/2; f.h = s.h
  win:setFrame(f)
end)

-- Top half
hs.hotkey.bind(hyper, "Up", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local f = win:frame()
  local s = win:screen():frame()
  f.x = s.x; f.y = s.y; f.w = s.w; f.h = s.h/2
  win:setFrame(f)
end)

-- Bottom half
hs.hotkey.bind(hyper, "Down", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local f = win:frame()
  local s = win:screen():frame()
  f.x = s.x; f.y = s.y + s.h/2; f.w = s.w; f.h = s.h/2
  win:setFrame(f)
end)

-- Maximize
hs.hotkey.bind(hyper, "Return", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  win:maximize()
end)

-- Center
hs.hotkey.bind(hyper, "Space", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local f = win:frame()
  local s = win:screen():frame()
  f.x = s.x + (s.w - f.w)/2
  f.y = s.y + (s.h - f.h)/2
  win:setFrame(f)
end)

-- ─── Reload Config ──────────────────────────────────────────────────────────
hs.hotkey.bind(hyper, "R", function()
  hs.reload()
  hs.alert.show("✅ Hammerspoon reloaded")
end)

-- ─── Quick Actions ──────────────────────────────────────────────────────────

-- Lock screen
hs.hotkey.bind(hyper, "L", function()
  hs.caffeinate.lockScreen()
end)

-- Show clipboard history (basic)
hs.hotkey.bind(hyper, "Y", function()
  hs.alert.show("Use cmd+shift+v for clipboard history\n(install hs.chooser plugin for full feature)")
end)

-- ─── Notifications ──────────────────────────────────────────────────────────
hs.alert.show("✅ Hammerspoon Loaded\nHyper key: ⌃⌥⇧⌘\nHyper+R = Reload")

-- ─── Auto-reload on file change ─────────────────────────────────────────────
function reloadConfig(files)
  for _, file in pairs(files) do
    if file:sub(-4) == ".lua" then
      hs.reload()
      return
    end
  end
end

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
