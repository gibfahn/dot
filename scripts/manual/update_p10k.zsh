#!/usr/bin/env zsh

# Update the p10k.zsh shell config

set -euo pipefail

autoload -U colors && colors

set -x

main() {
  cd ~/code/dot

  p10k_path=dotfiles/.config/zsh/early/p10k.zsh

  previous_stock_update=$(git rev-parse ":/update to latest stock p10k.zsh")
  current_commit=$(git rev-parse @)

  # If the latest commit is an "update to latest stock" commit, that means this script was just run,
  # and failed to apply changes due to merge conflicts.
  if [[ $previous_stock_update != "$current_commit" ]]; then
    echo -e "# Updated by up/manual/update_p10k.zsh script.\n" >$p10k_path
    curl -L https://raw.githubusercontent.com/romkatv/powerlevel10k/master/config/p10k-lean.zsh >>$p10k_path
    git add $p10k_path
    git commit -m "feat(zsh): update to latest stock p10k.zsh version"
  else
    previous_stock_update=$(git rev-parse 'HEAD~1^{/update to latest stock p10k.zsh}')
    current_commit=$(git rev-parse @~)
  fi

  # If there are no local changes, then apply our patch.
  if git diff --quiet --exit-code $p10k_path; then
    # If this fails with conflicts, fix them and rerun this script.
    git diff ${previous_stock_update:?} ${current_commit:?} -- ${p10k_path:?} | git -c rerere.enabled=false apply -3
  fi

  if grep -F -e '>>>>>>>' -e '<<<<<<<' $p10k_path; then
    error "Fix the git merge conflicts in $p10k_path before rerunning..."
  fi

  git add $p10k_path
  git commit -m "fix(zsh): re-apply p10k.zsh modifications"
}

# Usage: exit message [rc]
error() {
  echo -e "${fg[red]}Error:${reset_color} $1" >&2
  exit "${2:-1}"
}

main $@
