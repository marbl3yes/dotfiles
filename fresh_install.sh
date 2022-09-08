#!/bin/bash

export LC_ALL=C

# Nala package manager
apt install nala -y

# Stow for managing dot files
nala install stow -y

# Curl (needed for fnm)
nala install curl -y

# Fnm (node version manager)
curl -fsSL https://fnm.vercel.app/install | bash

# Zsh
nala install zsh -y
chsh -s /usr/bin/zsh
stow zsh

# Lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz -C /usr/local/bin lazygit
rm -rf lazygit.tar.gz
stow lazygit
