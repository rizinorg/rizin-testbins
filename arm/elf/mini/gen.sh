#!/usr/bin/env nix-shell
#!nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/e4bae1bd10c9c57b2cf517953ab70060a828ee6f.tar.gz
#!nix-shell --pure -i bash -p llvmPackages.clang-unwrapped llvmPackages.lld
set -e

CPUS=""

# Microcontroller
CPUS="$CPUS cortex-m4"   # v7E-M
CPUS="$CPUS cortex-m23"  # v8-M.baseline
CPUS="$CPUS cortex-m85"  # v8.1-M.mainline

# Application
CPUS="$CPUS cortex-a7"   # v7
CPUS="$CPUS cortex-a53"  # v8
CPUS="$CPUS cortex-a710" # v9

for CPU in $CPUS; do
  echo "=== $CPU"
  clang -target arm-none-eabi -mcpu="$CPU" -nostdlib -fuse-ld=lld mini.c -o "mini-$CPU.elf"
  readelf -A "mini-$CPU.elf"
done;
