#!/bin/bash

set -e

# Define files to backup
files=(.bashrc .ssh .config.custom scripts)

cd ~

mkdir -p git
mkdir -p .ssh/cm_socket
mkdir -p .local/data

cd git

cd ~

# Check for existing backups first
for file in "${files[@]}"; do
  backup="$file.pre-dotfiles"
  if [ -e "$backup" ]; then
    echo "Error: $backup already exists. Aborting to prevent overwrite." >&2
    exit 1
  fi
done

# If file exists, do a backup
for file in "${files[@]}"; do
  if [[ -e "$file" ]]; then
    echo "Moving old $file to $file.pre-dotfiles..."
    mv "$file" "$file.pre-dotfiles"
  fi
done

# Create symlinks
ln -s "git/dotfiles/local/scripts" "scripts"
ln -s "git/dotfiles/local/.config.custom" ".config.custom"
ln -s ".config.custom/bash/.bashrc" ".bashrc"

# SSH browser link protocol handling
sudo ln -sf "scripts/ssh-url.sh" "/usr/local/bin/ssh-url"

# Copy ssh config
cp -r "git/dotfiles/local/.ssh" ".ssh"

# Copy .custom.zsh from template (if not exists)
[ ! -e .config.custom/zsh/custom.zsh ] && cp .config.custom/zsh/.custom.zsh.template .config.custom/zsh/custom.zsh

bash "$HOME/.config.custom/scripts/install_nvim.sh"

# Ask for terminal restart
BLUE="$(tput setaf 4)"
NC="$(tput sgr0)"

printf "%sPlease restart your terminal to apply changes.%s\n" "$BLUE" "$NC"

