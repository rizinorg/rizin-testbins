#!/bin/sh

sparc64-linux-gnu-as -64 -o sparc64.o sparc64.s
sparc64-linux-gnu-gcc -nostdlib -g -O0 sparc64.o -o sparc64_insn_all.bin main_nostd.c

sparc64-linux-gnu-gcc -nostdlib -g -O0 -o sparc64_emulateme.bin ../emulateme.nostd_2.c

# sparc32-linux-gnu-as -32 -o sparc32.o sparc32.s
# sparc32-linux-gnu-gcc -nostdlib sparc32.o -o sparc32_insn_all.bin main_nostd.c

mv *.bin ../../../elf/sparc/
