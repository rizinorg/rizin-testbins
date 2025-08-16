# egdb -x sparc64_insn_openbsd.gdb ./sparc64_insn_openbsd.bin

set pagination off
set trace-commands on
b *(run_all_tests + 120)
r
disas

while ($pc < (run_all_tests + 212))
	info all-registers
	disas $pc,$pc+4
	si
end

info all-registers

quit
