#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
# SPDX-License-Identifier: CC0-1.0
"""Generate small ELF objects without depending on a host assembler or linker.

The virtual base differs from the file offset, and the 64-bit image is above
4 GiB. Each relocation has an eight-byte slot with guard bytes, so truncated
writes and writes beyond the relocation width are visible. Both GOT sections
are present to check that their entries use a common base.
"""

from pathlib import Path
import struct


# (relocation number, symbol index), in the order of the .data slots.
RELOCS = {
    32: [(3, 1), (43, 1), (4, 4), (10, 0), (9, 1), (8, 0),
         (6, 1), (7, 4), (14, 2), (35, 2), (36, 2), (36, 3),
         (42, 0), (1, 1), (2, 1), (20, 1), (21, 1), (22, 1),
         (23, 1), (5, 1), (3, 4), (43, 4), (43, 5)],
    64: [(9, 1), (42, 1), (28, 1), (3, 1), (27, 1), (26, 0),
         (29, 0), (25, 1), (4, 4), (6, 1), (7, 4), (8, 0),
         (16, 2), (17, 2), (17, 3), (18, 2), (37, 0), (5, 1),
         (9, 4), (42, 4), (42, 5)],
}


def generate(bits):
    data = bytearray(4096)
    base = 0x10000 if bits == 32 else 0x100000000

    def pack(offset, fmt, *values):
        struct.pack_into('<' + fmt, data, offset, *values)

    data[:16] = b'\x7fELF' + bytes([1 if bits == 32 else 2, 1, 1, 0]) + bytes(8)
    names = ['', '.got', '.got.plt', '.data', '.tdata',
             '.rel.data' if bits == 32 else '.rela.data',
             '.dynsym', '.dynstr', '.shstrtab']
    strings = b'\0value\0tls_local\0tls_import\0function\0external\0'
    data[0x900:0x900 + len(strings)] = strings
    section_names = b'\0'
    name_offsets = [0]
    for name in names[1:]:
        name_offsets.append(len(section_names))
        section_names += name.encode() + b'\0'
    data[0xa00:0xa00 + len(section_names)] = section_names

    # TLS values are offsets in the defining module, not virtual addresses.
    symbols = [(0, 0, 0, 0, 0, 0),
               (1, base + 0x3f0, 8, 0x11, 0, 3),
               (7, 8, 4, 0x16, 0, 4),
               (17, 0, 4, 0x16, 0, 0),
               (28, base + 0x3f8, 1, 0x12, 0, 3),
               (37, 0, 8, 0x11, 0, 0)]
    for i, (name, value, size, info, other, shndx) in enumerate(symbols):
        if bits == 32:
            pack(0x800 + i * 16, 'IIIBBH', name, value, size, info, other, shndx)
        else:
            pack(0x800 + i * 24, 'IBBHQQ', name, info, other, shndx, value, size)

    relocs = [(0x208, 6, 1), (0x228, 7, 4), (0x210, 6, 5)]
    relocs += [(0x300 + i * 8, kind, symbol)
               for i, (kind, symbol) in enumerate(RELOCS[bits])]
    for i, (offset, kind, symbol) in enumerate(relocs):
        pack(offset, 'Q', 0xaaaaaaaa00000003)
        if bits == 32:
            pack(0x500 + i * 8, 'II', base + offset, (symbol << 8) | kind)
        else:
            pack(0x500 + i * 24, 'QQq', base + offset, (symbol << 32) | kind, 3)
    data[0x3f8] = 0xc3
    reloc_size = 8 if bits == 32 else 24
    symbol_size = 16 if bits == 32 else 24
    # sh_name, type, flags, addr, offset, size, link, info, alignment, entry size
    sections = [(0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                (name_offsets[1], 1, 3, base + 0x200, 0x200, 16, 0, 0, 8, 0),
                (name_offsets[2], 1, 3, base + 0x220, 0x220, 16, 0, 0, 8, 0),
                (name_offsets[3], 1, 3, base + 0x300, 0x300, 256, 0, 0, 8, 0),
                (name_offsets[4], 1, 0x403, base + 0x400, 0x400, 16, 0, 0, 8, 0),
                (name_offsets[5], 9 if bits == 32 else 4, 2, base + 0x500, 0x500,
                 len(relocs) * reloc_size, 6, 3, 8, reloc_size),
                (name_offsets[6], 11, 2, base + 0x800, 0x800,
                 len(symbols) * symbol_size, 7, 1, 8, symbol_size),
                (name_offsets[7], 3, 2, base + 0x900, 0x900, len(strings), 0, 0, 1, 0),
                (name_offsets[8], 3, 0, 0, 0xa00, len(section_names), 0, 0, 1, 0)]
    if bits == 32:
        pack(16, 'HHIIIIIHHHHHH', 3, 3, 1, base + 0x3f8, 52, 0xb00,
             0, 52, 32, 2, 40, len(sections), 8)
        pack(52, 'IIIIIIII', 1, 0, base, base, 4096, 4096, 7, 0x1000)
        pack(84, 'IIIIIIII', 7, 0x400, base + 0x400, base + 0x400, 16, 16, 4, 8)
    else:
        pack(16, 'HHIQQQIHHHHHH', 3, 62, 1, base + 0x3f8, 64, 0xb00,
             0, 64, 56, 2, 64, len(sections), 8)
        pack(64, 'IIQQQQQQ', 1, 7, 0, base, base, 4096, 4096, 0x1000)
        pack(120, 'IIQQQQQQ', 7, 4, 0x400, base + 0x400, base + 0x400, 16, 16, 8)
    for i, section in enumerate(sections):
        pack(0xb00 + i * (40 if bits == 32 else 64),
             'IIIIIIIIII' if bits == 32 else 'IIQQQQIIQQ', *section)
    return data


if __name__ == '__main__':
    output = Path(__file__).resolve().parents[2] / 'elf'
    for bits in (32, 64):
        (output / ('x86-common-relocs%d.so' % bits)).write_bytes(generate(bits))
