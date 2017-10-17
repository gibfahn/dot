# Gib's Dotfiles

Contains everything I use to setup a new machine (except ssh and gpg keys).

## How to run

### Standard full setup

```bash
# Make a directory to put it in (any path is fine):
mkdir -p ~/code
git clone https://github.com/gibfahn/dot ~/code/dot && cd ~/code/dot
HARDCORE="" ./up
```

### Super-quick one line lite (non-root) setup

Useful for remote machines you don't own (you still want some niceties, but you
can't install a bunch of packages). Just copy and paste this one-line command:

```bash
git clone https://github.com/gibfahn/dot -o up && cd dot &&
  GIT_NAME=$(git config --global user.name) GIT_EMAIL=$(git config --global user.email) NO_SUDO=true HARDCORE="" ./up
```

### No git setup

```bash
# Make a directory to put it in (any path is fine):
mkdir -p ~/code
# If you don't have git, use curl/unzip instead (you should probably just install git).
curl -kL https://github.com/gibfahn/dot/archive/master.zip > master.zip
unzip master.zip
mv dot-master ~/code/dot
cd ~/code/dot
HARDCORE="" ./up # Don't run in Hardcore mode.
```

But you should probably just install git.

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
./rcme
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
  - Check `Paste to Current Window`, `Focus to Last Window`, Set History to
    `9999`
  - Add Global Shortcut: `Show/Hide Main Window` -> <kbd>⌘</kbd><kbd>Shift</kbd><kbd>v</kbd>
- Run Spectacle on Login (macOS):
  - <kbd>⌘</kbd><kbd>Space</kbd>`Spectacle`<kbd>Enter</kbd>
  - Click on the spectacles in the Menu Bar, click Preferences
  - Check the box at the bottom: `Launch Spectacle at login`
- Make default screenshot combination copy to clipboard:
  - `System Preferences` -> `Keyboard` -> `Shortcuts` -> `Screen Shots`
  - Swap `Save picture of selected area as file` and `Copy picture of selected
    area to the clipboard`.

#### Add git to zip

If you downloaded this repo as a zip, now you have git you can set up the repo
properly:

```bash
cd ~/code/dot
git init
git remote add up git@github.com/gibfahn/dot
# Doesn't override any changes you've made
git reset up/master
```


## Adding a new file to my dotfiles

As long as it goes in `$HOME`, just put it in the same relative directory inside
`./dotfiles/` (so `~/.bashrc` becomes `dot/dotfiles/.bashrc`). If you rerun
`rcme` it should get symlinked into the right place.
