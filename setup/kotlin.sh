#!/usr/bin/env bash

. "$(dirname "$0")"/../helpers/setup.sh # Load helper script from dot/helpers.

set -ex

changed=$(gitCloneOrUpdate fwcd/KotlinLanguageServer "$XDG_DATA_HOME/KotlinLanguageServer")
if [[ $USER == gib && -n "$changed" ]]; then
    (
      cd "$XDG_DATA_HOME/KotlinLanguageServer" || { echo "Failed to cd"; exit 1; }
      ./gradlew installDist # If tests passed we could use `./gradlew build`
      ln -sf "$XDG_DATA_HOME/KotlinLanguageServer/server/build/install/server/bin/kotlin-language-server" "$HOME/bin/kotlin-language-server"
    )
fi

