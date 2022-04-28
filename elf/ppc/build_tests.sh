#!/bin/bash

printf "Build 64bit test binary\n\n"
$(powerpc64-linux-gnu-as -a64 -mregnames ppc64_fp.S -o ppc64_fp)

#printf "Build 32bit test binary\n"
#$(powerpc64-linux-gnu-as -a32 -mregnames *_32.s -o ppc_insn_tests_32)

