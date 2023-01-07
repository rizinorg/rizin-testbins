all:
	as -o hello-arm32.o -mlittle-endian hello-arm32.s
	ld -o hello-arm32 hello-arm32.o -lc

.PHONY: calculate-macos-arm64
calculate-macos-arm64: ../mach0/calculate-macos-arm64
../mach0/calculate-macos-arm64: calculate.c
	clang -O0 calculate.c -o $@

../mach0/calculate-macos-x86_64: calculate.c
	clang -O0 calculate.c -target x86_64-apple-macos10.12 -o $@ # built on Monterey

../mach0/calculate-macos-x86_64-legacy: calculate.c
	clang -O0 calculate.c -arch x86_64 -o $@ # built on Snow Leopard

../mach0/calculate-macos-i386: calculate.c
	clang -O0 calculate.c -arch i386 -o $@ # built on Snow Leopard

../mach0/calculate-macos-fat-arm64-x86_64: ../mach0/calculate-macos-arm64 ../mach0/calculate-macos-x86_64
	lipo -create -output $@ $^

../mach0/calculate-macos-fat-i386-x86_64: ../mach0/calculate-macos-i386 ../mach0/calculate-macos-x86_64-legacy
	lipo -create -output $@ $^

.PHONY: mapper-macos-arm64
mapper-macos-arm64: ../mach0/mapper-macos-arm64
../mach0/mapper-macos-arm64: mapper.c
	clang -O0 mapper.c -o ../mach0/mapper-macos-arm64

../elf/vars-x86_64-bp: vars.c
	gcc -fno-omit-frame-pointer -O0 -g -o $@ vars.c

../elf/vars-x86_64-sp: vars.c
	gcc -fomit-frame-pointer -O0 -g -o $@ vars.c

../elf/vars-complex-x86_64-bp: vars.c
	gcc -fno-omit-frame-pointer -O0 -o $@ vars-complex.c

../elf/vars-complex-x86_64-sp: vars.c
	gcc -fomit-frame-pointer -O0 -o $@ vars-complex.c
