#!/bin/bash
# SPDX-FileCopyrightText: 2022 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

printf "Build 64bit be asm test binary\n\n"
$(powerpc64le-linux-gnu-as -a64 -mregnames asm_tests.S -o asm_tests)

printf "Build 64bit le test binary\n\n"
$(powerpc64le-linux-gnu-gcc -Ttext 0x100000 -static -Wa,-mregnames ppc_main.c ppc64.S -o ppc64le_uplifted)

printf "Build 32bit be test binary\n\n"
$(powerpc-linux-gnu-gcc -Ttext 0x100000 -static -m32 -Wa,-mregnames ppc_main.c ppc32.S -o ppc32be_uplifted)