#!/usr/bin/env bash
# Linux notification for Claude Code hooks (requires notify-send)
# Usage: bash claude-notify-linux.sh <EventType>
# Add to settings.json hooks:
#   "command": "bash \"$HOME/.claude/scripts/claude-notify-linux.sh\" Stop"

EVENT_TYPE="${1:-Notification}"
notify-send "Claude Code" "$EVENT_TYPE" 2>/dev/null || true
