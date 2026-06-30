# TMS320C2x (legacy) test fixtures

Fixtures for Rizin's legacy single-accumulator TMS320C2x support
(`asm.arch=tms320`, `analysis.cpu=c2x`; COFF autodetect via target id
`0x0092`).

## How these are built

The TI **C2000** Code Generation Tools (`cl2000`/`asm2000`) target **C28x**, a
different instruction set, and **binutils** has no legacy C2x target, so these
are built with <https://codeberg.org/xvilka/tms320-rs>:

```
tms320cc --c2x -S hello_c2x.c > hello_c2x.asm
tms320ld --c2x --coff-version 0 --coff hello_c2x.ticoff0.coff hello_c2x.asm
tms320ld --c2x --coff-version 2 --coff hello_c2x.ticoff2.coff hello_c2x.asm
```

## Files

* `hello_c2x.c` — the source both objects are compiled from.
* `hello_c2x.ticoff0.coff` — original TI COFF: the target id `0x0092` is the
  file magic.
* `hello_c2x.ticoff2.coff` — COFF2: magic `0x00c2` plus a separate target id
  `0x0092`.

## TMS320C5x

The C5x (C50/C51/C53) is an upward-compatible superset of the C2x and shares
the legacy first-generation COFF target id (`0x0092`), so the same fixtures also
exercise the `c5x` CPU when opened with `-c c5x`:

```
rizin -a tms320 -c c5x hello_c2x.ticoff0.coff
```
