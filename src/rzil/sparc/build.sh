#!/bin/sh
# SPDX-FileCopyrightText: 2025 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

sparc64-linux-gnu-as -xarch=v9m -64 -I. -o sparc64_jmp.o sparc64_jmp.s
sparc64-linux-gnu-gcc -nostdlib -g -O0 sparc64_jmp.o -o sparc64_insn_jmp.bin _start_jmp.c

sparc64-linux-gnu-as -xarch=v9m -64 -I. -o sparc64.o sparc64.s
sparc64-linux-gnu-as -xarch=v9m -64 -I. -o ai_tests.o ai_tests.s
sparc64-linux-gnu-gcc -nostdlib -g -O0 ai_tests.o sparc64.o -o sparc64_insn_all.bin _start.c

sparc64-linux-gnu-gcc -nostdlib -g -O0 -I. -o sparc64_emulateme.bin ../emulateme.nostd_2.c

# sparc32-linux-gnu-as -32 -o sparc32.o sparc32.s
# sparc32-linux-gnu-gcc -nostdlib sparc32.o -o sparc32_insn_all.bin _start.c

mv *.bin ../../../elf/sparc/
ls -lh ../../../elf/sparc/*.bin
