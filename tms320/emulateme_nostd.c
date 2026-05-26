/**
 * \file
 * Simple crackme-like program, which decrypts a string in memory.
 * The decryption loop is implemented to not make any external calls, so it can be emulated nicely.
 * There are many "solutions" here, so this isn't really a good crackme.
 *
 * This doesn't use the C stdlib.
 *
 * For TI TMS320 DSPs (C2000, C5500, C54x, C6000), use the companion build script:
 *   python build_tms320_all.py emulateme.nostd.c
 *
 * Portability notes
 * -----------------
 * To compile on the broadest set of platforms (including the older TI C54x
 * and C5500 cl500/cl55 compilers which predate C99), this file:
 *   - uses an `unsigned long` (not `unsigned long long`) literal for the
 *     UART address, so it fits in TI's 32-bit `long`;
 *   - keeps the UART base address well within 32 bits, since the C54x
 *     "small" memory model uses 16-bit pointers and any too-large literal
 *     produces "integer constant is too large";
 *   - declares all variables at the start of their block (C89 / C90
 *     style), since the cl500 family rejects mixed declarations and
 *     statements;
 *   - does not redefine `size_t`; it uses its own `nstd_size_t` so the
 *     compiler's built-in `size_t` (which is `unsigned int` on TI 16-bit
 *     DSPs) is not shadowed;
 *   - keeps all character buffers as `char *` (not `uint8_t *`) so that
 *     string literals can be passed without per-pointer casts that newer
 *     compilers warn about; the XOR loop casts to `unsigned char` only
 *     where the arithmetic actually needs an unsigned 8-bit type.
 */

typedef unsigned char  nstd_uint8_t;
typedef unsigned short nstd_uint16_t;
typedef unsigned long  nstd_size_t;

/* UART write target. Chosen to fit in 32 bits so the literal is portable
 * to every TI TMS320 compiler. The exact value doesn't matter for the
 * emulation — it's just a marker address. */
static nstd_uint8_t *uart_address = (nstd_uint8_t *)(nstd_size_t)0x12345678UL;
static nstd_size_t uart_position = 0;

#define uart_write(s) uart_write_text((s), sizeof(s) - 1)

void uart_write_text(const char *text, nstd_size_t len) {
	nstd_size_t i;
	for (i = 0; i < len; i++) {
		uart_address[uart_position] = (nstd_uint8_t)text[i];
		uart_position++;
	}
}

void uart_write_hex(nstd_uint8_t value) {
	const char *hex = "0123456789abcdef";
	nstd_uint8_t high = (nstd_uint8_t)((value >> 4) & 0x0Fu);
	nstd_uint8_t low  = (nstd_uint8_t)(value & 0x0Fu);
	uart_address[uart_position]     = (nstd_uint8_t)hex[high];
	uart_address[uart_position + 1] = (nstd_uint8_t)hex[low];
	uart_position += 2;
}

nstd_size_t c_strlen(const char *s) {
	nstd_size_t len = 0;
	for (; *s; ++len) ++s;
	return len;
}

#define LEN 0x10
#define PARITY_REF 0x58

static nstd_uint8_t seckrit[LEN + 1] = {
	0x51, 0x53, 0x4d, 0x77, 0x58, 0x14, 0x51, 0x5f,
	0x45, 0x6c, 0x17, 0x7f, 0x6e, 0x78, 0x7f, 0x1c,
	0x00
};

int decrypt(const char *key) {
	nstd_uint8_t parity = 0;
	nstd_size_t i;
	for (i = 0; i < LEN; i++) {
		seckrit[i] = (nstd_uint8_t)(seckrit[i] ^ (nstd_uint8_t)key[i]);
		parity = (nstd_uint8_t)(parity ^ seckrit[i]);
	}
	if (parity != PARITY_REF) {
		return 0;
	}
	for (i = 0; i < LEN; i++) {
		seckrit[i] = (nstd_uint8_t)(seckrit[i] ^ parity);
	}
	return 1;
}

int main(int argc, const char *argv[]) {
	const char *key;
	if (argc != 2) {
		uart_write("usage: emulateme [key]\n");
		return 1;
	}
	key = argv[1];
	if (c_strlen(key) != LEN) {
		uart_write("wrong length.\n");
		return 1;
	}
	if (!decrypt(key)) {
		uart_write("wrong key.\n");
		return 1;
	}
	uart_write("Decrypted: ");
	uart_write_text((const char *)seckrit, LEN);
	uart_write("\n");
	return 0;
}
