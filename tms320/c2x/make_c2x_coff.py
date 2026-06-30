#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
# SPDX-License-Identifier: LGPL-3.0-only
#
# Generate a minimal TI COFF2 object for the legacy TMS320C2x. No assembler
# targets the legacy C2x (neither the TI C2000 tools, which emit C28x, nor
# binutils), so this hand-assembles a tiny .text section of known C2x words and
# wraps it in a TI COFF2 container with target_id 0x0092 (the first-generation
# fixed-point id, shared by the C1x/C2x/C5x tools) so Rizin's COFF loader
# autodetects arch=tms320, cpu=c2x. Headers are little-endian (TI COFF
# convention); the C2x instruction words in .text are MSB-first.
import struct, sys

# .text : nop ; zac ; lack #1 ; ret   (MSB-first 16-bit words)
code_words = [0x5500, 0xCA00, 0xCA01, 0xCE26]
text = b"".join(struct.pack(">H", w) for w in code_words)  # big-endian words

F_MAGIC = 0x00C2          # TI COFF version 2
TARGET_ID = 0x0092        # TMS320C1x/C2x/C5x (first-gen fixed point)
OPTHDR_SIZE = 28
SCNHDR_SIZE = 40
HDR_SIZE = 20

# layout: file hdr(20) + target_id(2) + opt hdr(28) + 1 scn hdr(40) + data
data_off = HDR_SIZE + 2 + OPTHDR_SIZE + SCNHDR_SIZE

# file header (little-endian)
fh  = struct.pack("<H", F_MAGIC)   # f_magic
fh += struct.pack("<H", 1)         # f_nscns
fh += struct.pack("<I", 0)         # f_timdat
fh += struct.pack("<I", 0)         # f_symptr (no symbol table)
fh += struct.pack("<I", 0)         # f_nsyms
fh += struct.pack("<H", OPTHDR_SIZE)  # f_opthdr
fh += struct.pack("<H", 0x0002)    # f_flags = F_EXEC
fh += struct.pack("<H", TARGET_ID) # TI target id (read right after the header)

# optional header (little-endian)
oh  = struct.pack("<H", 0x0108)    # magic (TI executable)
oh += struct.pack("<H", 0)         # vstamp
oh += struct.pack("<I", len(text)) # tsize
oh += struct.pack("<I", 0)         # dsize
oh += struct.pack("<I", 0)         # bsize
oh += struct.pack("<I", 0)         # entry
oh += struct.pack("<I", 0)         # text_start
oh += struct.pack("<I", 0)         # data_start

# section header (little-endian)
sh  = b".text\x00\x00\x00"          # s_name[8]
sh += struct.pack("<I", 0)         # s_paddr
sh += struct.pack("<I", 0)         # s_vaddr
sh += struct.pack("<I", len(text)) # s_size (bytes)
sh += struct.pack("<I", data_off)  # s_scnptr
sh += struct.pack("<I", 0)         # s_relptr
sh += struct.pack("<I", 0)         # s_lnnoptr
sh += struct.pack("<H", 0)         # s_nreloc
sh += struct.pack("<H", 0)         # s_nlnno
sh += struct.pack("<I", 0x00000020)  # s_flags = STYP_TEXT

blob = fh + oh + sh + text
assert len(fh) == HDR_SIZE + 2 and len(oh) == OPTHDR_SIZE and len(sh) == SCNHDR_SIZE
out = sys.argv[1] if len(sys.argv) > 1 else "hello_c2x.ticoff2.coff"
open(out, "wb").write(blob)
print("wrote %s (%d bytes), text=%d bytes" % (out, len(blob), len(text)))
