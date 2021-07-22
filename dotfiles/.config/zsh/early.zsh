# Things we run at the start of the loading process.

# Below zle commands are early because they set the cursor to I-beam once loading is complete and
# zle inits the line.

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
