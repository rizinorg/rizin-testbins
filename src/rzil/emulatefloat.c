/**
 * \file
 * Simple crackme-like program, which decrypts a string in memory, but uses floating point operations to do so.
 * The decryption loop is implemented to not make any external calls, so it can be emulated nicely.
 * See emulateme.c for the the non-floating point instruction counterpart.
 */

#include <stdio.h>
#include <string.h>
#include <stdint.h>

#define LEN 0x10

char seckrit[LEN + 1] = { 0xe, 0xf, 0x3, 0xd, 0x1a, 0x6d, 0xf, 0x1a, 0xa, 0x4, 0x62, 0x34, 0xf, 0x3d, 0x29, 0x52 };

/* somewhat randomly generated numbers */
const double secondary_key[LEN] = { 8.99833709175345e-10, -0.3846771547676213, 2112271980.5789769, -2496373494.813322, 0.8743511441461778, -0.7300930961653576, -9705324222.854767, 0.5248033950772337, -712026204.430174, -0.04255897245519691, -8.307435687809127e-10, -0.22546719870688525, -0.8951827579358256, -8272556172.013981, 8.200744604338547e-10, 0.7577483159942799 };

int hash(double f) {
	/* Get f to be >= 1 or >= -1, and then square it. */
	if (f < 1 && f > -1) {
		f = 1.0 / f;
	}
	f *= f;

	/* Get the last byte of the rounded integer. */
	int h = (int)f;
	h &= 0xff;
	return h;
}

void decrypt(const char *key) {
	for (size_t i = 0; i < LEN; i++) {
		double key_i = secondary_key[i];
		int pad = hash(key_i);
		seckrit[i] ^= (pad ^ key[i]);
	}
}

#if INVERSE

int main() {
	const char *key = "FloatLikeAButter";
	const char *result = "Hello from RzIL!";

	printf("char seckrit[LEN + 1] = { ");
	for (size_t i = 0; i < LEN; i++) {
		double key_i = secondary_key[i];
		int pad = hash(key_i);

		printf("%#02x, ", pad ^ key[i] ^ result[i]);
	}
	printf("};\n");

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
	decrypt(key);
	printf("Decrypted: %s\n", seckrit);
	return 0;
}

#endif
