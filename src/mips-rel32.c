// SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
// SPDX-License-Identifier: LGPL-3.0-only

// R_MIPS_REL32 dynamic relocations without a symbol, against a defined
// symbol and against an imported one, each with its own addend.
//
//   mips-linux-gnu-gcc -O1 -fPIC -shared -nostdlib -Wl,--build-id=none \
//     -o ../elf/mips-rel32.so mips-rel32.c
extern int ext_var;
static int local_arr[8];
int glob_arr[4];
int *p_ext = &ext_var + 2;
int *p_local = &local_arr[3];
int *p_glob = &glob_arr[1];
static void lf(void) {}
void (*p_lf)(void) = lf;

int get(void) {
	return *p_ext + *p_local + *p_glob;
}
