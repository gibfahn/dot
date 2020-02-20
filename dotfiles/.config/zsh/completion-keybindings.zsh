# Fzf git files (unstaged).
# shellcheck shell=bash disable=SC2016
_gib_git_f() {
  git -c color.status=always status --short |
  fzf "$@" --border -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' | cut -c4- | sed 's/.* -> //'
}
# Fzf git branches.
_gib_git_b() {
  git branch -a --color=always --sort=committerdate --sort=-refname:rstrip=2 | grep -v '/HEAD\s' |
  fzf "$@" --border --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --color=always --graph --decorate --date=short $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES \
  | sed 's/^..//' | cut -d' ' -f1 | sed 's#^remotes/##'
}
# Fzf git tags.
_gib_git_t() {
  git tag --color=always --sort -version:refname |
  fzf "$@" --border --multi --preview-window right:70% \
    --preview 'git show --color=always {} | head -'$LINES
}
# Fzf git hashes.
_gib_git_h() {
  git log --all --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf "$@" --border --ansi --no-sort --reverse --multi --header 'Press CTRL-S to toggle sort' \
    --bind 'ctrl-s:toggle-sort' \
    --preview 'git show --color=always $(grep -oE "[a-f0-9]{7,}" <<< {})' \
  | grep -oE "[a-f0-9]{7,}"
}

# Fzf git reflog history.
_gib_git_r() {
  git reflog --date=short --pretty=oneline --color=always --decorate |
  fzf "$@" --border --ansi --no-sort --reverse --multi --header 'Press CTRL-S to toggle sort' \
    --bind 'ctrl-s:toggle-sort' \
    --preview 'grep -o "[a-f0-9]{7,}" <<< {} | xargs git show --color=always' \
  | grep -oE '[a-f0-9]{7,}'
}
# More fzf helpers.
# shellcheck disable=2034,SC2154
_gib_join-lines() { local item; while read -r item; do echo -n "${(q)item} "; done; }
bind-git-helper() {
  local c
  for c in "$@"; do
    eval "_gib_fzf-g$c-widget() { git rev-parse HEAD > /dev/null 2>&1 || return; local result=\$(_gib_git_$c | _gib_join-lines); zle reset-prompt; LBUFFER+=\$result }"
    eval "zle -N _gib_fzf-g$c-widget"
    eval "bindkey -M viins '^g^$c' _gib_fzf-g$c-widget"
  done
}

zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} r:|[.,_-]=*'
# shellcheck disable=SC2154
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # Use LS_COLORS in file completion menu.
zstyle ':completion:*:*:*:*:*' menu "select" # Make the completion selection menu a proper menu.

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path "$XDG_CACHE_HOME"/zsh

# TODO(gib): Work out why this is slow on Darwin and fix it.
zstyle ':bracketed-paste-magic' active-widgets '.self-*' # https://github.com/zsh-users/zsh-autosuggestions/issues/141

# Vim mode and keybindings in zsh:
autoload -U history-search-end # Not included by default so load (usually /usr/share/zsh/unctions/Zle/).
autoload -Uz edit-command-line # Load command to open current line in $VISUAL.
zle -N edit-command-line
zle -N history-beginning-search-backward-end history-search-end # Add it to existing widgets.
zle -N history-beginning-search-forward-end history-search-end  # Add it to existing widgets.
accept-line() { [ -z "$BUFFER" ] && zle up-history; zle ".$WIDGET"; }

# Changes the cursor shape. KEYMAP is set when called by zsh keymap change.
# If normal mode then 'vicmd', if insert mode then 'main' or 'viins'.
zle-keymap-select() {
  if [[ $KEYMAP == vicmd || $1 = block ]]; then
    printf "\e[2 q"  # Block cursor '█'
  elif [[ $1 = underline ]]; then
    printf "\e[4 q"  # Underline cursor '_'.
  elif [[ $KEYMAP == main || $KEYMAP == viins || -z $KEYMAP || $1 = beam ]]; then
    printf "\e[6 q"  # I-beam cursor 'I' or '|'.
  else  # Default cursor is I-beam.
    printf "\e[6 q"  # I-beam cursor 'I' or '|'.
  fi
}

zle-line-init() {
  zle -K viins  # Every line starts in insert mode.
  zle-keymap-select beam # Every line starts with I-beam cursor.
}

zle -N accept-line # Redefine accept-line to insert last input if empty (Enter key).
zle -N zle-keymap-select # Bind zle-keymap-select() above to be called when the keymap is changed.
zle -N zle-line-init     # Bind zle-line-init() above to be called when the line editor is initialized.
# shellcheck disable=SC2034
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
bindkey -M main '\e.' insert-last-word
bindkey ' ' magic-space # <Space> = do history expansion
# shellcheck disable=SC2154
bindkey "${terminfo[kcbt]}" reverse-menu-complete   # <Shift>-<Tab> - move backwards through the completion menu.
bindkey -M vicmd ' ' edit-command-line # <Space> in cmd mode opens editor.

# Bind git shortcuts to <c-g><c-$@> (see above functions for more info).
bindkey -r -M viins "^G" # Remove list-expand binding so we can use <C-g> for git.
bind-git-helper f b t r h # Bind <C-g><C-{f,b,t,r,h}> to fuzzy-find show {files,branches,tags,reflog,hashes}.
unset -f bind-git-helper

# Run before the prompt is displayed.
_gib_prompt_precmd() {
  # Set window title to current directory.
  print -Pn "\e]2;%1~\a"
}

# Run between user hitting Enter key, and command being run.
_gib_prompt_preexec() {
  printf '\e[4 q' # Cursor is an underline (_) while command is running.
  # Set window title to first word of exec command.
  [[ "$PWD" == "$HOME" ]] && printf "\e]2;%s\a" "${1%% *}"
}

autoload -Uz add-zsh-hook

add-zsh-hook precmd _gib_prompt_precmd
add-zsh-hook preexec _gib_prompt_preexec
