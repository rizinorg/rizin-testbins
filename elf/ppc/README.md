### Overview

This folder contains the test binaries for the PPC RZIL uplifting.

The binaries starting with `ppc` are used for validation with [tracetest](https://github.com/rizinorg/rz-tracetest) against QEMU.

Run `./build_tests.sh` to build the binaries.

### Toolchains to build the test binaries

The toolchains used to compile the binaries were one of the following:

- PPC cross toolchain from the Ubuntu package repository.
- The MUSL compiler from: https://musl.cc/#binaries
- The pre-build Intel PPC toolchain: https://www.ibm.com/support/pages/advance-toolchain-linux-power

Not all toolchains support the same instructions or relocation types. But Intel seems to do the best job (supports some instructions and reloc types the others don't).

### Not supported instructions

Since not all instructions are supported by the toolchains some of the tests are commented out.
If you find a toolchain which supports more instructions please add it here and open a PR.

### Writing tests

The tests never use the stack to backup the LR and stack or base pointers. The GPRs are backed up in `run_all_tests` and restored on exit.
If your test instructions which manipulate the LR register it should be backed up into `r30` and restored when the test code returns.
