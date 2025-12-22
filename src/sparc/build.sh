#!/bin/sh
# SPDX-FileCopyrightText: 2025 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

sparc64-linux-gnu-as -xarch=v9m -64 -I. -o relocs.o sparc-relocations.s

mv relocs.o ../../elf/sparc/relocs
ls -lh ../../elf/sparc/relocs
