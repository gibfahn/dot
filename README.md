# Gib's Dotfiles

Contains everything I use to setup a new machine (except ssh and gpg keys).

## How to run

```shell
curl --create-dirs -Lo ~/bin/up https://github.com/gibfahn/up-rs/releases/latest/download/up-darwin
chmod +x ~/bin/up
~/bin/up link --git-url https://github.com/gibfahn/dot --git-path ~/code/dot --from ~/code/dot/dotfiles
~/code/dot/up
```

Then see [manual.md][].

## TODOs

These need to be done manually until I automate them.

- Debug power etc not showing up.
- Trackpad:
  - Tap to click
  - Click -> Light
  - Swipe down for App Expose
- Accessibility -> Zoom:
  - Use scroll gesture with modifier keys to zoom

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

## Adding a new file to your dotfiles

As long as it goes in `$HOME`, just put it in the same relative directory inside
`./dotfiles/` (so `~/.bashrc` becomes `dot/dotfiles/.bashrc`). If you rerun
`link` it should get symlinked into the right place.

[22c17d0059340e2c90c3c316b746ba8b]: https://gist.github.com/gibfahn/22c17d0059340e2c90c3c316b746ba8b
[3cf4e6a17c85ff67d29fea37ed31963d]: https://gist.github.com/gibfahn/3cf4e6a17c85ff67d29fea37ed31963d/edit
[Install sVim]: https://safari-extensions.apple.com/?q=svim
[Post Install Setup]: #post-install-setup
[sVim]: https://github.com/flipxfx/sVim
[manual.md]: /setup/manual.md
