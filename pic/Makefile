
emulateme.%.elf: emulateme.tinymem.c
	xc8-cc -O0 -mcpu=$(notdir $*) -o $@ $<
	rm *.o *.sdb *.sym *.lst *.rlf *.s *.d *.p1 *.cmf *.hxl
