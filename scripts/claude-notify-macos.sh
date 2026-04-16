#!/usr/bin/env bash
# macOS notification for Claude Code hooks
# Usage: bash claude-notify-macos.sh <EventType>
# Add to settings.json hooks:
#   "command": "bash \"$HOME/.claude/scripts/claude-notify-macos.sh\" Stop"

EVENT_TYPE="${1:-Notification}"
osascript -e "display notification \"$EVENT_TYPE\" with title \"Claude Code\""
