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

# Generate current timestamp
timestamp=$(date +"%Y%m%d-%H%M%S")

# If file exists, do a backup with timestamp
for file in "${files[@]}"; do
  if [[ -e "$file" ]]; then
    backup="${file}.pre-dotfiles.${timestamp}"
    echo "Moving old $file to $backup..."
    mv "$file" "$backup"
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

# Copy custom files from template (if not exists)
[ ! -e .config.custom/zsh/custom.zsh ] && cp .config.custom/zsh/.custom.zsh.template .config.custom/zsh/custom.zsh
[ ! -e .config.custom/bash/custom.bash ] && cp .config.custom/bash/.custom.bash.template .config.custom/bash/custom.bash

bash "$HOME/.config.custom/scripts/install_nvim.sh"

# Ask for terminal restart
BLUE="$(tput setaf 4)"
NC="$(tput sgr0)"

printf "%sPlease restart your terminal to apply changes.%s\n" "$BLUE" "$NC"

