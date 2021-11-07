#!/bin/bash
git clone https://github.com/ep1h/vim-config.git ~/vim-config

# Backup existing .vimrc if it exists
if [ -f ~/.vimrc ]; then
    mv ~/.vimrc ~/.vimrc.bak
    echo "Existing .vimrc moved to .vimrc.bak"
fi

# Create a symlink for the .vimrc
ln -s ~/vim-config/.vimrc ~/.vimrc

echo "Vim configuration setup complete!"

