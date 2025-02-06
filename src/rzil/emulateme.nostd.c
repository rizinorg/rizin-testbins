/**
 * \file
 * Simple crackme-like program, which decrypts a string in memory.
 * The decryption loop is implemented to not make any external calls, so it can be emulated nicely.
 * There are many "solutions" here, so this isn't really a good crackme.
 * 
 * This doesn't use the C stdlib.
 * mips64-elf-gcc -nostdlib -mabi=32 -S -march=mips1 -o elf/emulateme.nostd.mips1.S src/rzil/emulateme.nostd.c
 * mips64-elf-gcc -nostdlib -mabi=32 -S -march=mips2 -o elf/emulateme.nostd.mips2.S src/rzil/emulateme.nostd.c
 * mips64-elf-gcc -nostdlib -mabi=32 -S -march=mips3 -o elf/emulateme.nostd.mips3.S src/rzil/emulateme.nostd.c
 * mips64-elf-gcc -nostdlib -mabi=32 -S -march=mips32 -o elf/emulateme.nostd.mips32.S src/rzil/emulateme.nostd.c
 * mips64-elf-gcc -nostdlib -mabi=32 -S -march=mips32r2 -o elf/emulateme.nostd.mips32r2.S src/rzil/emulateme.nostd.c
 * mips64-elf-gcc -nostdlib -mabi=32 -S -march=mips32r3 -o elf/emulateme.nostd.mips32r3.S src/rzil/emulateme.nostd.c
 * mips64-elf-gcc -nostdlib -mabi=32 -S -march=mips32r5 -o elf/emulateme.nostd.mips32r5.S src/rzil/emulateme.nostd.c
 * mips64-elf-gcc -nostdlib -S -march=mips4 -o elf/emulateme.nostd.mips4.S src/rzil/emulateme.nostd.c
 * mips64-elf-gcc -nostdlib -S -march=mips64 -o elf/emulateme.nostd.mips64.S src/rzil/emulateme.nostd.c
 * mips64-elf-gcc -nostdlib -S -march=mips64r2 -o elf/emulateme.nostd.mips64r2.S src/rzil/emulateme.nostd.c
 * mips64-elf-gcc -nostdlib -S -march=mips64r3 -o elf/emulateme.nostd.mips64r3.S src/rzil/emulateme.nostd.c
 * mips64-elf-gcc -nostdlib -S -march=mips64r5 -o elf/emulateme.nostd.mips64r5.S src/rzil/emulateme.nostd.c
 * mips64-elf-gcc -nostdlib -S -march=mips64r6 -o elf/emulateme.nostd.mips64r6.S src/rzil/emulateme.nostd.c
 * mips64-elf-gcc -nostdlib -S -march=octeon -o elf/emulateme.nostd.octeon.S src/rzil/emulateme.nostd.c
 * mips64-elf-gcc -nostdlib -S -march=octeon -o elf/emulateme.nostd.octeon.S src/rzil/emulateme.nostd.c
 * mips64-elf-gcc -nostdlib -S -march=octeon2 -o elf/emulateme.nostd.octeon2.S src/rzil/emulateme.nostd.c
 * mips64-elf-gcc -nostdlib -S -march=octeon3 -o elf/emulateme.nostd.octeon3.S src/rzil/emulateme.nostd.c
 * mips64-elf-gcc -nostdlib -S -march=orion -o elf/emulateme.nostd.orion.S src/rzil/emulateme.nostd.c
 * mips64-elf-gcc -nostdlib -mabi=32 -S -march=p5600 -o elf/emulateme.nostd.p5600.S src/rzil/emulateme.nostd.c
 */

typedef unsigned char  uint8_t;
typedef unsigned short uint16_t;
typedef unsigned long long size_t;

// this is an address where we write a bunch of data.
static uint8_t *uart_address = (uint8_t *)(void *)(size_t)0x800012345678ull;
static size_t uart_position = 0;

#define uart_write(s) uart_write_text(s, sizeof(s) - 1)

void uart_write_text(const char *text, size_t len) {
	for (size_t i = 0; i < len; i++) {
		uart_address[uart_position] = text[i];
		uart_position++;
	}
}

void uart_write_hex(uint8_t value) {
	const char *hex = "0123456789abcdef";
	uint8_t high = (value >> 4) & 0xf;
	uint8_t low = value & 0xf;
	uart_address[uart_position] = hex[high];
	uart_address[uart_position + 1] = hex[low];
	uart_position += 2;
}

size_t c_strlen(const char *s) {
	size_t len = 0;
	for (; *s; ++len) ++s;
	return len;
}

#define LEN 0x10
#define PARITY_REF 0x58

static uint8_t seckrit[LEN + 1] = { 0x51, 0x53, 0x4d, 0x77, 0x58, 0x14, 0x51, 0x5f, 0x45, 0x6c, 0x17, 0x7f, 0x6e, 0x78, 0x7f, 0x1c };

int decrypt(const char *key) {
	uint8_t parity = 0;
	for (size_t i = 0; i < LEN; i++) {
		seckrit[i] ^= (uint8_t)key[i];
		parity ^= seckrit[i];
	}
	if (parity != PARITY_REF) {
		return 0;
	}
	for (size_t i = 0; i < LEN; i++) {
		seckrit[i] ^= parity;
	}
	return 1;
}

int main(int argc, const char *argv[]) {
	if (argc != 2) {
		uart_write("usage: emulateme [key]\n");
		return 1;
	}
	const char *key = argv[1];
	if (c_strlen(key) != LEN) {
		uart_write("wrong length.\n");
		return 1;
	}
	if (!decrypt(key)) {
		uart_write("wrong key.\n");
		return 1;
	}
	uart_write("Decrypted: ");
	uart_write_text(seckrit, LEN);
	uart_write("\n");
	return 0;
}
