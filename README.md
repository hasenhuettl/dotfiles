# Introduction
My personal dotfiles repo, including ZSH, TMUX, NEOVIM, and custom SSH wrapper config.

# Installation

Open your favorite terminal application, and execute:

```
mkdir -p ~/git
git clone https://github.com/hasenhuettl/dotfiles.git ~/git/dotfiles
bash ~/git/dotfiles/bootstrap.sh
```

# Usage Manual

This manual provides a quick overview and useful commands/configurations for the main tools and environments in your development setup.

## Table of Contents
- [Tmux](#tmux)
- [Zsh](#zsh)
- [Neovim](#neovim)
- [SSH Wrapper](#ssh-wrapper)

## Tmux

Tmux (Terminal Multiplexer) allows multiple terminal sessions to be accessed and controlled from a single window.

### Configuration
- Config can be edited & applied with alias `trc`
  - `trc` is my abbreviation for "tmux rc". See [the zsh section](#zsh) on how to override aliases.

### Hotkeys
- `Ctrl + Shift + Left/Right Arrow`
  Navigate panes on the host machine.
- `Shift + Left/Right Arrow`
  Navigate panes on the remote machine.
- `Ctrl + b`
  Enter Tmux command mode on the host.
- `Ctrl + a`
  Enter Tmux command mode on the remote machine.
- In command mode, press `c` to create a new pane.

---

## Zsh

Zsh (Z Shell) is an extended shell with more powerful features than bash.

### Configuration
- Config can be edited & applied with alias `zrc`
  - I split some of the configs into multiple files. A neovim window should be opened, showing the different files in the folder. Refer to [the neovim section](#neovim) for further infos.
  - Place your custom config (aliases, options, etc.) within custom.zsh, it will be loaded last and overwrite previous settings.


### Hotkeys
- `Ctrl + Right/Left Arrow`
  Move cursor forward/backward by a whole word.
- `Alt + Left Arrow` or `Alt + Backspace`
  Delete the word before the cursor.
- `Alt + Right Arrow` or `Alt + Delete`
  Delete the word after the cursor.
- Text + `Cursor Up/Down`
  Navigate command history filtered by what you've typed so far.

---

## Neovim

An improved version of Vim with better extensibility and configuration.

My setup was inspired by https://pretalx.linuxtage.at/media/glt25/submissions/JUURFP/resources/setup_neovim_EO5gTE3.pdf

### Configuration
- Config can be edited & applied with alias `nrc`

### Features
- Supports most Vim commands.
- Shows style and inserts indentation based on filetype.
- Shows changes made in git-committed files in a sidebar.

### Usage
- Neovim handling for the user is nearly the same as basic vi/vim. It is highly recommended to at least look up basic vim commands beforehand.
- **Do not give up after initially seeing all the available keybinds.** Start with the basics, and soon you'll learn to love neovim. Trust me.

### Tools
You can close/quit the UIs usually via `:q` or `, + q`
- `, + l` opens Lazy. This is the tool which will install and update our plugins for neovim.
- `, + m` opens Mason. This is the tool which will install and update our LSP servers for neovim.

### Hotkeys
- `Shift + i` to enter a paste-friendly insert mode that disables UI elements that could interfere with pasting text. Press `Escape` to exit this mode.
- `Spacebar` (LEADER key for the snacks plugin) or `,` (LEADER key for Neovim) to display your shortcuts, e.g., save/quit with `, + w/q` instead of `:w/q`.
- `gcc` to comment/uncomment the current line based on filetype.
- There are 2 different file explorers available, depending on preference or use case:
  - `-` for "Oil" file explorer (opens in current directory)
    - Navigation: `gg`, `G`, `Shift + H/M/L`, `/ + search_string`
    - `-` to switch to parent directory
    - `Enter` to select
    - `:q` or `, + q` to quit
  - `Space + e` for "Snacks" file explorer (opens at project root)
    - Navigation: `gg`, `G`, `/ + search_string`
    - `Shift + H` to show hidden files
    - `Enter` to select
    - `Space + e` again, `:q` or `, + q` to quit
- After changing files, use `Ctrl + n` / `Ctrl + p` to switch to next/previous file.
- Run `:Inspect` on an element to find out e.g. why the element is a different color
- `:help Command` to see what a command does (e.g.: `:help gcc`)
- Hover over e.g. a function, then press `K` to hover docs, `gr` for references

### Troubleshooting
- `:lua Snacks.notifier.show_history()` to display vim notify error history

---

## SSH Wrapper

The ssh command is aliased to run $HOME/scripts/myssh.py. You can use either `ussh` or `\ssh` to run standard ssh.

### Usage
- Ensure remote system has required packages installed (e.g. rsync, curl, tmux, zsh -> refer to Install/Bash/install_nvim.sh)
- View available parameters via `ssh --help`
- Use standard `ssh [username@]host[:port]` to connect

### Features
- Synchronize configuration files for neovim, tmux, zsh, etc. to remote system (Folder: "$HOME/.config.custom"), if either:
  - Username on host and remote is the same
  - `--transfer` parameter is provided to force file transfer. **(THIS WILL ALWAYS OVERWRITE REMOTE FOLDER "$HOME/.config.custom" AND "$HOME/.terminfo"!)**
- Automatically creates a new terminal multiplexer session, either tmux or screen (if supported by remote system)
- SSH session multiplexing via ControlMaster (if supported by remote system)
  - Reuse same connection (only input remote password once)
  - SSH session restore with tmux (re-open used remote tabs when host crashes)

---

