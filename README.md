# Gib's Dotfiles

Contains everything I use to setup a new machine (except ssh and gpg keys).

## How to run

Run either the full or the manual setup, then go to the [Post Install Setup][].

### Requirements

- Git:

### Standard full setup

```bash
# Make a directory to put it in (any path is fine):
mkdir -p ~/code
git clone https://github.com/gibfahn/dot ~/code/dot && cd ~/code/dot
HARDCORE="" ./up
```

### Lite (non-root) setup

Useful for remote machines you don't own (you still want some niceties, but you
can't install a bunch of packages). Just copy and paste this one-line command:

```bash
git clone https://github.com/gibfahn/dot -o up && cd dot &&
  GIT_NAME=$(git config --global user.name) GIT_EMAIL=$(git config --global user.email) NO_SUDO=true HARDCORE="" ./up
```

### How to update to the latest master

```bash
./update
```

### Manual setup

Everything should be pretty self-explanatory and commented, it's all basic bash
scripting. From `./up` you can see what scripts get run. Each of them can be run
individually (and run more than once).

If you don't have root (and don't want `sudo` prompts), just do:

```bash
export NO_SUDO=true
```

The scripts change your default shell to zsh, if you don't want this change
`$NEWSHELL` to the path to the shell you'd like (or an empty string to not
change shell). Make sure the shell you choose is in `/etc/shells`.

```bash
export NEWSHELL=/usr/local/bin/fish # Or NEWSHELL="" to keep current shell.
```

If you want hardcore modifications enter anything at the prompt.

If you want to enable HARDCORE mode for a single script, just pass it as an env
var, e.g.

```bash
export HARDCORE=true
./setup/unix.sh
```

If you just want to update your dotfile symlinks, you can just run:

```sh
./link
```

Dotfiles are pretty personal, so feel free to adapt this repo as you wish. If
you make a change feel free to send a Pull Request, you might fix something for
me!

## Post install setup

Some things you have to do manually, here's a short list:

- Set up ssh keys (All)
  - If you don't have them you probably want them. Instructions
    [here](http://fahn.co/blog/setting-up-ssh-keys.html).
- Set up gpg keys (All)
  - Similar to ssh keys, instructions
    [here](http://fahn.co/blog/setting-up-gpg-keys.html).
- CopyQ setup (All)
  - Set History to `9999`
  - Add Global Shortcut: `Show/Hide Main Window` -> <kbd>⌘</kbd><kbd>Shift</kbd><kbd>v</kbd>
  - Add Global Shortcut: `Paste as Plain Text` -> <kbd>Shift</kbd><kbd>Enter</kbd>
- Run Spectacle on Login (macOS):
  - <kbd>⌘</kbd><kbd>Space</kbd>`Spectacle`<kbd>Enter</kbd>
  - Click on the spectacles in the Menu Bar, click Preferences
  - Check the box at the bottom: `Launch Spectacle at login`
- Run HyperSwitch on Login (macOS):
  - Change settings:
    - General:
      - Check `Run HyperSwitch in the background.`
      - Active the window switcher for `all windows` -> <kbd>⌘</kbd><kbd>Tab</kbd>
      - Check `Include windows from other screens`
    - `App Switcher`
      - `App Switcher` -> `Delay activation for` -> `0` ms for both.
    - `Appearance`
      - `Hide animation:` -> `None`
      - `Show HyperSwitch in` -> `the menu bar`
    - `About:`
      - `Download and install updates in the background`
- Make default screenshot combination copy to clipboard:
  - `System Preferences` -> `Keyboard` -> `Shortcuts` -> `Screen Shots`
  - Swap `Save picture of selected area as file` and `Copy picture of selected
    area to the clipboard`.

## Adding a new file to your dotfiles

As long as it goes in `$HOME`, just put it in the same relative directory inside
`./dotfiles/` (so `~/.bashrc` becomes `dot/dotfiles/.bashrc`). If you rerun
`link` it should get symlinked into the right place.

[Post Install Setup]: #post-install-setup
