#!/bin/bash

printf "Build 64bit asm test binary\n\n"
$(powerpc64-linux-musl-as -a64 -mregnames asm_tests.S -o asm_tests)

printf "Build 64bit le qemu test binary\n\n"
$(powerpc64le-linux-gnu-gcc -static -Ttext 0x100000 -Wa,-mregnames ppc64_main.c ppc64.S -o ppc64le_uplifted)
