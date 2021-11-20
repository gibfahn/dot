# Gib's Dotfiles

Contains everything I use to setup a new machine (except ssh and gpg keys).

## How to set up a new machine

N.B. until I add better control over ordering, on the first run it is
necessary to clone the `wrk_dotfile_dir` before running `up` for the first time.

```shell
curl --create-dirs -Lo ~/bin/up https://github.com/gibfahn/up-rs/releases/latest/download/up-darwin
chmod +x ~/bin/up
~/bin/up run -bf gibfahn/dot
```

Then see [manual.md][].

### Manual setup

If you just want to update your dotfile symlinks, you can run:

```sh
./link
```

Dotfiles are pretty personal, so feel free to adapt this repo as you wish. If you make a change feel
free to send a Pull Request, you might fix something for me!

## Adding a new file to your dotfiles

As long as it goes in `$HOME`, just put it in the same relative directory inside `./dotfiles/` (so
`~/.bashrc` becomes `dotfiles/.bashrc`). If you rerun `link` it should get symlinked into the right
place.

[manual.md]: /setup/manual.md
