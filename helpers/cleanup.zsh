# Helper functions for the cleanup scripts, which remove things that older versions of the dotfiles
# created, so that every machine `up` runs on stays cruft-free.
# Every function is a no-op once its work is done, so the scripts are safe to re-run.
# Functions set `work_done=true` if they changed anything.

# Move a file or directory to its new location.
# If both exist, merge the old one into the new one (old wins, as it's the one that was in use),
# then delete the old one.
# Usage: cleanup::migrate <old_path> <new_path>
cleanup::migrate() {
  local old=$1 new=$2
  [[ -e $old || -L $old ]] || return 0
  work_done=true

  # If new is a symlink (e.g. to the shared volume), move into its target.
  new=${new:A}
  # An empty dir has nothing to merge.
  [[ -d $new && -z $(ls -A $new) ]] && rmdir $new

  if [[ ! -e $new ]]; then
    mkdir -p ${new:h}
    # Same filesystem: rename is instant. Otherwise fall through to copy and delete, as mv doesn't
    # cope with read-only directories (e.g. the Go module cache).
    if [[ $(stat -f %d $old) == $(stat -f %d ${new:h}) ]]; then
      mv $old $new
      return 0
    fi
  fi

  if [[ -d $old ]]; then
    # ditto merges like `rsync -a`, but also keeps APFS transparent compression (rsync would write
    # e.g. Xcode DeviceSupport out at ~3x its size on disk).
    ditto $old $new
    chmod -R u+w $old
    rm -rf $old
  else
    # Files (e.g. REPL history): append the old contents so nothing is lost.
    cat $old >>$new
    rm -f $old
  fi
}

# Delete files or directories that are no longer used.
# Usage: cleanup::remove <path>...
cleanup::remove() {
  local p
  for p in "$@"; do
    [[ -e $p || -L $p ]] || continue
    work_done=true
    chmod -R u+w $p
    rm -rf $p
  done
}

# Remove the links `up link` created for files that have since been deleted or moved in a dotfiles
# repo, then remove any parent directories that are now empty.
# Uses the repo's git history, so any file you remove from the repo is cleaned up automatically.
# Usage: cleanup::remove_dead_links <repo_dir> (dotfiles are in <repo_dir>/dotfiles)
cleanup::remove_dead_links() {
  local repo_dir=$1 rel_path link target dir
  local dotfiles_dir=${repo_dir:A}/dotfiles

  {
    git -C $repo_dir log --no-renames --diff-filter=D --name-only --format= -- dotfiles
    # Also uncommitted deletions.
    git -C $repo_dir diff HEAD --no-renames --diff-filter=D --name-only -- dotfiles
  } \
    | sort -u \
    | while IFS= read -r rel_path; do
      link=$HOME/${rel_path#dotfiles/}
      # Only touch broken links that point into this repo.
      [[ -L $link && ! -e $link ]] || continue
      target=$(readlink $link)
      [[ ${target:A} == $dotfiles_dir/* ]] || continue

      work_done=true
      rm $link

      dir=${link:h}
      while [[ $dir != $HOME && -d $dir ]] && rmdir $dir 2>/dev/null; do
        dir=${dir:h}
      done
    done
}
