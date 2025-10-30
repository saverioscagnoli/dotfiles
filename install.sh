#!/bin/bash
set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then
    echo "This script must be run as root" 
    exit 1
fi

# Get the actual user who ran sudo
ACTUAL_USER=${SUDO_USER:-$USER}
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

echo "Syncing..."
pacman -Syu --noconfirm

echo "Installing sway..."
pacman -S --noconfirm sway foot wl-clipboard mako grim slurp

echo "Installing sddm..."
pacman -S --noconfirm sddm sddm-kcm
systemctl enable sddm.service

echo "Installing yay..."
pacman -S --needed --noconfirm git base-devel

# Clone and build as the actual user, not root
sudo -u $ACTUAL_USER bash << EOF
cd /tmp
rm -rf yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
EOF

echo "Setting up wallpapers..."

# Run yay as the actual user
sudo -u $ACTUAL_USER yay -S --noconfirm swww

echo "Setting up fonts..."

yay -S --noconfirm ttf-jetbrains-mono ttf-inconsolata noto-fonts-emoji noto-fonts-cjk

# Linking configuration files
ln -sf ./sway $ACTUAL_HOME/.config/sway
ln -sf ./foot $ACTUAL_HOME/.config/foot
ln -sf ./gtk-3.0 $ACTUAL_HOME/.config/gtk-3.0
ln -sf ./gtk-4.0 $ACTUAL_HOME/.config/gtk-4.0
ln -sf ./i3status $ACTUAL_HOME/.config/i3status

chown -R $ACTUAL_USER:$ACTUAL_USER $ACTUAL_HOME/.config

echo "Done!"