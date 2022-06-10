#!/usr/bin/env zsh

# Update the p10k.zsh shell config

set -euo pipefail

set -x

cd ~/code/dot

p10k_path=dotfiles/.config/zsh/early/p10k.zsh

previous_stock_update=$(git rev-parse ":/update to latest stock p10k.zsh")
current_commit=$(git rev-parse @)

echo -e "# Updated by up/manual/update_p10k.zsh script.\n" > $p10k_path
curl -L https://raw.githubusercontent.com/romkatv/powerlevel10k/master/config/p10k-lean.zsh >> $p10k_path
git add $p10k_path
git commit -m "feat(zsh): update to latest stock p10k.zsh version"

git diff $previous_stock_update $current_commit -- $p10k_path | git apply
