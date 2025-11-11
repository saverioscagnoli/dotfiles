#!/usr/bin/env bash
# Random wallpaper setter using awww
# Usage: awww-random.sh /path/to/wallpapers [sleep_seconds]

set -euo pipefail

# === Arguments ===
WALLPAPER_DIR="${1:-$HOME/Pictures/wallpapers}"
SLEEP_SECONDS="${2:-0}"

# === Transition settings ===
TRANSITION="grow"
DURATION="3"

# === Check if awww is running ===
if ! pgrep -x "awww-daemon" >/dev/null; then
    echo "awww not running — starting it..."
    awww-daemon &
    sleep 1
fi

# === Pick a random image ===
RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) | shuf -n 1)

if [ -z "$RANDOM_WALLPAPER" ]; then
    echo "No images found in $WALLPAPER_DIR"
    exit 1
fi

# === Set wallpaper ===
awww img "$RANDOM_WALLPAPER" \
    --transition-type "$TRANSITION" \
    --transition-duration "$DURATION"

# === Optional sleep loop ===
if [ "$SLEEP_SECONDS" -gt 0 ]; then
    echo "Next wallpaper change in $SLEEP_SECONDS seconds..."
    sleep "$SLEEP_SECONDS"
fi
