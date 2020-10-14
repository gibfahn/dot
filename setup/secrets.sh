#!/usr/bin/env bash

set -eu

main() {
  action="${1:-}"
  shift || { usage; error "Must specify encrypt or decrypt." 4; }
  case "$action" in
    encrypt) encrypt ;;
    decrypt) decrypt ;;
    --help|-h) usage ;;
    --version|-v) echo "master" ;;
    *) usage; error "Unrecognized arguments: '$action'" 2 ;;
  esac
}

usage() {
  echo -e "Usage:\n  $0 encrypt|decrypt

  encrypt: tars up secret files on disk and gpg encrypts the tarball. Saves file to ~.
  decrypt: takes file encrypted by this script in ~ and decrypts and extracts it.

  Dependencies:
  - GNU coreutils and gpg:
    brew install coreutils gnupg
  "
}

CYAN='\033[0;36m'       # Light blue.
RED='\033[0;31m' # Red.
NC='\033[0m' # No Colour.

# Usage: exit message [rc]
error() {
  # printf "${RED}Error:${NC} %s\n" "$1"
  echo -e "${RED}Error:${NC} $1"
  exit "${2:-1}"
}

encrypt() {
  cd || error "Failed to cd home." 1

  mkdir -p ~/.ssh/tmp

  # TODO(gib): There must be a better way to get the list of emails.
  readarray -t emails <<<"$(gpg --list-secret-keys | grep ultimate | sed -E 's/.*<(.*)>.*/\1/')"
  if (( ${#emails[@]} != 2 )); then
    error "Expected two private key emails, found: ${emails[*]}" 3
  fi

  for email in "${emails[@]}"; do
    gpg --armor --export "$email" > "$HOME/.ssh/tmp/pubkey-$email.asc"
    gpg --export-secret-keys -a "$email" > "$HOME/.ssh/tmp/privkey-$email.asc"
  done

  cp ~/.netrc ~/.ssh/tmp/
  cp ~/.config/hub ~/.ssh/tmp/
  mkdir -p ~/.ssh/tmp/kube/ ~/.ssh/tmp/gh/
  cp ~/.config/gh/hosts.yml ~/.ssh/tmp/gh/hosts.yml
  cp ~/.kube/*.conf ~/.ssh/tmp/kube/

  date=$(date "+%Y-%m-%d")

  tar -cJf "ssh_$date.tar.xz" .ssh
  gpg -c "ssh_$date.tar.xz" # Creates ~/ssh_$date.tar.xz.gpg

  rm "ssh_$date.tar.xz"
}

decrypt() {
  cd || error "Failed to cd home." 1
  [[ -e ~/.ssh || -e ~/.netrc ]] && error "~/.ssh or ~/.netrc already exists." 6

  hash gpg || error "Missing 'gpg' dependency" 8

  gpg -d ssh_*.tar.xz.gpg >ssh.tar.xz
  tar -xf ssh.tar.xz
  rm ssh_* ssh.tar.xz
  cd ~/.ssh
  for file in "$HOME/.ssh/tmp/privkey-"*; do
    email="${file#$HOME/.ssh/tmp/privkey-}"
    email="${email%.asc}"
    gpg --import "$file"
    echo "${CYAN}Gib Do: Type 'trust', 5 (ultimate), y, quit${NC}"
    gpg --edit-key "$email"
  done

  cp -v ~/.ssh/tmp/.netrc ~/
  mkdir -p ~/.config
  cp  -v ~/.ssh/tmp/hub ~/.config/
  mkdir -p ~/.config/gh
  cp  -v ~/.ssh/tmp/gh/hosts.yml ~/.config/gh/hosts.yml
  mkdir -p ~/.kube/
  cp  -v ~/.ssh/tmp/kube/* ~/.kube/
  rm -rv ~/.ssh/tmp
}

main "$@"
