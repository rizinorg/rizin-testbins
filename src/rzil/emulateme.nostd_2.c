// Compile this this with gcc --nostdlib -O0
// Most compilers should have an --nostdlib option.

#define LEN 0x10

typedef unsigned char uint8_t;

static const uint8_t parity_ref = 0x58;
static char seckrit[LEN + 1] = { 0x51, 0x53, 0x4d, 0x77, 0x58, 0x14, 0x51, 0x5f, 0x45, 0x6c, 0x17, 0x7f, 0x6e, 0x78, 0x7f, 0x1c };

uint8_t decrypt(const char *key) {
	uint8_t parity = 0;
	for (uint8_t i = 0; i < LEN; i++) {
		seckrit[i] ^= key[i];
		parity ^= seckrit[i];
	}
	if (parity != parity_ref) {
		return 0;
	}
	for (uint8_t i = 0; i < LEN; i++) {
		seckrit[i] ^= parity;
	}
	return 1;
}

int _start(int argc, const char *argv[]) {
	const char *key = "AnyColourYouLike";
	return decrypt(key) != 0;
}
