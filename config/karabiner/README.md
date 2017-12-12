# macOS Karabiner Configuration

Uses [Karabiner-Elements](https://github.com/tekezo/Karabiner-Elements/) to
customize keyboards on macOS.

By default there are two profiles, `Gib` and `Clean`. `Gib` is what I use
day-to-day, `Clean` is what I switch to when other people want to use my
computer.

To see an overview of the rules, run `grep description karabiner.json` in this
directory.

### Editing `karabiner.json`

Editing the file manually is pretty straightforward, the `Karabiner-Elements`
`Log` tab will tell you if `Karabiner` fails to parse the `json`, and
`Karabiner` updates as soon as you save the file.

Once you make a change in the Karabiner UI, Karabiner will rewrite the json in
super-expanded form. If you want to edit it manually trawling through
thousands of lines of json is a bit of a pain, so you can run a quick script to
condense it (only changes whitespace). I suggest running the script before
committing changes.


```bash
# Use vim instead of nvim if you don't have nvim.
nvim karabiner.json -S format-lines.vim
```

### Hyper

If you're lucky, you have an ISO (European) style keyboard, with a <kbd>\`</kbd>
character to the right of the left <kbd>Shift</kbd>. This is perfect for use as
a <kbd>Hyper</kbd> key (I use `Ж` to represent Hyper). If you don't you'll have
to find another key to act as the Hyper key. People often use <kbd>Space</kbd>
or the right <kbd>⌘</kbd>. I don't because I use <kbd>Space</kbd> for vim shortcuts (and
the <kbd>Hyper</kbd> mouse <kbd>Ж🐭</kbd> layer), and because I'm lucky enough
to have an ISO keyboard layout.

### Keyboard specific options

You can disable karabiner for specific keyboards, or enable specific rules. Just
add a rule in the UI to get started, then copy from other bits of the json file.
