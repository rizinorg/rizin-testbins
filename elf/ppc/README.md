<!--
SPDX-FileCopyrightText: 2022 Rot127 <unisono@quyllur.org>
SPDX-License-Identifier: LGPL-3.0-only
-->

### Overview

This folder contains the test binaries for the PPC RZIL uplifting.

The binaries are used for validation with [rz-tracetest](https://github.com/rizinorg/rz-tracetest) against QEMU and the RZIL related asm and analysis tests.

Run `./build_tests.sh` to build the binaries.

### Toolchains

For building we use the following toolchains:

- `ppc64le`: Intel [Intel advance toolchain](https://www.ibm.com/support/pages/advtool-cross-compilers)
- `ppc32` GNU toolchain.
- `ppc32le`, `ppc64`: MUSL toolchains

Intel and GNU toolchains can be installed via the package manager. (You can find the install instructions for the Intel toolchain at the link above).

MUSL toolchains can be downloaded [here](https://musl.cc/#binaries).

**Please note**: Exclusively using MUSL was not possible because binaries from MUSL segfault in QEMU before main is reached. If you get it to work, please open a PR.

After you've installed the toolchains simply run `./build_tests.sh`.

### Testing

- To generate the trace of the binary test files you need to build [BAPs QEMU](https://github.com/BinaryAnalysisPlatform/qemu) for `ppc64le` and `ppc`.
- Afterwards build [rz-tracetest](https://github.com/rizinorg/rz-tracetest).
- Make sure all tools are in your `PATH` and run `./run_trace_tests.sh`.

**Notes for manual testing**:

- Big endian traces need the `-b` option passed to `rz-tracetest`.
- Some instructions are broken in Capstone and cannot be emulated properly. Check Rizin's issues to find out which one and ignore them via `rz-tracetests` `-s` option.

### Adding new instructions

- The tests never use the stack to backup the LR register, stack and base pointers. The GPRs are backed up in `run_all_tests` and restored on exit. If you test instructions which manipulate the `LR` register, backup `LR` into `r30` and restored it when the test code returns.

- Due to this backup of `LR` your tests should never use the `r30` register.

- Please add all new instructions to both the 64 and 32bit src files. If it is a 64bit only instruction add it to the corresponding 32bit source file anyways (and comment it out). This way we can do a simple diff between both source files and check that no instruction has been forgotten.
