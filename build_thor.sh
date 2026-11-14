#!/usr/bin/env sh
set -eu

# Build compiler
./build_odin.sh "$@"

# Link thor binary
mkdir -p bin
ln -sf ../odin bin/thor

if [ -d "$HOME/.local/bin" ]; then
	ln -sf "$(pwd)/odin" "$HOME/.local/bin/thor"
	printf "\nLinked thor to $HOME/.local/bin/thor\n"
fi
