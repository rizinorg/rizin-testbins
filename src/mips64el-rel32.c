// SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
// SPDX-License-Identifier: LGPL-3.0-only

// MIPS64 dynamic relocations, which compose R_MIPS_REL32 with R_MIPS_64 to
// relocate a doubleword: without a symbol, against a defined symbol and
// against an imported one, each with its own addend.
//
//   mips64el-linux-gnuabi64-gcc -O1 -fPIC -shared -nostdlib \
//     -Wl,--build-id=none -o ../elf/mips64el-rel32.so mips64el-rel32.c
extern int ext_var;
extern int ext_fn(int);
int local_var = 5;
static int local_arr[8];
int *p_ext = &ext_var + 3;
int *p_local = &local_var + 1;
int *p_static = &local_arr[2];
int (*p_fn)(int) = ext_fn;

int f(int x) {
	return ext_fn(x) + *p_ext + *p_local + *p_static;
}
