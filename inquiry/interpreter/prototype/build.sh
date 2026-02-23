# SPDX-FileCopyrightText: 2026 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

echo "Compile x86 objects"
clang --static -c -o x86_icall_malloc icall_malloc.c
clang --static -c -o x86_unmapped_fcn_in_loop unmapped_fcn_in_loop.c
clang --static -c -o x86_discover_recurse discover_recurse.c

HEXAGON_SDK_TOOLS_BIN="/home/$USER/toolchains/Hexagon_SDK/6.4.0.2/tools/HEXAGON_Tools/19.0.04/Tools/bin/"

echo "Compile Hexagon objects"
$HEXAGON_SDK_TOOLS_BIN/clang --static -c -O0 -o hexagon_icall_malloc icall_malloc.c
$HEXAGON_SDK_TOOLS_BIN/clang --static -c -O0 -o hexagon_unmapped_fcn_in_loop unmapped_fcn_in_loop.c
$HEXAGON_SDK_TOOLS_BIN/clang --static -c -O0 -o hexagon_discover_recurse discover_recurse.c

echo "Compile Sparc objects"
sparc64-linux-gnu-gcc --static -c -O0 -o sparc_icall_malloc icall_malloc.c
sparc64-linux-gnu-gcc --static -c -O0 -o sparc_unmapped_fcn_in_loop unmapped_fcn_in_loop.c
sparc64-linux-gnu-gcc --static -c -O0 -o sparc_discover_recurse discover_recurse.c

echo "Compile ARM objects"
arm-none-eabi-gcc --static -c -O0 -o arm_icall_malloc icall_malloc.c
arm-none-eabi-gcc --static -c -O0 -o arm_unmapped_fcn_in_loop unmapped_fcn_in_loop.c
arm-none-eabi-gcc --static -c -O0 -o arm_discover_recurse discover_recurse.c

echo "Compile Mips64 objects"
mips64-linux-gnu-gcc --static -c -O0 -o mips64_icall_malloc icall_malloc.c
mips64-linux-gnu-gcc --static -c -O0 -o mips64_unmapped_fcn_in_loop unmapped_fcn_in_loop.c
mips64-linux-gnu-gcc --static -c -O0 -o mips64_discover_recurse discover_recurse.c
