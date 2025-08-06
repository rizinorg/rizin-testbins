Build script/instructions in build.sh.

It is a little hard to come by Sparc libc for cross compiling.
Hence everything is `nostdlib`.

### Toolchains

Sparc32: https://github.com/mcayland/sparc-linux-cross/

### Expected rz-tracetest results

**Note about SAVE and RESTORE**

The content of the local registers after SAVE or RESTORE varies.
With traps the content is undefined, without traps it can be the content
of the previous window or 0.

Same for the out registers after SAVE.
In Rizin they are always set to 0 (no traps are modeled),
QEMU doesn't and models traps.
So the trace and Rizin will likely mismatch.
But only if an input register mismatches the test failed.

**Command**

```
 ../rz-tracetest/rz-tracetest/build/rz-tracetest -s "((f[dqixs]to|fdiv). (f0|f16|f32).+)|(.+asr19.+)||(rd fprs, i0)" -b  -v ~/repos/qemu/sparc64_insn_all.bin.trace
 ../rz-tracetest/rz-tracetest/build/rz-tracetest -e -s fdiv.+ -b ~/repos/qemu/sparc64_insn_jmp.bin.trace
```

The skipped instructions have `0` or other edge case float inputs (infinity, NaN etc.).
These tests fail, because Rizin's float implementation doesn't match the QEMU one.
And the output differs.
For example:
Our implementation represents zero with all exponent bits set.
QEMU sets all bits to `0`. Although semantically both are correct, it still leads to a mismatch.

`rd fprs, i0` is skipped because QEMU sets more than 3 bits (more than the ISA defines).

**Binary**: `sparc64_insn_all.bin`

**Expected results (or better)**

--------------------------------------
              success: 1767    96.98%
              skipped: 55       3.02%
           invalid op: 0        0.00%
           invalid il: 0        0.00%
     vm runtime error: 0        0.00%
          misexecuted: 0        0.00%
             unlifted: 0        0.00%
     unknown failures: 0        0.00%

Unique instructions emulated: 150

**Binary**: `sparc64_insn_jmp.bin`

**Expected results (or better)**

--------------------------------------
              success: 2015    99.90%
              skipped: 2        0.10%
           invalid op: 0        0.00%
           invalid il: 0        0.00%
     vm runtime error: 0        0.00%
          misexecuted: 0        0.00%
             unlifted: 0        0.00%
     unknown failures: 0        0.00%

Unique instructions emulated: 28


**Binary**: `sparc32_insn_jmp.bin`


**Command**

```
../rz-tracetest/rz-tracetest/build/rz-tracetest -s "fdiv.+" -b ~/repos/qemu/sparc32_insn_jmp.bin.trace
```

Compare frames...
Frames: 367 Done: 100.00%

--------------------------------------
              success: 364     99.18%
              skipped: 3        0.82%
           invalid op: 0        0.00%
           invalid il: 0        0.00%
     vm runtime error: 0        0.00%
          misexecuted: 0        0.00%
             unlifted: 0        0.00%
     unknown failures: 0        0.00%

Unique instructions emulated: 15
