# Config files

This folder contains things that aren't yet (or can't be) in my dotfiles.

## Karabiner

The files in `~/.config/karabiner` can't be symlinks due to
https://github.com/tekezo/Karabiner-Elements/issues/597, so I make the folder in
dotfiles a symlink to this one.

## Atom

I never really got into Atom, always found it too unresponsive. I should
probably use `$ATOM_HOME` and put it in `dotfiles/.config/atom/`, just haven't
gotten round to it yet.

## AutoGibkey.ahk

My AutoHotKey script from when I was forced to use a Windows computer.
Not particularly maintained.

## FreeFileSync

Really specific preferences you almost certainly don't want.

## SurfingKeys.js

[SurfingKeys](https://github.com/brookhong/Surfingkeys) is a really good vim
shortcuts plugin for Firefox and Chrome, and a good alternative to Vimium.

To use my config follow the instructions in the `./SurfingKeys.js` file.

## Inkscape

Color theme, see `./inkscape/README.md`.

## Gimp

Color theme, see `./gimp/README.md`.

## Safari Omnikey

Json settings for Omnikey plugin

- Install [Omnikey][]
- `🔍` -> `Import/Export` -> Paste contents of `./safari-omnikey.json`

[Omnikey]: http://marioestrada.github.io/safari-omnikey/
