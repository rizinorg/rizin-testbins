// SPDX-FileCopyrightText: 2022 Rot127 <unisono@quyllur.org>
// SPDX-License-Identifier: LGPL-3.0-only

#include <stdio.h>

extern void run_all_tests();

int main() {
    printf("run all\n");
    asm (
        "bl run_all_tests"
    );
    
    return 0;
}