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
hppa-linux-gnu-strip -o ../hppa-exe-stripped ../hppa-exe
hppa-linux-gnu-strip -o ../hppa-lib-stripped.so ../hppa-lib.so
hppa-linux-gnu-as -o hppa-noret.o hppa-noret.S
hppa-linux-gnu-gcc -nostartfiles -o ../hppa-noret hppa-noret.o
hppa-linux-gnu-as -o hppa-rodata.o hppa-rodata.S
hppa-linux-gnu-ld -e _start -o ../hppa-rodata hppa-rodata.o
rm -f hppa-exe.o hppa-lib.o hppa64-wide.o hppa-dwarf.o hppa64-dwarf.o hppa-noret.o hppa-rodata.o

# These standalone fixtures model the BSD and HP-UX ELF layouts with GNU binutils 2.44.
hppa-linux-gnu-as -o hppa-bsd-init.o hppa-bsd-init.S
hppa-linux-gnu-ld -shared -e init_hook -o ../hppa-bsd-init.so hppa-bsd-init.o
hppa-linux-gnu-elfedit --output-osabi HPUX ../hppa-bsd-init.so
hppa64-linux-gnu-as -o hppa64-hpux.o hppa64-hpux.S
hppa64-linux-gnu-ld -shared -Ttext-segment=0x4000000000000000 -e hook -o ../hppa64-hpux.so hppa64-hpux.o
hppa64-linux-gnu-elfedit --output-osabi HPUX ../hppa64-hpux.so
rm -f hppa-bsd-init.o hppa64-hpux.o
