# Key bindings for history substring search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[0A' history-substring-search-up
bindkey '^[0B' history-substring-search-down
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

# Terminal word navigation
bindkey "^[[1;5C" forward-word # CTRL + Cursor-Right
bindkey "^[[1;5D" backward-word # CTRL + Cursor-Left
bindkey "^[[1;3D" backward-kill-word # ALT + Cursor-Left
bindkey "^[^?"    backward-kill-word # ALT + BACKSPACE
bindkey "^[[3~" delete-char # ENTF
bindkey "^[[1;3C" kill-word # ALT + Cursor-Right
bindkey "^[[3;3~" kill-word # ALT + ENTF

# Bind Shift-Left/Right to no terminal input
bindkey -s '^[[1;2C' ''
bindkey -s '^[[1;2D' ''

# Issue: ALT + umlaut inserts <ffffffff>, with this rebind it annoys us with a beep instead
bindkey -s "^[ä" ''
bindkey -s "^[ö" ''
bindkey -s "^[ü" ''

# Enable reverse search
bindkey "^R" history-incremental-pattern-search-backward

# Use Escape + . OR Alt + . to insert the last argument in previous commands
bindkey '\e.' insert-last-word

# Let SPACE expand history expressions like !!, !$, etc.
bindkey ' ' magic-space

# ============================================================
# key bindings from grml's zshrc:
# Source: https://github.com/grml/grml-etc-core/blob/master/etc/zsh/zshrc
# ============================================================

# Use emacs-like key bindings by default.
# Remove this line if you prefer vi mode (bindkey -v).
bindkey -e

# ------------------------------------------------------------
# Terminal application mode
#
# Puts the terminal into "application mode" while ZLE is active
# so that $terminfo values (e.g. khome, kend) are valid.
# Without this, Home/End/etc. may not work in some terminals.
# ------------------------------------------------------------
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init   () { printf '%s' ${terminfo[smkx]} }
    function zle-line-finish () { printf '%s' ${terminfo[rmkx]} }
    zle -N zle-line-init
    zle -N zle-line-finish
fi

# ------------------------------------------------------------
# Key map: abstract names → terminal escape sequences
# ------------------------------------------------------------
typeset -A key
key=(
    Home     "${terminfo[khome]}"
    End      "${terminfo[kend]}"
    Insert   "${terminfo[kich1]}"
    Delete   "${terminfo[kdch1]}"
    Up       "${terminfo[kcuu1]}"
    Down     "${terminfo[kcud1]}"
    Left     "${terminfo[kcub1]}"
    Right    "${terminfo[kcuf1]}"
    PageUp   "${terminfo[kpp]}"
    PageDown "${terminfo[knp]}"
    BackTab  "${terminfo[kcbt]}"
)

# ------------------------------------------------------------
# Helper: bind a key to a widget in one or more keymaps.
# Usage: bind2maps <keymap>... -- ["-s" <seq>|<keyname>] <widget>
# ------------------------------------------------------------
function bind2maps () {
    local i sequence widget
    local -a maps

    while [[ "$1" != "--" ]]; do
        maps+=( "$1" )
        shift
    done
    shift

    if [[ "$1" == "-s" ]]; then
        shift
        sequence="$1"
    else
        sequence="${key[$1]}"
    fi
    widget="$2"

    [[ -z "$sequence" ]] && return 1

    for i in "${maps[@]}"; do
        # Only bind if the widget actually exists
        if (( ${+widgets[$widget]} )); then
            bindkey -M "$i" "$sequence" "$widget"
        fi
    done
}

# ------------------------------------------------------------
# Custom widget: smart beginning/end of line
#
# Normally moves to beginning/end of the current line.
# At a newline boundary in a multi-line buffer it falls back to
# beginning-of-buffer-or-history / end-of-buffer-or-history.
# ------------------------------------------------------------
function beginning-or-end-of-somewhere () {
    local hno=$HISTNO
    if [[ ( "${LBUFFER[-1]}" == $'\n' && "${WIDGET}" == beginning-of* ) || \
          ( "${RBUFFER[1]}"  == $'\n' && "${WIDGET}" == end-of*        ) ]]; then
        zle .${WIDGET:s/somewhere/buffer-or-history/} "$@"
    else
        zle .${WIDGET:s/somewhere/line-hist/} "$@"
        if (( HISTNO != hno )); then
            zle .${WIDGET:s/somewhere/buffer-or-history/} "$@"
        fi
    fi
}
zle -N beginning-of-somewhere beginning-or-end-of-somewhere
zle -N end-of-somewhere       beginning-or-end-of-somewhere

# ------------------------------------------------------------
# Standard key bindings
# ------------------------------------------------------------

# Home / End
bind2maps emacs             -- Home   beginning-of-somewhere
bind2maps       viins vicmd -- Home   vi-beginning-of-line
bind2maps emacs             -- End    end-of-somewhere
bind2maps       viins vicmd -- End    vi-end-of-line

# Insert / Delete
bind2maps emacs viins       -- Insert overwrite-mode
bind2maps             vicmd -- Insert vi-insert
bind2maps emacs             -- Delete delete-char
bind2maps       viins vicmd -- Delete vi-delete-char

# Arrow keys: cursor movement
bind2maps emacs             -- Left   backward-char
bind2maps       viins vicmd -- Left   vi-backward-char
bind2maps emacs             -- Right  forward-char
bind2maps       viins vicmd -- Right  vi-forward-char

# Page Up / Page Down: history search by prefix
bind2maps emacs viins       -- PageUp   history-beginning-search-backward
bind2maps emacs viins       -- PageDown history-beginning-search-forward

# Shift-Tab: reverse menu completion
# menuselect keymap requires zsh/complist; only bind if both are available
if zmodload zsh/complist 2>/dev/null && [[ -n ${key[BackTab]} ]]; then
    bind2maps menuselect -- BackTab reverse-menu-complete
fi

# ------------------------------------------------------------
# Ctrl-arrow: jump by word
# Different terminals send different sequences — cover the
# most common ones (URxvt and xterm/VTE families).
# ------------------------------------------------------------

# Ctrl-Right / Ctrl-Left (URxvt)
bind2maps emacs viins vicmd -- -s '\eOc' forward-word
bind2maps emacs viins vicmd -- -s '\eOd' backward-word

# Ctrl-Right / Ctrl-Left (xterm / VTE)
bind2maps emacs viins vicmd -- -s '\e[1;5C' forward-word
bind2maps emacs viins vicmd -- -s '\e[1;5D' backward-word

# Alt-Right / Alt-Left (URxvt)
bind2maps emacs viins vicmd -- -s '\e\e[C' forward-word
bind2maps emacs viins vicmd -- -s '\e\e[D' backward-word

# Alt-Right / Alt-Left (xterm / VTE)
bind2maps emacs viins vicmd -- -s '^[[1;3C' forward-word
bind2maps emacs viins vicmd -- -s '^[[1;3D' backward-word

# ESC + Left/Right (fallback using terminfo values)
bind2maps emacs viins vicmd -- -s '\e'${key[Right]} forward-word
bind2maps emacs viins vicmd -- -s '\e'${key[Left]}  backward-word

# ------------------------------------------------------------
# Incremental history search (^R / ^S)
# Uses pattern search widgets when available, falls back to
# the built-in incremental search otherwise.
# ------------------------------------------------------------
if zle -l history-incremental-pattern-search-backward 2>/dev/null; then
    bind2maps emacs viins vicmd -- -s '^r' history-incremental-pattern-search-backward
    bind2maps emacs viins vicmd -- -s '^s' history-incremental-pattern-search-forward
else
    bindkey '^r' history-incremental-search-backward
    bindkey '^s' history-incremental-search-forward
fi

# ------------------------------------------------------------
# Miscellaneous useful bindings
# ------------------------------------------------------------

# Ctrl-A / Ctrl-E: beginning / end of line (standard emacs keys, kept explicit)
# These are already part of emacs mode but listed here for clarity.
# bindkey '^a' beginning-of-line
# bindkey '^e' end-of-line

# Undo
bindkey '^_' undo          # Ctrl-_
bindkey '^xu' undo         # Ctrl-x u

# Ctrl-U: kill to beginning of line (zsh default is kill-whole-line; override)
bindkey '^u' backward-kill-line

# Ctrl-K: kill to end of line
bindkey '^k' kill-line

# Ctrl-W: kill previous word
bindkey '^w' backward-kill-word

# Ctrl-Y: yank (paste killed text)
bindkey '^y' yank

# Alt-.: insert last argument of previous command (like !$)
bindkey '\e.' insert-last-word

