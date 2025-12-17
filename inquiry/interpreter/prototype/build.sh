# SPDX-FileCopyrightText: 2024 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

echo "Compile x86 binaries"
clang --static -o x86_icall_malloc icall_malloc.c
# clang -c -o x86_unmapped_fcn_in_loop.o unmapped_fcn_in_loop.c
# clang -c -o x86_discover_recurse.o discover_recurse.c
# clang -c -o x86_paper_dep_example.o paper_dep_example.c
# clang -c -o x86_post_simple_two_deps.o post_simple_two_deps.c
# clang -c -O1 -o x86_post_loop_offsets.o post_loop_offsets.c
# clang -c -o x86_post_pass_ref_across_proc.o post_pass_ref_across_proc.c

echo "Compile Hexagon objects"
/home/$USER/toolchains/Hexagon_SDK/6.4.0.2/tools/HEXAGON_Tools/19.0.04/Tools/bin/clang --static -c -O0 -o hexagon_icall_malloc icall_malloc.c
# hexagon-unknown-linux-musl-clang -c -O0 -o hexagon_unmapped_fcn_in_loop.o unmapped_fcn_in_loop.c
# hexagon-unknown-linux-musl-clang -c -O0 -o hexagon_discover_recurse.o discover_recurse.c
# hexagon-unknown-linux-musl-clang -c -O0 -o hexagon_paper_dep_example.o paper_dep_example.c
# hexagon-unknown-linux-musl-clang -c -O0 -o hexagon_post_simple_two_deps.o post_simple_two_deps.c
# hexagon-unknown-linux-musl-clang -c -O0 -o hexagon_post_loop_offsets.o post_loop_offsets.c
# hexagon-unknown-linux-musl-clang -c -O0 -o hexagon_post_pass_ref_across_proc.o post_pass_ref_across_proc.c

echo "Compile Sparc objects"
sparc64-linux-gnu-gcc --static -c -O0 -o sparc_icall_malloc icall_malloc.c
