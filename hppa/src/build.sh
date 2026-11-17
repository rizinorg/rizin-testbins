#!/bin/sh
# SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
# SPDX-License-Identifier: LGPL-3.0-only
# Built with the Ubuntu 24.04 cross toolchains (gcc 13.3, binutils 2.42).
# Objects get fixed names, as the linker records them in the symbol table,
# and the debug info gets no build directory.
set -e
cd "$(dirname "$0")"
hppa-linux-gnu-gcc -O1 -c -o hppa-exe.o hppa-exe.c
hppa-linux-gnu-gcc -o ../hppa-exe hppa-exe.o
hppa-linux-gnu-gcc -O1 -fPIC -c -o hppa-lib.o hppa-lib.c
hppa-linux-gnu-gcc -shared -o ../hppa-lib.so hppa-lib.o
hppa64-linux-gnu-as -o hppa64-wide.o hppa64-wide.S
hppa64-linux-gnu-ld -e _start -o ../hppa64-wide hppa64-wide.o
hppa-linux-gnu-gcc -g -O2 -fdebug-prefix-map="$PWD"=. -c -o hppa-dwarf.o hppa-dwarf.c
hppa-linux-gnu-gcc -o ../hppa-dwarf hppa-dwarf.o
hppa64-linux-gnu-gcc -g -O2 -fdebug-prefix-map="$PWD"=. -c -o hppa64-dwarf.o hppa-dwarf.c
hppa64-linux-gnu-ld -e main -o ../hppa64-dwarf hppa64-dwarf.o
rm -f hppa-exe.o hppa-lib.o hppa64-wide.o hppa-dwarf.o hppa64-dwarf.o
