/**
 * \file
 * Simple crackme-like program, which decrypts a string in memory.
 * The decryption loop is implemented to not make any external calls, so it can be emulated nicely.
 * There are many "solutions" here, so this isn't really a good crackme.
 */

#include <stdio.h>
#include <string.h>
#include <stdint.h>

#define LEN 0x10

uint8_t parity_ref = 0x58;
char seckrit[LEN + 1] = { 0x51, 0x53, 0x4d, 0x77, 0x58, 0x14, 0x51, 0x5f, 0x45, 0x6c, 0x17, 0x7f, 0x6e, 0x78, 0x7f, 0x1c };

int decrypt(const char *key) {
	uint8_t parity = 0;
	for (size_t i = 0; i < LEN; i++) {
		seckrit[i] ^= key[i];
		parity ^= seckrit[i];
	}
	if (parity != parity_ref) {
		return 0;
	}
	for (size_t i = 0; i < LEN; i++) {
		seckrit[i] ^= parity;
	}
	return 1;
}

#if INVERSE

int main() {
	const char *key =    "AnyColourYouLike";
	const char *result = "Hello from RzIL!";
	for (uint16_t parity = 0; parity < 0x100; parity++) {
		parity_ref = (uint8_t)parity;
		uint8_t a[LEN];
		for (size_t i = 0; i < LEN; i++) {
			a[i] = result[i] ^ parity_ref ^ key[i];
			seckrit[i] = a[i];
		}
		if (decrypt(key)) {
			printf("parity: %#02x\n", (unsigned int)parity_ref);
			printf("{ ");
			for (size_t i = 0; i < LEN; i++) {
				if (i) {
					printf(", ");
				}
				printf("%#02x", (unsigned int)a[i]);
			}
			printf(" };\n");
		}
	}
	return 0;
}

#else

int main(int argc, const char *argv[]) {
	if (argc != 2) {
		printf("usage: %s [key]\n", argv[0]);
		return 1;
	}
	const char *key = argv[1];
	if (strlen(key) != LEN) {
		printf("wrong length.\n");
		return 1;
	}
	if (!decrypt(key)) {
		printf("wrong key.\n");
		return 1;
	}
	printf("Decrypted: %s\n", seckrit);
	return 0;
}

#endif
