# shellcheck shell=zsh

# Startup files: https://zsh.sourceforge.io/Intro/intro_3.html
# .zshrc is sourced in interactive shells.

# {{{ Initial setup

# To test shell startup time, run:
#   hyperfine --warmup 3 "zsh -ic 'exit'"

# # Enable zsh startup profiling 1/2, see helpers/sort_timings.zsh
# zmodload zsh/datetime
# setopt PROMPT_SUBST
# PS4='+$EPOCHREALTIME %N:%i> '
# logfile=$(mktemp -t zsh_profile.XXXXXXXX)
# echo "Logging to $logfile"
# exec 3>&2 2>$logfile
# setopt XTRACE

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
printf '\e[4 q' # Cursor is an underline (_) while shell setup is running.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${USER}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${USER}.zsh"
fi

# }}} Initial setup

# {{{ Environment Variables

# For making things adhere to XDG see: https://wiki.archlinux.org/index.php/XDG_Base_Directory
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME/.cache"} # Cache stuff should go here.
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"} # Config stuff should go here.
export XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"} # Data should go here.
export HISTSIZE=200000 SAVEHIST=200000 HISTFILE="$XDG_CACHE_HOME/zsh/history" # Set history file location and size.
export CARGO_HOME="$XDG_DATA_HOME/cargo" # Cargo goes here.
export VOLTA_HOME="$XDG_CACHE_HOME/volta" # Set directory to use for volta install.
export GOPATH="$HOME/code/go"

# }}} Environment Variables

# {{{ System Path Setup

# Where brew is on the system if it's installed.
# Script expects brew to be already in the path, e.g. by adding to /etc/paths.d with:
#   echo "$(brew --prefix)/bin" | sudo tee /etc/paths.d/10-brew
brew_prefix=${commands[brew]:+${commands[brew]:h:h}}

typeset -U path # Don't allow duplicates in the path (keep left-most entry).

path=(
  ${VIRTUAL_ENV:+$VIRTUAL_ENV/bin} # Virtual env needs to be in front of /usr/local/bin.

  $HOME/bin # Put random binaries you want to run in here.
  $HOME/.local/bin

# /usr/local/opt/ccache/libexec # Add ccache to the path if installed (macOS).
# /usr/lib/ccache # Add ccache to the path if installed (Linux).

  # Overrides the version in ${brew_prefix}/bin.
  ${CARGO_HOME:+$CARGO_HOME/bin} # Rust packages.
  ${VOLTA_HOME:+$VOLTA_HOME/bin} # Node.js and packages.

  ${brew_prefix:+$brew_prefix/opt/ruby/bin} # Brew ruby.
  ${brew_prefix:+$brew_prefix/lib/ruby/gems/*/bin(N)} # Add ruby or skip.
  ${brew_prefix:+$brew_prefix/bin} # Alternate brew install location.

  /usr/local/sbin # Missed in some shells.
  /usr/local/bin # Missed in some shells.
  /usr/bin # Should be after /usr/local/bin.

  $HOME/Library/Python/*/bin(N) # macOS Python User Packages.
  ${GOPATH:+$GOPATH/bin} # Go binaries.
  $path
)
export PATH

# }}} System Path Setup

# {{{ Zsh Plugins and Sourcing

# Source plugins
source $XDG_DATA_HOME/zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme
source $XDG_CONFIG_HOME/zsh/early/p10k.zsh
source $XDG_CACHE_HOME/zsh/ls_colors.zsh
source $XDG_DATA_HOME/zsh/plugins/zsh-defer/zsh-defer.plugin.zsh

zsh-defer source $XDG_CONFIG_HOME/zsh/deferred/deferred.zsh

# }}} Zsh Plugins and Sourcing

# {{{ Zsh options

setopt always_to_end # Move to end of word after completing that word from the middle of it.
setopt auto_cd # Typing a path that isn't a command will cd to it.
setopt auto_pushd # cd pushes onto pushd stack (Try `cd -<Tab>`)
setopt complete_in_word # Allow completing words when you're in the middle of them.
setopt extended_history # Save timestamps in history.
setopt hist_expire_dups_first # Delete duplicates when history is full.
setopt hist_ignore_all_dups # Remove older dups in HISTFILE when adding newer ones.
setopt hist_ignore_space # Don't save history lines if they start with ' ' (use for secret values).
setopt inc_append_history # Show local history before remote.
setopt interactive_comments # Allow comments in the terminal.
setopt long_list_jobs # Show more info on background jobs.
setopt no_list_ambiguous # Show menu on first tab if multiple matches (don't wait for second tab).
setopt no_list_beep # Don't beep if tab-complete has multiple choices, only if no such file.
setopt no_notify # Print job updates just before a prompt (not mid-execution).
setopt prompt_percent # Allow variables and functions to be used in the prompt.
setopt prompt_subst # Perform expansion and subsitution on PROMPT and RPROMPT.
setopt pushd_ignore_dups # Don't push multiple copies onto the directory stack.
setopt pushd_minus # Make `cd -2` be two dirs ago rather than `cd +2`.
setopt pushd_silent # Don't print pushd stack after pushd or cd (unless in CDPATH).
setopt share_history # Do show history from other open tabs.

# }}} Zsh options


# {{{ Early Completion Keybindings

# Better ls commands.
# l->full detail + hidden, la->no detail + hidden, ll->full detail no hidden, md->create dir.
alias ls="${commands[gls]+g}ls --color=auto" l='ls -lAh' la='ls -A' ll='ls -l'

# We want this to expand when defined.
alias ..="cd .." ...="cd ../.." ....="cd ../../.." .....="cd ../../../.." ......="cd ../../../../.."
# shellcheck disable=SC2139 # We want this to expand when defined.
alias -- -="cd -"
alias cg='cd $(git rev-parse --show-toplevel)' # Change to top level of git dir.
alias g=git md="mkdir -p"
# x->close terminal, g->git, h->history, path->print $PATH,
alias path='echo $PATH | tr : "\n"' dt="date +%Y-%m-%d"
alias s="TERM=xterm-256color ssh" # Reset cursor to block and ssh.

# }}} Early Completion Keybindings

# {{{ Early Aliases

_gib_vim=
{ (( $+commands[nvim] )) && _gib_vim=nvim; } || { (( $+commands[vim] )) && _gib_vim=vim; } || _gib_vim=vi # Take what you can get.
[[ $VISUAL == 'nvr --remote-wait' ]] && _gib_vim=$VISUAL # Allow passing through the neovim init.vim value.
export VISUAL=$_gib_vim EDITOR=$_gib_vim # Set vim/nvim as the default editor.
unset _gib_vim

alias vt='v ~/tmp/drafts/t.md' # vim temp: Edit a common scratch file (allows vim history preservation).

alias v="$=VISUAL" xv="xargs $=VISUAL"
alias k=kubectl kx=kubectx kn='kubectl config set-context --current --namespace' # Build tools.

# }}} Early Aliases

# {{{ Early Keybindings

# ^D with contents clears the buffer, without contents exits (sends an actual ^D).
_gib_clear_exit() { [[ -n $BUFFER ]] && zle kill-buffer || zle self-insert-unmeta; }
zle -N _gib_clear_exit

# ⌥-n with contents inserts, without contents cd's to matching directory.
_gib_fzfz_cd() {
  local selected_dir
  local orig_buffer_len=${#${(z)BUFFER}}
  selected_dir=$(zoxide query --list | fzf --reverse --keep-right --filepath-word --tiebreak=end,index)
  local ret=$?
  LBUFFER="${LBUFFER}${selected_dir:q}"
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  if [[ $ret -eq 0 && -n "$BUFFER" && $orig_buffer_len == 0 ]]; then
    zle .accept-line
  fi
  return $ret
}
zle -N _gib_fzfz_cd

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
zle -N zle-keymap-select # Bind zle-keymap-select() above to be called when the keymap is changed.

zle-line-init() {
  zle -K viins  # Every line starts in insert mode.
  zle-keymap-select beam # Every line starts with I-beam cursor.
}
zle -N zle-line-init     # Bind zle-line-init() above to be called when the line editor is initialized.

# Immediately loaded keybindings (more expensive ones are in deferred.zsh).

# Modes:
# - main -> 'viins' for vim, 'emacs' for emacs mode.
# - viins -> insert mode
# - vicmd -> normal mode
# - visual -> visual mode

bindkey -v # Enable vi-mode.

bindkey -M vicmd ' ' edit-command-line # <Space> in cmd mode opens editor.
bindkey -M vicmd '^D' _gib_clear_exit
bindkey -M vicmd '\ez' _gib_fzfz_cd # Alt-z switches to a commonly-used directory.

bindkey -M viins "^A" beginning-of-line # Ctrl-A = Go to beginning of line (Emacs default).
bindkey -M viins "^E" end-of-line       # Ctrl-E = Go to end of line (Emacs default).
bindkey -M viins ' ' magic-space # <Space> = do history expansion
bindkey -M viins '\e ' edit-command-line # <Alt><Space> in insert mode opens editor.
bindkey -M viins '\e.' insert-last-word # Alt-. inserts last word from previous line.
bindkey -M viins '\ec' fzf-cd-widget # Alt-c opens fzf cd into subdir.
bindkey -M viins '\ez' _gib_fzfz_cd # Alt-z switches to a commonly-used directory.
bindkey -M viins '^?' backward-delete-char # Backspace: delete a char.
bindkey -M viins '^D' _gib_clear_exit # Ctrl-d: clear or exit terminal.
bindkey -M viins '^H' backward-delete-char # Ctrl-h: delete a char.
bindkey -M viins '^T' fzf-file-widget # Ctrl-t: preserve fzf file widget setting.
bindkey -M viins '^U' backward-kill-line # Ctrl-u: delete the current line (not whole buffer).
bindkey -M viins '^W' backward-kill-word # Ctrl-w: delete the current line (not whole buffer).


# }}} Early Keybindings

# # Enable zsh startup profiling 2/2, see helpers/sort_timings.zsh
# unsetopt XTRACE
# exec 2>&3 3>&-

# vim: foldmethod=marker filetype=zsh tw=100
