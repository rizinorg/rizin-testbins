#!/bin/bash

printf "Build 64bit rzil test binary\n\n"
$(powerpc64-linux-musl-as -a64 -mregnames ppc64_fp.S -o ppc64_fp)

printf "Build 64bit asm test binary\n\n"
$(powerpc64-linux-musl-as -a64 -mregnames asm_tests.S -o asm_tests)

printf "Build 64bit le qemu test binary\n\n"
$(powerpc64le-linux-gnu-gcc -static -Wa,-mregnames qemu_ppc64_fp_main.c ppc64_qemu.S -o qemu_ppc64le)

#printf "Build 32bit test binary\n"
#$(powerpc64-linux-gnu-as -a32 -mregnames *_32.s -o ppc_insn_tests_32)

