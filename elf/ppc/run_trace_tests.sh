#!/bin/sh
# SPDX-FileCopyrightText: 2022 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "$0 \"<rz-tracetest exclude regex>\" (optional))"
    exit
fi


echo "* Emulate pseudo_fuzz_tests"
qemu-ppc64le -tracefile pseudo_fuzz_tests.frames pseudo_fuzz_tests
echo "* Tracetest"
if [ $# -eq 1 ]; then
    rz-tracetest -i -s "$1" pseudo_fuzz_tests.frames
else
    rz-tracetest -i pseudo_fuzz_tests.frames
fi
echo "\n\n* DONE Test pseudo_fuzz_tests\n\n"


echo "* Emulate ppc32be"
qemu-ppc -tracefile ppc32be_uplifted.frames ppc32be_uplifted
echo "* Tracetest"
if [ $# -eq 1 ]; then
    rz-tracetest -b -i -s "$1" ppc32be_uplifted.frames
else
    rz-tracetest -b -i ppc32be_uplifted.frames
fi
echo "\n\n* DONE Test ppc32be\n\n"


echo "* Emulate ppc64le"
qemu-ppc64le -tracefile ppc64le_uplifted.frames ppc64le_uplifted
echo "* Tracetest"
if [ $# -eq 1 ]; then
    rz-tracetest -i -s "$1" ppc64le_uplifted.frames
else
    rz-tracetest -i ppc64le_uplifted.frames
fi
echo "\n\n* DONE Test ppc64le\n\n"
