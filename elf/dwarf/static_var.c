#include <stdio.h>
#include <string.h>
#include <stdint.h>

void fn1(int a, int b) {
	static char *bla = NULL;
	bla = strdup("qwe");
	printf("bla = %s %d\n", bla, a + b);
}

void fn2(void *q) {
	const static float qwe = 30.0;
	printf("qwe = %f %lx %lx\n", qwe, (uint64_t)q, *(uint64_t *)((uint64_t)&qwe + (uint64_t)q));
}

int main() {
	for (uint64_t i = 0; i < 1024; ++i) {
		fn1(i, i + 1);
		fn2((void *)i);
	}

	return 0;
}
