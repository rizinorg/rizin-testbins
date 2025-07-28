Build script/instructions in build.sh.

It is a little hard to come by Sparc libc for cross compiling.
Hence everything is `nostdlib`.

### Toolchains

Sparc32: https://github.com/mcayland/sparc-linux-cross/

### Expected rz-tracetest results

**Command**

(ignore FDIV because inf (1/0) is differently defined in QEMU than RzIL.

```
../rz-tracetest/rz-tracetest/build/rz-tracetest -s fdiv.+ -v -b ~/repos/qemu/sparc64_insn_all.bin.trace
```

**Binary**: `sparc64_insn_all.bin`

**Expected results**

| Result               | n   | Percent  |
|----------------------|-----|----------|
|              success | 426 |   98.84% |
|              skipped | 3   |    0.70% |
|           invalid op | 0   |    0.00% |
|           invalid il | 0   |    0.00% |
|     vm runtime error | 0   |    0.00% |
|          misexecuted | 0   |    0.00% |
|             unlifted | 2   |    0.46% |
|     unknown failures | 0   |    0.00% |

Unique instructions emulated: 119
