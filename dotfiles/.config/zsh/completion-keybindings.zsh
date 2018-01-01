zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} r:|[.,_-]=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # Use LS_COLORS in file completion menu.
zstyle ':completion:*:*:*:*:*' menu "select" # Make the completion selection menu a proper menu.

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path "$ZSH_CACHE_DIR"

autoload -U compinit
compinit
zstyle ':bracketed-paste-magic' active-widgets '.self-*' # https://github.com/zsh-users/zsh-autosuggestions/issues/141

# Vim mode and keybindings in zsh:
autoload -U history-search-end # Not included by default so load (usually /usr/share/zsh/unctions/Zle/).
zle -N history-beginning-search-backward-end history-search-end # Add it to existing widgets.
zle -N history-beginning-search-forward-end history-search-end  # Add it to existing widgets.
accept-line() { [ -z "$BUFFER" ] && zle up-history; zle ".$WIDGET"; }
zle-keymap-select () { [ $KEYMAP = vicmd ] && printf "\033[2 q" || printf "\033[6 q"; } # Other KEYMAPs are main and viins.
zle-line-init () { zle -K viins; printf "\033[6 q"; }
zle -N accept-line # Redefine accept-line to insert last input if empty (Enter key).
zle -N zle-keymap-select # I-beam cursor in insert mode, block otherwise.
zle -N zle-line-init     # Part of above cursor hack ^.
KEYTIMEOUT=10 # Key delay of 0.1s (Esc in vim mode is quicker).

bindkey -v # Enable vim mode in zsh.

bindkey -M viins 'kj' vi-cmd-mode # Map kj -> Esc in vim mode.
bindkey -M viins "^?" backward-delete-char # Make backspace work properly.
bindkey -M viins "^H" backward-delete-char # <Ctrl>-H = Backspace (Emacs default).
bindkey -M viins "^W" backward-kill-word # <Ctrl>-W = Delete word (Emacs default).
bindkey -M viins "^U" backward-kill-line # <Ctrl>-U = Delete line (Emacs default).
bindkey -M viins "^A" beginning-of-line # <Ctrl>-A = Go to beginning of line (Emacs default).
bindkey -M viins "^E" end-of-line       # <Ctrl>-E = Go to end of line (Emacs default).
bindkey -M viins "^R" history-incremental-search-backward # Restore <Ctrl>-R search.
bindkey -M viins "^S" history-incremental-search-forward  # Restore <Ctrl>-S forward search.
bindkey -M main "^[[A" history-beginning-search-backward-end # Re-enable up   for history search.
bindkey -M main "^[[B" history-beginning-search-forward-end  # Re-enable down for history search.
bindkey ' ' magic-space # <Space> = do history expansion
bindkey "${terminfo[kcbt]}" reverse-menu-complete   # <Shift>-<Tab> - move backwards through the completion menu.
