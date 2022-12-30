#!/bin/bash

# Check for the use of sudo first 
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run as sudo." 2>&1
  exit 1
fi

username=$(id -u -n 1000)
builddir=$(pwd)

# Update system first
apt update
apt upgrade -y

# Install nala package manager for better usage
apt install -y nala

# Making .config and and .font directories
mkdir -p "/home/$username/.config"
mkdir -p "/home/$username/.fonts"
chown -R "$username:$username" "/home/$username"

# Install necessary dependencies
nala install -y wget curl unzip zip stow gpg
# Install additional programs
nala install -y neofetch vim tree network-manager-l2tp

# Install fonts
cd "$builddir" || exit
nala install -y fonts-font-awesome
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/FiraCode.zip
unzip FiraCode.zip -d "/home/$username/.fonts"
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/Meslo.zip
unzip Meslo.zip -d "/home/$username/.fonts"
cp /usr/share/fonts-font-awesome/fonts/*.otf "/home/$username/.fonts/"
chown "$username:$username" "/home/$username/.fonts/*"

# Reloading Font
fc-cache -vf
# Removing zip files
rm ./FiraCode.zip ./Meslo.zip

# Install chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i google-chrome-stable_current_amd64.deb
nala install -f
rm google-chrome-stable_current_amd64.deb

# FNM (node version manager)
curl -fsSL https://fnm.vercel.app/install | bash

# SDKMAN (manager for java, maven, etc.)
curl -s "https://get.sdkman.io" | bash

# Zsh
nala install -y zsh
chsh -s /usr/bin/zsh
# Oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions.git "/home/$username/.oh-my-zsh/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-completions.git "/home/$username/.oh-my-zsh/plugins/zsh-completions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "/home/$username/.oh-my-zsh/plugins/zsh-syntax-highlighting"
# Install Starship prompt
curl -sS https://starship.rs/install.sh | sh

# Install fzf
nala install -y fzf

# Install Lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz -C /usr/local/bin lazygit
rm -rf lazygit.tar.gz

# Install VS Code
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
nala install -y apt-transport-https
nala update
nala install -y code

# Stow configurations
stow zsh
stow vim
stow vscode
stow lazygit
