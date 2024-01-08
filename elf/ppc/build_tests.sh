#!/bin/bash
# SPDX-FileCopyrightText: 2022 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

CWD=$(pwd)
cd ../../src/rzil/ppc

echo "* asm_tests"
powerpc64le-linux-gnu-as -a64 -mregnames asm_tests.S -o "$CWD"/asm_tests

echo "* pseudo_fuzz_tests"
powerpc64le-linux-gnu-gcc -static -Wa,-mregnames pseudo_fuzz_main.c pseudo_fuzz_tests.S -o "$CWD"/pseudo_fuzz_tests

echo "* ppc64le_uplifted"
powerpc64le-linux-gnu-gcc -Ttext 0x100000 -static -Wa,-mregnames ppc_main.c ppc64.S -o "$CWD"/ppc64le_uplifted

echo "* ppc32be_uplifted"
powerpc-linux-gnu-gcc -Ttext 0x100000 -static -m32 -Wa,-mregnames ppc_main.c ppc32.S -o "$CWD"/ppc32be_uplifted

echo "* ppc32be_uplifted"
powerpc-linux-gnu-gcc -Ttext 0x100000 -static -m32 -Wa,-mregnames ppc_main.c ppc32.S -o "$CWD"/ppc32be_uplifted

echo "* emulateme-ppc32le"
powerpcle-linux-musl-gcc -Ttext 0x100000 -Wl,-no-pie -static ../../src/rzil/emulateme.c -o "$CWD"/emulateme-ppc32le

echo "* emulateme-ppc32be"
powerpc-linux-gnu-gcc -Ttext 0x100000 -Wl,-no-pie -static ../../src/rzil/emulateme.c -o "$CWD"/emulateme-ppc32be

echo "* emulateme-ppc64le"
powerpc64le-linux-gnu-gcc -Ttext 0x100000 -Wl,-no-pie -static ../../src/rzil/emulateme.c -o "$CWD"/emulateme-ppc64le

echo "* emulateme-ppc64be"
powerpc64-linux-musl-gcc -Ttext 0x100000 -Wl,-no-pie -static ../../src/rzil/emulateme.c -o "$CWD"/emulateme-ppc64be
