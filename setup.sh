#!/bin/bash
set -euo pipefail

REPO_URL="https://github.com/ep1h/vim-config.git"
REPO_DIR="$HOME/vim-config"

# Clone repo if not already present
if [ -d "$REPO_DIR" ]; then
    echo "Repository already exists at $REPO_DIR, pulling latest changes..."
    git -C "$REPO_DIR" pull
else
    git clone "$REPO_URL" "$REPO_DIR"
fi

# Backup existing .vimrc if it exists and is not already our symlink
if [ -f "$HOME/.vimrc" ] && [ ! -L "$HOME/.vimrc" ]; then
    mv "$HOME/.vimrc" "$HOME/.vimrc.bak"
    echo "Existing .vimrc backed up to ~/.vimrc.bak"
fi

# Create symlink for .vimrc
ln -sf "$REPO_DIR/.vimrc" "$HOME/.vimrc"

# Create symlink for .vim-config directory
# .vimrc sources from ~/.vim-config/, so point it to the repo's .vim-config/
if [ -L "$HOME/.vim-config" ]; then
    rm "$HOME/.vim-config"
elif [ -d "$HOME/.vim-config" ]; then
    mv "$HOME/.vim-config" "$HOME/.vim-config.bak"
    echo "Existing ~/.vim-config directory backed up to ~/.vim-config.bak"
fi
ln -sf "$REPO_DIR/.vim-config" "$HOME/.vim-config"

# Install vim-plug
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    echo "Installing vim-plug..."
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
    echo "vim-plug already installed."
fi

# Install ripgrep (detect package manager)
if command -v rg &>/dev/null; then
    echo "ripgrep already installed."
elif command -v dnf &>/dev/null; then
    sudo dnf install -y epel-release
    sudo dnf install -y ripgrep
elif command -v apt-get &>/dev/null; then
    sudo apt-get install -y ripgrep
elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm ripgrep
elif command -v brew &>/dev/null; then
    brew install ripgrep
else
    echo "Warning: Could not detect package manager. Install ripgrep manually."
fi

echo ""
echo "Vim configuration setup complete!"
echo "Run :PlugInstall inside Vim to install plugins."

