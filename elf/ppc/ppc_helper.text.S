# SPDX-FileCopyrightText: 2022 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

.global max_sd_into_r28
.global max_sw_into_r28
.global max_sh_into_r28
.global max_sb_into_r28
.global max_ud_into_r28
.global max_uw_into_r28
.global max_uh_into_r28
.global max_ub_into_r28
.global min_sd_into_r27
.global min_sw_into_r27
.global min_sh_into_r27
.global min_sb_into_r27
.global min_ud_into_r27
.global min_uw_into_r27
.global min_uh_into_r27
.global min_ub_into_r27

# Helper max (un)signed into r28

max_sd_into_r28:
    lis r20, max_sd@ha
    la r20, max_sd@l(r20)
    ld r28, 0(r20)
    blr

max_sw_into_r28:
    lis r20, max_sw@ha
    la r20, max_sw@l(r20)
    lwa r28, 0(r20)
    blr

max_sh_into_r28:
    lis r20, max_sh@ha
    la r20, max_sh@l(r20)
    lha r28, 0(r20)
    blr

max_sb_into_r28:
    lis r20, max_sb@ha
    la r20, max_sb@l(r20)
    lbz r28, 0(r20)
    blr

max_ud_into_r28:
    lis r20, max_ud@ha
    la r20, max_ud@l(r20)
    ld r28, 0(r20)
    blr

max_uw_into_r28:
    lis r20, max_uw@ha
    la r20, max_uw@l(r20)
    lwz r28, 0(r20)
    blr

max_uh_into_r28:
    lis r20, max_uh@ha
    la r20, max_uh@l(r20)
    lhz r28, 0(r20)
    blr

max_ub_into_r28:
    lis r20, max_ub@ha
    la r20, max_ub@l(r20)
    lbz r28, 0(r20)
    blr

# Helper min (un)signed into r27

min_sd_into_r27:
    lis r20, min_sd@ha
    la r20, min_sd@l(r20)
    ld r27, 0(r20)
    blr

min_sw_into_r27:
    lis r20, min_sw@ha
    la r20, min_sw@l(r20)
    lwa r27, 0(r20)
    blr

min_sh_into_r27:
    lis r20, min_sh@ha
    la r20, min_sh@l(r20)
    lha r27, 0(r20)
    blr

min_sb_into_r27:
    lis r20, min_sb@ha
    la r20, min_sb@l(r20)
    lbz r27, 0(r20)
    blr

min_ud_into_r27:
    lis r20, min_ud@ha
    la r20, min_ud@l(r20)
    ld r27, 0(r20)
    blr

min_uw_into_r27:
    lis r20, min_uw@ha
    la r20, min_uw@l(r20)
    lwz r27, 0(r20)
    blr

min_uh_into_r27:
    lis r20, min_uh@ha
    la r20, min_uh@l(r20)
    lhz r27, 0(r20)
    blr

min_ub_into_r27:
    lis r20, min_ub@ha
    la r20, min_ub@l(r20)
    lbz r27, 0(r20)
    blr
