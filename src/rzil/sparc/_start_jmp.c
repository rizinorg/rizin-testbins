// SPDX-FileCopyrightText: 2025 Rot127 <unisono@quyllur.org>
// SPDX-License-Identifier: LGPL-3.0-only

extern void test_branches();

int _start() {
  asm("call test_branches; nop");
  return 0;
}
