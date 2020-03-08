#!/usr/bin/env bash

set -e

main() {
  action="$1"; shift
  case "$action" in
    encrypt) encrypt ;;
    decrypt) decrypt ;;
    *) exit 2;
  esac
}

encrypt() {
  cd || exit 1

  mkdir -p ~/.ssh/tmp

  # TODO(gib): There must be a better way to get the list of emails.
  readarray -t emails <<<"$(gpg --list-secret-keys | grep ultimate | sed -E 's/.*<(.*)>.*/\1/')"
  if (( ${#emails[@]} != 2 )); then
    echo "Expected two private key emails, found: ${emails[*]}"
    exit 3
  fi

  for email in "${emails[@]}"; do
    gpg --armor --export "$email" > "$HOME/.ssh/tmp/pubkey-$email.asc"
    gpg --export-secret-keys -a "$email" > "$HOME/.ssh/tmp/privkey-$email.asc"
  done

  cp ~/.netrc ~/.ssh/tmp/

  date=$(date "+%Y-%m-%d")

  tar -cJf "ssh_$date.tar.xz" .ssh
  gpg -c "ssh_$date.tar.xz" # Creates ~/ssh_$date.tar.xz.gpg

  rm "ssh_$date.tar.xz"
}

decrypt() {
  cd || exit 1
  [[ -e ~/.ssh || -e ~/.netrc ]] && exit 1

  gpg -d ssh_*.tar.xz.gpg >ssh.tar.xz
  tar -xf ssh.tar.xz
  rm ssh_*
  mv .ssh ~
  cd ~/.ssh
  for file in "$HOME/.ssh/tmp/privkey-"*; do
    email="${file#$HOME/.ssh/tmp/privkey-}"
    email="${email%.asc}"
    gpg --import "$file"
    echo "Type 'trust', 5 (ultimate), y, quit"
    gpg --edit-key "$email"
  done

  cp ~/.ssh/tmp/.netrc ~/
  rm -r ~/.ssh/tmp
}

main "$@"
