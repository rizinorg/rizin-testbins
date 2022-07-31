<!--
SPDX-FileCopyrightText: 2022 Rot127 <unisono@quyllur.org>
SPDX-License-Identifier: LGPL-3.0-only
-->

### Overview

This folder contains the test binaries for the PPC RZIL uplifting.

The binaries are used for validation with [rz-tracetest](https://github.com/rizinorg/rz-tracetest) against QEMU and the RZIL related asm and analysis tests.

Run `./build_tests.sh` to build the binaries.

The 64bit little endian binaries were compiled with the [Intel advance toolchain](https://www.ibm.com/support/pages/advtool-cross-compilers) and the 32bit big endian with the GNU toolchain.

Both toolchains can be installed via the package manager. Find the install instructions for the Intel toolchain at the link above.

**Please note**: The musl toolchains did not work. QEMU segfaults before main is reached. If you get it to work, please open a PR.

The toolchains used to compile the binaries were one of the following:

After you've installed the toolchains simply run `./build_tests.sh`.

### Testing

1. To produce a trace of those binaries run them with [BAPs QEMU](https://github.com/BinaryAnalysisPlatform/qemu). It saves the trace in a `.frames` file.
1. Afterwards run `rz-tracetest` with the generated `.frames` file.

**NOTE**:

- Big endian traces need the `-b` option passed to `rz-tracetest`.
- Some instructions are broken in Capstone and cannot be emulated properly. Check Rizin's issues to find out which one and ignore them via `rz-tracetests` `-s` option.

### Adding new instructions

- The tests never use the stack to backup the LR register, stack and base pointers. The GPRs are backed up in `run_all_tests` and restored on exit. If you test instructions which manipulate the `LR` register, backup `LR` into `r30` and restored it when the test code returns.

- Due to this backup of `LR` your tests should never use the `r30` register.

- Please add all new instructions to both the 64 and 32bit src files. If it is a 64bit only instruction add it to the corresponding 32bit source file anyways (and comment it out). This way we can do a simple diff between both source files and check that no instruction has been forgotten.
