// SPDX-FileCopyrightText: 2022 Rot127 <unisono@quyllur.org>
// SPDX-License-Identifier: LGPL-3.0-only

#include <stdio.h>

extern void pseudo_fuzz();

int main() {
    printf("run all\n");
    asm (
        "bl pseudo_fuzz"
    );
    
    return 0;
}