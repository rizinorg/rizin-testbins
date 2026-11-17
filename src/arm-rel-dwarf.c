// SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
// SPDX-License-Identifier: LGPL-3.0-only

// DWARF in an Arm object, whose string and section offsets are R_ARM_ABS32
// addends in the fields of .debug_info.
//
//   arm-linux-gnueabi-gcc -c -g -gdwarf-4 -O1 -gno-record-gcc-switches \
//     -fdebug-prefix-map=$(pwd)=. -o ../elf/arm-rel-dwarf.o arm-rel-dwarf.c
struct point {
	int x, y;
};

static int counter;

int scale(struct point *p, int k) {
	counter++;
	return p->x * k + p->y;
}

int origin_dist(const struct point *p) {
	return p->x + p->y;
}
