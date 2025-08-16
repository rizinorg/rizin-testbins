#!/bin/ksh
# SPDX-FileCopyrightText: 2025 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

# Tested on OpenBSD 7.7 sparc64
# Install gas from ports

gas -KPIC -xarch=v9m -64 -I. -o sparc64_openbsd.o sparc64_openbsd.s
gcc -g -O0 sparc64_openbsd.o -o sparc64_insn_openbsd.bin main.c
