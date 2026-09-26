#define LEN 0x10

static const unsigned char parity_ref = 0x58;
static char seckrit[LEN + 1] = { 0x51, 0x53, 0x4d, 0x77, 0x58, 0x14, 0x51, 0x5f, 0x45, 0x6c, 0x17, 0x7f, 0x6e, 0x78, 0x7f, 0x1c };

int decrypt(const char *key) {
	unsigned char parity = 0;
	for (int i = 0; i < LEN; i++) {
		seckrit[i] ^= key[i];
		parity ^= seckrit[i];
	}
	if (parity != parity_ref) {
		return 0;
	}
	for (int i = 0; i < LEN; i++) {
		seckrit[i] ^= parity;
	}
	return 1;
}

int main(int argc, const char *argv[]) {
	const char *key = "AnyColourYouLike";
	decrypt(key);
	return 0;
}
