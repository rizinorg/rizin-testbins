// SPDX-FileCopyrightText: 2024 Rot127 <unisono@quyllur.org>
// SPDX-License-Identifier: LGPL-3.0-only

extern void *alloc(unsigned int n);

static unsigned *function_0() { return (unsigned *) alloc(12); }
static unsigned *function_1() { return (unsigned *) alloc(16); }

typedef unsigned *(*fcn)();

fcn fcn_arr[] = {
    function_0,
    function_1,
};

int run();

void recurse() {
  run();
}

// The unmapped functions should be called and not ignored.
// But the last clone of the recurse() call must be set to normal
int run() {
  unsigned x = 0;
  for (int i = 0; i < 2; ++i) {
    unsigned *ptr = fcn_arr[i]();
    if (i == 3) {
      recurse();
    }
    x += ptr[0];
  }
  return x;
}
