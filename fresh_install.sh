#!/bin/bash

export LC_ALL=C

# Nala package manager
apt install nala -y

# Stow for managing dot files
nala install stow -y

# Curl (needed for fnm)
nala install curl -y

# FNM (node version manager)
curl -fsSL https://fnm.vercel.app/install | bash

# SDKMAN (manager for java, maven, etc.)
curl -s "https://get.sdkman.io" | bash

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

# FZF
nala install fzf -y

# Neovim
nala install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen -y
git clone https://github.com/neovim/neovim.git
cd neovim
git checkout release-0.7
make CMAKE_BUILD_TYPE=Release
make install
