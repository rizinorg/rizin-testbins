#!/bin/sh
hexagon-llvm-mc -mno-fixup relocations.s --filetype=obj -o relocs
