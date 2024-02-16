#!/usr/bin/env bash
set -eEuo pipefail

realpath() {
  [ -e "$1" ] && command realpath -- "$1"
}

# cd to the root of the project
cd "$(dirname -- "$(realpath "${BASH_SOURCE[0]}")")"/..

find bin lib legacy-bin -type f |
  grep -Pv '/show-duplicate-java-classes$' |
  grep -Pv '/\.editorconfig$' |
  xargs --verbose shellcheck --shell=bash
