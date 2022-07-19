The `.stats` files should be formatted like the following:

```
<enum_id>\t[xe]\t[xr]
```

`e` - implemented in ESIL
`r` - implemented in RZIL
`x` - not implemented


Code snipped added to Rizin was:

```c
if (/* Instruction correctly disassembled */) {
	printf("%d\t", insn->id);
	if (rz_strbuf_is_empty(&op->esil)) {
		printf("x\t");
	} else {
		printf("e\t");
	}
	if (op->il_op) {
		printf("r\n");
  } else {
		printf("x\n");
	}
}
```

`gen_stats.py` Writes the stdout into `.stats` files.
