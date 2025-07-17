// SPDX-FileCopyrightText: 2025 Rot127 <unisono@quyllur.org>
// SPDX-License-Identifier: LGPL-3.0-only

extern void run_all_tests();

int _start() {
    asm (
        "call run_all_tests; nop"
    );
    return 0;
}
