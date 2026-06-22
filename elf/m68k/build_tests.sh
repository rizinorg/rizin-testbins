#!/bin/sh
set -eu

CWD=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SRC="$CWD/../../src/rzil/emulateme.c"

CC="${M68K_CC:-m68k-linux-gnu-gcc}"

COMMON_FLAGS="-O0 -fno-pic -fno-pie"
COMMON_LDFLAGS="-Wl,-Ttext=0x100000 -Wl,-no-pie"

"$CC" -m68060 -DM68K_68060_FEATURE $COMMON_FLAGS $COMMON_LDFLAGS "$SRC" -o "$CWD/emulateme-m68060"
"$CC" -mcpu32 -DM68K_CPU32_FEATURE $COMMON_FLAGS $COMMON_LDFLAGS "$SRC" -o "$CWD/emulateme-cpu32"
