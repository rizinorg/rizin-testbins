// SPDX-FileCopyrightText: 2025 Rot127 <unisono@quyllur.org>
// SPDX-License-Identifier: LGPL-3.0-only

extern void run_all_tests();
extern void ai_tests();

int _start() {
    asm (
        "call ai_tests; nop;"
        "call run_all_tests; nop;"
    );
    return 0;
}
