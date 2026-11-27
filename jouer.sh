#!/usr/bin/env sh
set -eu
cd "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
if ! command -v godot >/dev/null 2>&1; then
  printf '%s\n' 'Installez Godot 4.7.2 standard, puis importez prototype/project.godot et lancez avec F5.'
  exit 1
fi
exec godot --path prototype
