#!/usr/bin/env bash
set -e
set -u
set -o pipefail

if [ "$EUID" -eq 0 ]; then
    REAL_USER="${SUDO_USER:-root}"
    USER_HOME=$(eval echo "~$REAL_USER")
else
    REAL_USER="$USER"
    USER_HOME="$HOME"
fi

cd "$USER_HOME"

GREEN='\033[0;32m'
NC='\033[0m'
CACHE_DIR="$USER_HOME/.cache"


# --- CLEANUP TRAP ---
cleanup() {
    if [ -d "$CACHE_DIR/awww" ]; then
        echo -e "${GREEN}Cleaning up cache folder...${NC}"
        rm -rf "$CACHE_DIR/awww"
    fi
}

trap cleanup EXIT

echo -e "${GREEN}Installing prerequisites...${NC}"

dnf update -y
dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf install git curl lz4 lz4-devel wayland-devel wayland-protocols-devel cc -y

echo -e "${GREEN}Installing Rust...${NC}"

sudo -u "$REAL_USER" env HOME="$USER_HOME" USER="$REAL_USER" bash -c '
    if [ -x "$HOME/.cargo/bin/rustup" ]; then
        echo "Rustup already installed. Updating..."
        "$HOME/.cargo/bin/rustup" update
    else
        curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    fi
'

if sudo -u "$REAL_USER" env HOME="$USER_HOME" PATH="$USER_HOME/.cargo/bin:$PATH" bash -c 'command -v rustc &>/dev/null'; then
    echo "✅ Rust installed successfully for $REAL_USER"
    source "$HOME/.cargo/env"
else
    echo "❌ Error: Rust installation failed for $REAL_USER"
    exit 1
fi

echo -e "${GREEN}Installing sway...${NC}"

dnf install sway wofi -y

mkdir -p $CACHE_DIR

if ! command -v awww >/dev/null 2>&1; then
    echo -e "${GREEN}Installing wallpaper daemon...${NC}"

    git clone https://codeberg.org/LGFae/awww "$CACHE_DIR/awww"

    cd "$CACHE_DIR/awww"

    cargo build --release

    sudo cp target/release/awww /usr/local/bin  
    sudo cp target/release/awww-daemon /usr/local/bin
fi


cd "$USER_HOME"


echo -e "${GREEN}Linking...${NC}"

DOTFILES_DIR="${USER_HOME}/.dotfiles"
CONFIG_DIR="${USER_HOME}/.config"

mkdir -p $CONFIG_DIR

ln -sf "$DOTFILES_DIR/sway"      "$CONFIG_DIR/sway"
ln -sf "$DOTFILES_DIR/foot"      "$CONFIG_DIR/foot"
ln -sf "$DOTFILES_DIR/gtk-3.0"   "$CONFIG_DIR/gtk-3.0"
ln -sf "$DOTFILES_DIR/gtk-4.0"   "$CONFIG_DIR/gtk-4.0"

echo -e "${GREEN}Done!!${NC}" 
