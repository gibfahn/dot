#!/bin/bash

set -eu

error() {
  printf "Error: %s\n" "$1"
  exit 1
}

unpushed_all=""

while read -r git_path; do
  repo_path=$(cd "$(dirname "$git_path")" && pwd)

  unpushed=""

  cd "$repo_path" || error "Couldn't cd to $repo_path"

  unpushed+=$(git stash list --color=always)
  unpushed+=$(git diff --color=always)
  # Plumbing version of 'git branch'.
  for branch in $(git for-each-ref refs/heads/ --format='%(refname:short)'); do
    branch_hash=$(git rev-parse "$branch")

    push_hash=$(git rev-parse "$branch@{push}" 2>/dev/null) && true
    has_push=$?
    upstream_hash=$(git rev-parse "$branch@{upstream}" 2>/dev/null) && true
    has_upstream=$?

    if [[ $has_push == 0 ]]; then
      # What's not in push branch that is in local branch?
      push_delta=$(git cherry -v "$push_hash" "$branch_hash")
      if [[ $push_delta ]]; then
        unpushed+="$branch has commits not in @{push}:\n$push_delta\n"
      fi
    elif [[ $has_upstream == 0 ]]; then
      # What's not in upstream branch that is in local branch?
      upstream_delta=$(git cherry -v "$upstream_hash" "$branch_hash")
      if [[ $upstream_delta ]]; then
        unpushed+="$branch has commits not in @{upstream}:\n$upstream_delta\n"
      fi
    else
      unpushed+="$branch has no @{upstream} or @{push}\n"
    fi
  done

  if [[ -n $unpushed ]]; then
    unpushed_all+="=> $repo_path:\n$(echo -e "$unpushed" | sed 's/^/    /')\n"
  fi

done <<<"$(fd --no-ignore --hidden --type directory '^\.git$' ~/wrk ~/code | grep -v '/go/')"

if [[ -n $unpushed_all ]]; then
  echo -e "$unpushed_all"
  error "Unpushed changes, see above."
fi
