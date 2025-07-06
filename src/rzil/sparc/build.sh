#!/bin/sh

sparc64-linux-gnu-as -64 -o sparc64.o sparc64.s
sparc64-linux-gnu-gcc -nostdlib sparc64.o -o sparc64_insn_all.bin main_nostd.c

# sparc32-linux-gnu-as -32 -o sparc32.o sparc32.s
# sparc32-linux-gnu-gcc -nostdlib sparc32.o -o sparc32_insn_all.bin main_nostd.c

mv *.bin ../../../elf/sparc/
