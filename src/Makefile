all:
	as -o hello-arm32.o -mlittle-endian hello-arm32.s
	ld -o hello-arm32 hello-arm32.o -lc

.PHONY: calculate-macos-arm64
calculate-macos-arm64: ../mach0/calculate-macos-arm64
../mach0/calculate-macos-arm64: calculate.c
	clang -O0 calculate.c -o ../mach0/calculate-macos-arm64
