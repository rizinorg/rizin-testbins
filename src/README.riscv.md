RISC-V Requirements
-------------------

 * Download and make the GNU toolchain from https://github.com/riscv-collab/riscv-gnu-toolchain, follow the instructions to install it, the commit hash used to build the binaries committed to this repo is 357800bf2c5115ade5bc33f69af79c641db63cc8

 * To make riscv_arrsum.c: 
 ```bash
/opt/riscv/bin/riscv64-unknown-linux-gnu-gcc \
                            -march=rv64gcv \
                            -O3 \
                            -ftree-vectorize \
                            -fopt-info-vec-optimized \
                            -o riscv_vec_arrsum \
                            riscv_arrsum.c
 ```
 
 * To make riscv_mul_div_bitwise.c:
    * 32-bit 
 ```bash
/opt/riscv/bin/riscv64-unknown-linux-gnu-gcc -march=rv32im -mabi=ilp32 -nostdlib -e main -o riscv_mul_div_bitwise_32 riscv_mul_div_bitwise.c
 ```

    * 64-bit 
 ```bash
 /opt/riscv/bin/riscv64-unknown-linux-gnu-gcc -o riscv_mul_div_bitwise riscv_mul_div_bitwise.c
 ```
    
 * To make riscv_crypto_test.c:
 ```bash
  /opt/riscv/bin/riscv64-unknown-linux-gnu-gcc -march=rv64gc_zknd_zkne_zknh -o riscv_crypto_64 riscv_crypto_test.c
```

 * To make riscv_vec_arith.c:
 ```bash
/opt/riscv/bin/riscv64-unknown-linux-gnu-gcc -O3 -march=rv64gcv -fopenmp-simd riscv_vec_arith.c -o riscv_vec_arith -lm
 ```

 * To make riscv_bitmanip.c:
 ```bash
/opt/riscv/bin/riscv64-unknown-linux-gnu-gcc -march=rv64gc_zbb_zbs -O2 src/riscv_bitmanip.c -o riscv_bitmanip
 ```

 * To make riscv_compressed_push_pop.c:
 ```bash
 clang --target=riscv64 -march=rv64ima_zcmp -mabi=lp64 -O2 -ffreestanding -nostdlib -nostartfiles --gcc-toolchain=/opt/riscv --sysroot=/opt/riscv/sysroot -fuse-ld=lld -o riscv_compressed_push_pop src/riscv_compressed_push_pop.c
 ```

 * To make riscv_float_rounding.c:
 ```bash
 /opt/riscv/bin/riscv64-unknown-linux-gnu-gcc  -march=rv64imafd_zfh_zfa -O2 src/riscv_float_rounding.c -o riscv_float_rounding
 ```

  * To make riscv_jal_near.s:
   * 32-bit
 ```bash
llvm-mc -filetype=obj -triple=riscv32-unknown-elf -mattr=-relax src/riscv_jal_near.s  -o riscv_relocs_jal_near_32
 ```
   * 64-bit
 ```bash
llvm-mc -filetype=obj -triple=riscv64-unknown-elf -mattr=-relax src/riscv_jal_near.s  -o riscv_relocs_jal_near_64
 ```


 * To make riscv_jal_far.s:
   * 32-bit
 ```bash
llvm-mc -filetype=obj -triple=riscv32-unknown-elf -mattr=-relax src/riscv_jal_far.s  -o riscv_relocs_jal_far_32
 ```
   * 64-bit
 ```bash
llvm-mc -filetype=obj -triple=riscv64-unknown-elf -mattr=-relax src/riscv_jal_far.s  -o riscv_relocs_jal_far_64
 ```

 * To make riscv_add_relocs.s:
 ```bash
 llvm-mc -filetype=obj -triple=riscv32 -mattr=+relax src/riscv_add_relocs.s -o riscv_relocs_add
 ```

 * To make riscv_hi_lo_is.s:
   * 32-bit
 ```bash
 llvm-mc -filetype=obj -triple=riscv32-unknown-elf src/riscv_hi_lo_is.s -o riscv_relocs_hi_lo_is_32
 ```
   * 64-bit
 ```bash
 llvm-mc -filetype=obj -triple=riscv64-unknown-elf src/riscv_hi_lo_is.s -o riscv_relocs_hi_lo_is_64
 ```

