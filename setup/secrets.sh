#!/usr/bin/env zsh

set -eu

autoload -U colors && colors

temp_dir=$TMPDIR/s
to_tar_dir=$temp_dir/to_tar
gpg_dir=$to_tar_dir/gpg-keys
dotfile_dir=$to_tar_dir/dotfiles
git_keychain_dir=$to_tar_dir/keychain/git

main() {
  local action user_input ret_code

  [[ ${1:-} =~ ^(--help|-h)$ ]] && { usage; exit; }

  [[ ${1:-} =~ ^(--version|-v)$ ]] && { echo "main"; exit; }

  action="${1:-}"
  shift || { usage; error "Must specify encrypt or decrypt." 4; }

  if [[ $action == decrypt ]]; then
    encrypted_secrets_file=${1:-}
    shift ||  { usage; error "decrypt takes the file to decrypt as an argument." 5; }
  fi

  if [[ -d $temp_dir ]]; then
    log_info "$temp_dir exists. Press Enter to remove the directory and continue."
    read "user_input"
  fi

  mkdir -p $temp_dir
  cd $temp_dir

  trap "cleanup" EXIT INT TERM QUIT

  case "$action" in
    encrypt) encrypt && true ;;
    decrypt) decrypt && true ;;
    *) usage; error "Unrecognized arguments: '$action'" 2 ;;
  esac
  ret_code=$?
  cleanup
  exit $ret_code
}

usage() {
  echo -e "Usage:\n  $0 encrypt|decrypt [file_to_decrypt]

  encrypt: tars up secret files on disk and gpg encrypts the tarball. Opens output directory in the console.
  decrypt: takes file encrypted by this script as the first argument

  Dependencies:
  - GNU coreutils and gpg:
    brew install coreutils gnupg
  "
}

encrypt() {
  local files_to_backup

  export_gpg_keys

  files_to_backup=(
    ~/.netrc
    ~/.config/hub
    ~/.config/gh/hosts.yml
    ~/.kube/*.conf
    ~/.local/share/gradle/gradle.properties
    ~/.config/coursier/credentials.properties
  )

  copy_to_tmp "${files_to_backup[@]}"

  git_urls=(
    github.com
    github.pie.apple.com
  )

  read_git_tokens "${git_urls[@]}"

  date=$(date "+%Y-%m-%d")

  tar -cJv -f "$temp_dir/s_$date.tar.xz" --directory $to_tar_dir .
  gpg -c "s_$date.tar.xz" # Creates $temp_dir/ssh_$date.tar.xz.gpg

  open $temp_dir
  log_info "Now save the output file $temp_dir/s_$date.tar.xz.gpg
    Then press Enter to cleanup"
  read "user_input"
}

decrypt() {
  hash gpg || error "Missing 'gpg' dependency" 8

  gpg -d $encrypted_secrets_file >$temp_dir/s.tar.xz
  mkdir -p $to_tar_dir
  tar -xvf $temp_dir/s.tar.xz --directory $to_tar_dir
  copy_from_tmp
  write_git_tokens
  import_gpg_keys
}

cleanup() {
  rm -rv $temp_dir
}

# Usage: exit message [rc]
error() {
  # printf "${fg[red]}Error:${reset_color} %s\n" "$1"
  echo -e "${fg[red]}Error:${reset_color} $1"
  exit "${2:-1}"
}

copy_to_tmp() {
  local to_path file
  for file in "$@"; do
    to_path=$dotfile_dir/"${file#~/}"
    mkdir -p "$(dirname "$to_path")"
    cp "$file" "$to_path"
  done
}

copy_from_tmp() {
  local from_dir file existing_files
  from_dir=$dotfile_dir

  local to_path file
  files=(${(0)"$(find "$from_dir" -print0)"})
  existing_files=()

  for file in "${files[@]}"; do
    to_path=~/"${file#$from_dir/}"
    [[ -d $to_path ]] && continue # Skip directories.
    if [[ -e $to_path ]]; then
      from_sha=$(sha256sum $file | awk '{print $1}')
      to_sha=$(sha256sum $to_path | awk '{print $1}')
      if [[ $from_sha == $to_sha ]]; then
        echo "Shasums match, $file -> $to_path = $to_sha"
        continue
      fi
      set -x
      $VISUAL -d $file $to_path
      { set +x; } 2>/dev/null
      continue
    fi

    mkdir -p "$(dirname "$to_path")"
    set -x
    cp "$file" "$to_path"
    { set +x; } 2>/dev/null
  done
}

import_gpg_keys() {
  for file in "$gpg_dir/privkey-"*; do
    email="${file#$gpg_dir/privkey-}"
    email="${email%.asc}"
    gpg --import "$file"
    echo "${fg[cyan]}From @Gib, now do the following: Type 'trust', 5 (ultimate), y, quit${reset_color}"
    gpg --edit-key "$email"
  done
}

export_gpg_keys() {
  # TODO(gib): There must be a better way to get the list of emails.
  emails=("${(@f)$(gpg --list-secret-keys | grep ultimate | sed -E 's/.*<(.*)>.*/\1/')}")
  if (( ${#emails[@]} != 2 )); then
    error "Expected two private key emails, found: ${emails[*]}" 3
  fi

  mkdir -p $gpg_dir
  for email in "${emails[@]}"; do
    gpg --armor --export "$email" > "$gpg_dir/pubkey-$email.asc"
    gpg --export-secret-keys -a "$email" > "$gpg_dir/privkey-$email.asc"
  done
}

read_git_tokens() {
  mkdir -p $git_keychain_dir
  for url in $@; do
    set -x
    git credential fill <<<"protocol=https
host=$url" >$git_keychain_dir/$url
    {set +x;} 2>/dev/null
  done
}

write_git_tokens() {
  for file in $git_keychain_dir/*; do
    set -x
    git credential-osxkeychain store <$file
    {set +x;} 2>/dev/null
  done
}

log_info() {
    print >&2 "${fg[magenta]}$1${reset_color}"
}

main "$@"
