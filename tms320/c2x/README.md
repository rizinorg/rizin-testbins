# TMS320C2x (legacy) test fixtures

Fixtures for Rizin's legacy single-accumulator TMS320C2x support
(`asm.arch=tms320`, `analysis.cpu=c2x`; COFF autodetect via target id
`0x0092`).

## Why these are hand-built

Unlike the other TMS320 targets in this directory (`c54x`, `c55x`, `c28x`,
`c6x` — all compiled from `emulateme_nostd.c` by the TI CGT tools, see
`../compilation_cmds_ccsv5.txt`), the legacy C2x has **no available
assembler**:

* The TI **C2000** Code Generation Tools (`cl2000`/`asm2000`) target **C28x**,
  not the legacy single-accumulator C2x — a different instruction set.
* **binutils** ships `tic54x`, `tic4x` and `tic30` GAS targets, but nothing
  for the legacy C2x/C25.

So C2x machine code is produced by hand from the published instruction
encodings (the opcode bit patterns match MAME's tested `tms32025` disassembler).
The disassembly/IL expectations live in the Rizin tree, not here:

* `test/db/asm/tms320_c2x_16` — disassembly + RzIL vectors (`d "..." <hex>`).
* `test/db/analysis/tms320.c2x_16` — op classification, reg profile, COFF open.

## Files

* `hello_c2x.ticoff2.coff` — a minimal TI COFF2 object (`nop; zac; lack #1;
  ret`) with file magic `0x00C2` and target id `0x0092` (the first-generation
  fixed-point id shared by the C1x/C2x/C5x tools), used by the COFF-open test.
* `make_c2x_coff.py` — regenerates the COFF object:
  `python3 make_c2x_coff.py hello_c2x.ticoff2.coff`

## Verification status

These fixtures were prepared against the encoding reference and the COFF format,
but had not been round-tripped through a built `rz-asm`/loader at authoring
time. The COFF `target_id 0x0092` mapping and the F8..FF branch opcode tail in
particular should be confirmed against real C2x objects before being relied on.

## TMS320C5x

The C5x (C50/C51/C53) is an upward-compatible superset of the C2x and shares
the legacy first-generation COFF target id (`0x0092`), so the same fixture also
exercises the `c5x` CPU when opened with `-c c5x`:

```
rizin -a tms320 -c c5x hello_c2x.ticoff2.coff
```

Rizin decodes the C5x via the shared C2x core (which covers the C2x-compatible
instruction set that forms the bulk of real C5x code) and exposes the full C5x
register model (ACCB, PMST, TREG1/2, the circular-buffer pointers, BMAR, ...).
Real C5x objects (e.g. TMS320C5x DSK `.obj`/`.out` images) open and report
`arch=tms320, cpu=c2x, bits=16` and can be re-opened as `c5x`.
