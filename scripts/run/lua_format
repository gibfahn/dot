#!/usr/bin/env zsh

set -eux

case $(uname) in
  Darwin) url=https://github.com/Koihik/vscode-lua-format/raw/master/bin/darwin/lua-format ;;
  Linux) url=https://github.com/Koihik/vscode-lua-format/raw/master/bin/darwin/lua-format ;;
  *)
    echo "Unknown architecture"
    exit 1
    ;;
esac

curl -L -o ~/bin/lua-format "$url"
chmod +x ~/bin/lua-format
