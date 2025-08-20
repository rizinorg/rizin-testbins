#!/bin/sh
# SPDX-FileCopyrightText: 2025 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

# Build with https://github.com/mcayland/sparc-linux-cross
podman run --rm -it --security-opt label=disable -v $(pwd):/tmp ghcr.io/mcayland/sparc-linux-cross sparc-linux-gnu-as -32 -I/tmp/ -o /tmp/sparc32.o /tmp/sparc32.s
podman run --rm -it --security-opt label=disable -v $(pwd):/tmp ghcr.io/mcayland/sparc-linux-cross sparc-linux-gnu-as -32 -I/tmp/ -o /tmp/ai_tests32.o /tmp/ai_tests32.s
podman run --rm -it --security-opt label=disable -v $(pwd):/tmp ghcr.io/mcayland/sparc-linux-cross sparc-linux-gnu-gcc -m32 -nostdlib /tmp/sparc32.o /tmp/ai_tests32.o -o /tmp/sparc32_insn_all.bin /tmp/_start.c

podman run --rm -it --security-opt label=disable -v $(pwd):/tmp ghcr.io/mcayland/sparc-linux-cross sparc-linux-gnu-as -32 -I/tmp/ -o /tmp/sparc32_jmp.o /tmp/sparc32_jmp.s
podman run --rm -it --security-opt label=disable -v $(pwd):/tmp ghcr.io/mcayland/sparc-linux-cross sparc-linux-gnu-gcc -m32 -nostdlib -g -O0 /tmp/sparc32_jmp.o -o /tmp/sparc32_insn_jmp.bin /tmp/_start_jmp.c

mv *.bin ../../../elf/sparc/
ls -lh ../../../elf/sparc/*.bin

