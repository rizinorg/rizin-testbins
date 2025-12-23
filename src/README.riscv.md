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
 
 * To make mul_div_bitwise.c:
    * 32-bit 
 ```bash
/opt/riscv/bin/riscv64-unknown-linux-gnu-gcc -march=rv32im -mabi=ilp32 -nostdlib -e main -o riscv_mul_div_bitwise_32.o mul_div_bitwise.c
 ```

   * 64-bit 
 ```bash
 /opt/riscv/bin/riscv64-unknown-linux-gnu-gcc -o riscv_mul_div_bitwise.o mul_div_bitwise.c
 ```
    
 * To make riscv_crypto_test.c:
 ```bash
  /opt/riscv/bin/riscv64-unknown-linux-gnu-gcc -march=rv64gc_zknd_zkne_zknh -o riscv_crypto_64 riscv_crypto_test.c
```

 * To make riscv_vec_arith
 ```bash
/opt/riscv/bin/riscv64-unknown-linux-gnu-gcc -O3 -march=rv64gcv -fopenmp-simd riscv_vec_arith.c -o riscv_vec_arith -lm
 ```