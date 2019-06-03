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

Some things you have to do manually:

- System Preferences:
  - `General` -> `Automatically hide and show the menu bar`
  - `Dock`
    - `Automatically hide and show the dock`
    - `Show recent applications in Dock`
  - `Mission Control` -> `Displays have separate spaces` -> Uncheck
  - `Touch ID` -> Add other fingerprints
  - `Software Update` -> `Automatically keep my mac up to date`
- Set up ssh keys (All)
  - If you don't have them you probably want them. Instructions
    [here](http://fahn.co/blog/setting-up-ssh-keys.html).
- Set up gpg keys (All)
  - Similar to ssh keys, instructions
    [here](http://fahn.co/blog/setting-up-gpg-keys.html).
- CopyQ setup (All)
  - `General`
    - `Vi style navigation`
    - `Autostart`
  - `History` -> `Maximum number of items in history` -> `9999`
  - `Notifications`:
    - `Notification position` -> `Top Right`
    - `Interval in seconds to display notifications` -> `2`
    - `Number of lines for clipboard notification` -> `5`
    - `Maximum height` -> `300`
  - `Shortcuts`:
    - `Show/Hide Main Window` -> <kbd>⌘</kbd><kbd>Shift</kbd><kbd>v</kbd>
    - `Paste as Plain Text` -> <kbd>Shift</kbd><kbd>Enter</kbd>
  - `Appearance` -> `Theme` -> `Dark`
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
- Safari Extensions:
  - Set up [sVim][] for Safari:
    - [Install sVim][]
    - Click the `sVim` icon by the address bar, then `Show sVimrc`
    - Paste gist ids, `Sync`, `Save`
      - `sVimrc`: [22c17d0059340e2c90c3c316b746ba8b][]
      - `sVimcss`: [3cf4e6a17c85ff67d29fea37ed31963d][]
- Safari settings:
  - `General`
    - `Safari opens with` -> `All windows from last session`
    - `New windows open with` -> `Empty page`
    - `New tabs open with` -> `Empty page`
    - `Remove history items` -> `Manually`
  - `Tabs` -> `Show website icons in tabs`
  - `Advanced`
    - `Show full website address` -> Tick
    - `Press Tab to highlight each item on a webpage`
    - `Show Develop menu in menu bar`
- Give Kitty full disk access: `System Preferences` -> `Privacy` -> `Full Disk Access`.

## Adding a new file to your dotfiles

As long as it goes in `$HOME`, just put it in the same relative directory inside
`./dotfiles/` (so `~/.bashrc` becomes `dot/dotfiles/.bashrc`). If you rerun
`link` it should get symlinked into the right place.

[22c17d0059340e2c90c3c316b746ba8b]: https://gist.github.com/gibfahn/22c17d0059340e2c90c3c316b746ba8b
[3cf4e6a17c85ff67d29fea37ed31963d]: https://gist.github.com/gibfahn/3cf4e6a17c85ff67d29fea37ed31963d/edit
[Install sVim]: https://safari-extensions.apple.com/?q=svim
[Post Install Setup]: #post-install-setup
[sVim]: https://github.com/flipxfx/sVim
