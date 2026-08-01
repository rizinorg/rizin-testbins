
CC_x86_64=x86_64-linux-gnu-gcc
CC_hexagon=$(HEXAGON_SDK_TOOLS_BIN)/clang
CC_sparc64=sparc64-linux-gnu-gcc
CC_arm=arm-none-eabi-gcc
CC_mips64=mips64-linux-gnu-gcc

ARCH=x86_64
CC=$(CC_$(ARCH))
CFLAGS=-O0

TARGETS=indirect_call

.PHONY: all
all: $(foreach target,$(TARGETS),$(ARCH)_$(target).o)

CLEAN_TARGETS=$(foreach target,$(TARGETS),clean_$(target))
.PHONY: clean
clean: $(CLEAN_TARGETS)

$(ARCH)_%.o: src/%.c
	$(CC) --static -c $(CFLAGS) -o $@ $<

clean_%:
	rm -fv $(ARCH)_$*.o

ARCH_TARGET=all

.PHONY: all_archs
all_archs:
	make $(ARCH_TARGET) # default: ARCH=x86_64 CFLAGS=-O0
	make $(ARCH_TARGET) ARCH=hexagon CFLAGS=-O0
	make $(ARCH_TARGET) ARCH=sparc64 CFLAGS=-O0
	make $(ARCH_TARGET) ARCH=arm CFLAGS=-O0
	make $(ARCH_TARGET) ARCH=mips64 CFLAGS=-O0

.PHONY: all_archs_clean
all_archs_clean:
	make all_archs ARCH_TARGET=clean
