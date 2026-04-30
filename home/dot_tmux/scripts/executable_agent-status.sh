#!/usr/bin/env bash
status_dir="$HOME/.agents/status"
[ ! -d "$status_dir" ] && exit 0
count=$(ls "$status_dir"/*.md 2>/dev/null | wc -l | tr -d ' ')
[ "$count" -eq 0 ] && exit 0
avg=$(grep -h "^- progress:" "$status_dir"/*.md 2>/dev/null | \
  awk -F'[: %]' '{sum+=$3; n++} END {if (n>0) printf "%d", sum/n; else print 0}')
echo "🤖 ${count} · ${avg}%"
