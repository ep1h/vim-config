#!/bin/bash
git clone https://github.com/ep1h/vim-config.git ~/.vim-config
mv ~/.vim-config/.vimrc ~/
"curl -fLm ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
curl -f -L -m 10 --create-dirs -o ~/.vim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim 
sudo dnf install epel-release
sudo dnf install ripgrep
":PlugInstall


# Backup existing .vimrc if it exists
if [ -f ~/.vimrc ]; then
    mv ~/.vimrc ~/.vimrc.bak
    echo "Existing .vimrc moved to .vimrc.bak"
fi

# Create a symlink for the .vimrc
ln -s ~/vim-config/.vimrc ~/.vimrc

echo "Vim configuration setup complete!"

