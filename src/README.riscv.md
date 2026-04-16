RISC-V Requirements
-------------------
 * To get `/opt/riscv/bin/riscv64-unknown-linux-gnu-gcc`:
  * Download and make the GNU toolchain from https://github.com/riscv-collab/riscv-gnu-toolchain, follow the instructions to install it, the commit hash used to build the binaries committed to this repo is 357800bf2c5115ade5bc33f69af79c641db63cc8
 * To get `clang` and `llvm-mc`:
  * Download them from any repositery, ensure they have the following version string:
    ```bash
    $ clang --version
      => Ubuntu clang version 18.1.3 (1ubuntu1)
      => Target: x86_64-pc-linux-gnu
      => Thread model: posix
      => InstalledDir: /usr/bin
    $ llvm-mc --version
      => Ubuntu LLVM version 18.1.3
      => Optimized build.
      => Registered Targets:
         aarch64     - AArch64 (little endian)
         aarch64_32  - AArch64 (little endian ILP32)
         aarch64_be  - AArch64 (big endian)
         amdgcn      - AMD GCN GPUs
         arm         - ARM
         arm64       - ARM64 (little endian)
         arm64_32    - ARM64 (little endian ILP32)
         armeb       - ARM (big endian)
         avr         - Atmel AVR Microcontroller
         bpf         - BPF (host endian)
         bpfeb       - BPF (big endian)
         bpfel       - BPF (little endian)
         hexagon     - Hexagon
         lanai       - Lanai
         loongarch32 - 32-bit LoongArch
         loongarch64 - 64-bit LoongArch
         m68k        - Motorola 68000 family
         mips        - MIPS (32-bit big endian)
         mips64      - MIPS (64-bit big endian)
         mips64el    - MIPS (64-bit little endian)
         mipsel      - MIPS (32-bit little endian)
         msp430      - MSP430 [experimental]
         nvptx       - NVIDIA PTX 32-bit
         nvptx64     - NVIDIA PTX 64-bit
         ppc32       - PowerPC 32
         ppc32le     - PowerPC 32 LE
         ppc64       - PowerPC 64
         ppc64le     - PowerPC 64 LE
         r600        - AMD GPUs HD2XXX-HD6XXX
         riscv32     - 32-bit RISC-V
         riscv64     - 64-bit RISC-V
         sparc       - Sparc
         sparcel     - Sparc LE
         sparcv9     - Sparc V9
         systemz     - SystemZ
         thumb       - Thumb
         thumbeb     - Thumb (big endian)
         ve          - VE
         wasm32      - WebAssembly 32-bit
         wasm64      - WebAssembly 64-bit
         x86         - 32-bit X86: Pentium-Pro and above
         x86-64      - 64-bit X86: EM64T and AMD64
         xcore       - XCore
         xtensa      - Xtensa 32
  ```
  * To download Bootlin rv32, download from https://toolchains.bootlin.com/downloads/releases/toolchains/riscv32-ilp32d/tarballs/riscv32-ilp32d--musl--stable-2025.08-1.tar.xz and untar to any location.

This is a best-effort attempt at reproducibility, there might be hidden or ambient setup on the original dev machine that will make the committed binaries in this repo not bit-for-bit identical to any binaries newly compiled on other machines using those instructions. Please use the comitted binaries only for maximum reproducibility. 


 * To make riscv_arrsum.c: 
 ```bash
/opt/riscv/bin/riscv64-unknown-linux-gnu-gcc \
                            -march=rv64gcv \
                            -O3 \
                            -ftree-vectorize \
                            -fopt-info-vec-optimized \
                            -o elf/riscv_vec_arrsum \
                            riscv_arrsum.c
 ```
 
 * To make riscv_mul_div_bitwise.c:
    * 32-bit 
 ```bash
/opt/riscv/bin/riscv64-unknown-linux-gnu-gcc -march=rv32im -mabi=ilp32 -nostdlib -e main -o elf/riscv_mul_div_bitwise_32 riscv_mul_div_bitwise.c
 ```

    * 64-bit 
 ```bash
 /opt/riscv/bin/riscv64-unknown-linux-gnu-gcc -o elf/riscv_mul_div_bitwise riscv_mul_div_bitwise.c
 ```
    
 * To make riscv_crypto_test.c:
 ```bash
  /opt/riscv/bin/riscv64-unknown-linux-gnu-gcc -march=rv64gc_zknd_zkne_zknh -o elf/riscv_crypto_64 riscv_crypto_test.c
```

 * To make riscv_vec_arith.c:
 ```bash
/opt/riscv/bin/riscv64-unknown-linux-gnu-gcc -O3 -march=rv64gcv -fopenmp-simd riscv_vec_arith.c -o elf/riscv_vec_arith -lm
 ```

 * To make riscv_bitmanip.c:
    * 32-bit (Bootlin toolchain)
    ```bash
    ./riscv32-ilp32d--musl--stable-2025.08-1/bin/riscv32-buildroot-linux-musl-gcc src/riscv_bitmanip.c -O3 -o riscv_bitmanip_32
    ```
    * 64-bit
 ```bash
/opt/riscv/bin/riscv64-unknown-linux-gnu-gcc -march=rv64gc_zbb_zbs -O2 src/riscv_bitmanip.c -o elf/riscv_bitmanip
 ```

 * To make riscv_compressed_push_pop.c:
 ```bash
 clang --target=riscv64 -march=rv64ima_zcmp -mabi=lp64 -O2 -ffreestanding -nostdlib -nostartfiles --gcc-toolchain=/opt/riscv --sysroot=/opt/riscv/sysroot -fuse-ld=lld -o elf/riscv_compressed_push_pop src/riscv_compressed_push_pop.c
 ```

 * To make riscv_float_rounding.c:
 ```bash
 /opt/riscv/bin/riscv64-unknown-linux-gnu-gcc  -march=rv64imafd_zfh_zfa -O2 src/riscv_float_rounding.c -o elf/riscv_float_rounding
 ```

  * To make riscv_jal_near.s:
   * 32-bit
 ```bash
llvm-mc -filetype=obj -triple=riscv32-unknown-elf -mattr=-relax src/riscv_jal_near.s  -o elf/riscv_relocs_jal_near_32
 ```
   * 64-bit
 ```bash
llvm-mc -filetype=obj -triple=riscv64-unknown-elf -mattr=-relax src/riscv_jal_near.s  -o elf/riscv_relocs_jal_near_64
 ```


 * To make riscv_jal_far.s:
   * 32-bit
 ```bash
llvm-mc -filetype=obj -triple=riscv32-unknown-elf -mattr=-relax src/riscv_jal_far.s  -o elf/riscv_relocs_jal_far_32
 ```
   * 64-bit
 ```bash
llvm-mc -filetype=obj -triple=riscv64-unknown-elf -mattr=-relax src/riscv_jal_far.s  -o elf/riscv_relocs_jal_far_64
 ```

 * To make riscv_add_relocs.s:
 ```bash
 llvm-mc -filetype=obj -triple=riscv32 -mattr=+relax src/riscv_add_relocs.s -o elf/riscv_relocs_add
 ```

 * To make riscv_hi_lo_is.s:
   * 32-bit
 ```bash
 llvm-mc -filetype=obj -triple=riscv32-unknown-elf src/riscv_hi_lo_is.s -o elf/riscv_relocs_hi_lo_is_32
 ```
   * 64-bit
 ```bash
 llvm-mc -filetype=obj -triple=riscv64-unknown-elf src/riscv_hi_lo_is.s -o elf/riscv_relocs_hi_lo_is_64
 ```
 
 * To make riscv_branch_near.c:
   * 32-bit
 ```bash
 clang -target riscv32 -c -O1 src/riscv_branch_near.c -o elf/riscv_relocs_branch_near_32
 ```
   * 64-bit
```bash
clang -target riscv64 -c -O1 src/riscv_branch_near.c -o elf/riscv_relocs_branch_near_64
```
 	
 * To make riscv_branch_far.c
   * 32-bit
```bash
clang -target riscv32 -c -O1 src/riscv_branch_far.c -o elf/riscv_relocs_branch_far_32
```
   * 64-bit
```bash
clang -target riscv64 -c -O1 src/riscv_branch_far.c -o elf/riscv_relocs_branch_far_64
```
 * To make riscv_relocations_relative_32_64.c:
   * 32-bit 
 ```bash
 clang -target riscv32 -c -O0 src/riscv_relocations_relative_32_64.c -o elf/riscv_relocs_32
 ```
   * 64-bit 
 ```bash
  /opt/riscv/bin/riscv64-unknown-linux-gnu-gcc -c src/riscv_relocations_relative_32_64.c -o elf/riscv_relocs_64
 ```
 
 * To make riscv_branch_compressed_near.c:
   * 32-bit:
   ```bash
   clang -target riscv32 -march=rv32ic -c -O1 src/riscv_branch_compressed_near.c -o elf/riscv_relocs_rvc_branch_near_32
   ```

   * 64-bit:
   ```bash
    clang -target riscv64 -march=rv64ic -c -O1 src/riscv_branch_compressed_near.c -o elf/riscv_relocs_rvc_branch_near_64
 
 * To make riscv_branch_compressed_far.c:
   * 32-bit:
   ```bash
   clang -target riscv32 -march=rv32ic -c -O1 src/riscv_branch_compressed_far.c -o elf/riscv_relocs_rvc_branch_far_32

   ```
   * 64-bit:
   ```bash
   clang -target riscv64 -march=rv64ic -c -O1 src/riscv_branch_compressed_far.c -o elf/riscv_relocs_rvc_branch_far_64
   ```
