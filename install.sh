#!/bin/bash

yes | sudo dnf update
yes | sudo dnf install hyprland waybar wofi kitty wayland-devel hyprlang-devel cmake wayland-protocols-devel pango-devel cairo-devel file-devel libglvnd-devel libglvnd-core-devel libjpeg-turbo-devel libwebp-devel gcc-c++


git clone https://github.com/hyprwm/hyprpaper

cd hyprpaper

yes | cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
yes | cmake --build ./build --config Release --target hyprpaper -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`

yes | cmake --install ./build

cd ..

sudo git clone https://gitlab.com/phoneybadger/pokemon-colorscripts.git
cd pokemon-colorscripts
sudo chmod +x ./install.sh
sudo ./install.sh

cd ..

if [ -d ~/.config/hypr ]; then
    rm -rf ~/.config/hypr
fi

ln -sf ~/dotfiles/hypr ~/.config/hypr

if [ -d ~/.config/kitty ]; then
    rm -rf ~/.config/kitty
fi

ln -sf ~/dotfiles/kitty ~/.config/kitty

if [ -d ~/.config/waybar ]; then
    rm -rf ~/.config/waybar
fi

ln -sf ~/dotfiles/waybar ~/.config/waybar

if [ -d ~/.gitconfig ]; then
    rm ~/.gitconfig
fi

ln -sf ~/dotfiles/.gitconfig ~/.gitconfig

if [ -d ~/.bashrc ]; then
    rm ~/.bashrc
fi

ln -sf ~/dotfiles/.bashrc ~/.bashrc
