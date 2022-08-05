#!/bin/bash
# SPDX-FileCopyrightText: 2022 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

CWD=$(pwd)
cd ../../src/ppc-rzil

printf "Build 64bit le asm test binary\n\n"
$(powerpc64le-linux-gnu-as -a64 -mregnames asm_tests.S -o "$CWD"/asm_tests)

printf "Build 64bit le asm  pseudo fuzz test binary\n\n"
$(powerpc64le-linux-gnu-gcc -static -Wa,-mregnames pseudo_fuzz_main.c pseudo_fuzz_tests.S -o "$CWD"/pseudo_fuzz_tests)

printf "Build 64bit le test binary\n\n"
$(powerpc64le-linux-gnu-gcc -Ttext 0x100000 -static -Wa,-mregnames ppc_main.c ppc64.S -o "$CWD"/ppc64le_uplifted)

printf "Build 32bit be test binary\n\n"
$(powerpc-linux-gnu-gcc -Ttext 0x100000 -static -m32 -Wa,-mregnames ppc_main.c ppc32.S -o "$CWD"/ppc32be_uplifted)
echo "* emulateme-ppc32le"
powerpcle-linux-musl-gcc -Ttext 0x100000 -Wl,-no-pie -static ../../src/ppc-rzil/emulateme.c -o "$CWD"/emulateme-ppc32le

echo "* emulateme-ppc32be"
powerpc-linux-musl-gcc -Ttext 0x100000 -Wl,-no-pie -static ../../src/ppc-rzil/emulateme.c -o "$CWD"/emulateme-ppc32be