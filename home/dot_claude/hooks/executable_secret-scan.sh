#!/usr/bin/env bash
# Pre-tool-use hook: block commands containing API key patterns
if echo "$CLAUDE_TOOL_INPUT" | grep -qE '(sk-[a-zA-Z0-9]{20,}|AKIA[A-Z0-9]{16}|ghp_[a-zA-Z0-9]{36}|xoxb-)'; then
  echo "⛔ Secret pattern detected — blocked" >&2
  exit 2
fi
