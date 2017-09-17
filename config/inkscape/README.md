# Inkscape dark theme

I should probably automate this, but I haven't handled all OSs yet (I've only
set this up on macOS). Everything should be the same elsewhere except for the
`$appDir`.

Basically you want to copy:

```bash
[ `uname` = Darwin ] && appDir=/Applications/Inkscape.app/Contents/Resources
cp gtkrc $appDir/etc/gtk-2.0/gtkrc
cp icons.svg ~/.config/inkscape/icons/icons.svg
```

This gives you dark icons on a dark theme.

Icons come from [here](https://logosbynick.com/new-icons-for-inkscape/)
Theme instructions come from [here](https://github.com/abirnie/inkscape-dark-theme-mac)
