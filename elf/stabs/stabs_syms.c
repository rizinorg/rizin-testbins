// Rich STABS test: types, globals, statics, params, locals.
// Compile: gcc-12 -gstabs -O0 -no-pie stabs_syms.c -o stabs_syms
#include <stdio.h>

typedef unsigned int uint_t;

struct point {
	int x;
	int y;
};

enum color { RED, GREEN, BLUE };

int g_counter = 5;
static char s_buffer[16];
struct point g_origin;

int add(int a, int b) {
	int sum = a + b;
	return sum;
}

long scale(struct point *p, uint_t factor) {
	long area = (long)p->x * p->y * factor;
	return area;
}

int main(void) {
	int local = add(3, 4);
	enum color c = GREEN;
	g_origin.x = local;
	printf("%d %d\n", local, (int)c);
	return 0;
}
