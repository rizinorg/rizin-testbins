// SPDX-FileCopyrightText: 2024 Rot127 <unisono@quyllur.org>
// SPDX-License-Identifier: LGPL-3.0-only

int run();
static void function_0() { run(); }

typedef void (*fcn)();

fcn fcn_arr[] = {
  function_0,
};

/// Endless recursion which should be discovered during analysis
/// (not before by Rizin though) and resolved.
int run() {
  int i = -1;
  i++;
  fcn_arr[i]();
  return 0;
}
