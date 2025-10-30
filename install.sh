#!/bin/bash
set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

echo "Syncing..."

pacman -Syu --noconfirm