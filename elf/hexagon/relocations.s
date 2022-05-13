# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

# Source code taken from https://github.com/llvm/llvm-project/blob/7dfc56c10746faeb5759da9ece3d62db06b88511/llvm/test/MC/Hexagon/relocations.s
# The code was modified (some yet unsupported relocs were removed + renamed symbol).

.global test_sym

test_sym:
  { nop }
  { nop }
  { nop }
  { nop }

# CHECK: R_HEX_B22_PCREL
r_hex_b22_pcrel:
{ jump #test_sym+4 }

# CHECK: R_HEX_B15_PCREL
r_hex_b15_pcrel:
{ if (p0) jump #test_sym }

# CHECK: R_HEX_B7_PCREL
r_hex_b7_pcrel:
{ loop1 (#test_sym, #0) }

# CHECK: R_HEX_LO16
r_hex_lo16:
{ r0.l = #lo(test_sym) }

# CHECK: R_HEX_HI16
r_hex_hi16:
{ r0.h = #hi(test_sym) }

# CHECK: R_HEX_B13_PCREL
r_hex_b13_pcrel:
{ if (r0 != #0) jump:nt #test_sym }

# CHECK: R_HEX_B9_PCREL
r_hex_b9_pcrel:
{ r0 = #0 ; jump #test_sym }

# CHECK: R_HEX_B32_PCREL_X
r_hex_b32_pcrel_x:
{ jump ##test_sym }

# CHECK: R_HEX_32_6_X
r_hex_32_6_x:
{ r0 = ##test_sym }

# CHECK: R_HEX_B22_PCREL_X
r_hex_b22_pcrel_x:
{ jump ##test_sym }

# CHECK: R_HEX_B15_PCREL_X
r_hex_b15_pcrel_x:
{ if (p0) jump ##test_sym }

# CHECK: R_HEX_B7_PCREL_X
r_hex_b7_pcrel_x:
{ loop1 (##test_sym, #0) }

# CHECK: R_HEX_PLT_B22_PCREL
r_hex_plt_b22_pcrel:
jump test_sym@plt

# CHECK: R_HEX_6_PCREL_X
r_hex_6_pcrel_x:
{ r0 = ##test_sym@pcrel
  r1 = r1 }

# CHECK: R_HEX_DTPREL_32_6_X
r_hex_dtprel_32_6_x:
{ r0 = ##test_sym@dtprel }

# CHECK: R_HEX_DTPREL_16_X
r_hex_dtprel_16_x:
{ r0 = ##test_sym@dtprel }

# CHECK: R_HEX_DTPREL_11_X
r_hex_dtprel_11_x:
{ r0 = memw(r0 + ##test_sym@dtprel) }

# CHECK: R_HEX_32
r_hex_32:
.word test_sym

# CHECK: R_HEX_16
r_hex_16:
.half test_sym
.half 0

# CHECK: R_HEX_8
r_hex_8:
.byte test_sym
.byte 0
.byte 0
.byte 0

# CHECK: R_HEX_32_PCREL
r_hex_32_pcrel:
.word test_sym@pcrel

