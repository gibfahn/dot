#!/usr/bin/env zsh

set -eu

CYAN='\033[0;36m'       # Light blue.
RED='\033[0;31m' # Red.
NC='\033[0m' # No Colour.

temp_dir=$TMPDIR/s
to_tar_dir=$temp_dir/to_tar
gpg_dir=$to_tar_dir/gpg-keys
dotfile_dir=$to_tar_dir/dotfiles

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


  [[ -d $temp_dir ]] && read "user_input?$temp_dir exists. Press Enter to remove the directory and continue."

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

  files_to_backup=(
    ~/.netrc
    ~/.config/hub
    ~/.config/gh/hosts.yml
    ~/.kube/*.conf
    ~/.local/share/gradle/gradle.properties
    ~/.config/coursier/credentials.properties
  )

  copy_to_tmp "${files_to_backup[@]}"

  date=$(date "+%Y-%m-%d")

  set -x
  tar -cJv -f "$temp_dir/s_$date.tar.xz" --directory $to_tar_dir .
  gpg -c "s_$date.tar.xz" # Creates $temp_dir/ssh_$date.tar.xz.gpg
  { set +x; } 2>/dev/null

  open $temp_dir
  read "user_input?Now save the output file $temp_dir/s_$date.tar.xz.gpg
  Then press Enter to cleanup"
}

decrypt() {
  hash gpg || error "Missing 'gpg' dependency" 8

  gpg -d $encrypted_secrets_file >$temp_dir/s.tar.xz
  tar -xvf $temp_dir/s.tar.xz
  for file in "$gpg_dir/privkey-"*; do
    email="${file#$gpg_dir/privkey-}"
    email="${email%.asc}"
    gpg --import "$file"
    echo "${CYAN}From @Gib, now do the following: Type 'trust', 5 (ultimate), y, quit${NC}"
    gpg --edit-key "$email"
  done

  copy_from_tmp
}

cleanup() {
  rm -rv $temp_dir
}

# Usage: exit message [rc]
error() {
  # printf "${RED}Error:${NC} %s\n" "$1"
  echo -e "${RED}Error:${NC} $1"
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
    to_path=~/"${file#$from_dir}"
    if [[ -e $to_path ]]; then
      existing_files+=($to_path)
      continue
    fi
    mkdir -p "$(dirname "$to_path")"
    set -x
    cp "$file" "$to_path"
    { set +x; } 2>/dev/null
  done

  if [[ ${#existing_files[@]} != 0 ]]; then
    echo "Some files already exist, bailing. Please merge manually and then delete $temp_dir:
    Files: ${existing_files[*]}"
  fi
  return 1
}

main "$@"
