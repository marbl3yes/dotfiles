#!/bin/bash

export LC_ALL=C

# Install nala package manager
apt install nala -y

# Install stow for managing dot files
nala install stow -y

# Install curl (needed for fnm)
nala install curl -y

# Install fnm (node version manager)
curl -fsSL https://fnm.vercel.app/install | bash

# Install and configure zsh
nala install zsh -y
chsh -s /usr/bin/zsh
stow zsh
