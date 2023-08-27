#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

struct Some {
	int a;
	char b[6];
	float c;
	void *qwe;
};

typedef struct Some some_t;

bool fn1(int a, char *g, double q, struct Some *gg, some_t **out) {
	if (!gg || !out) {
		return false;
	}
	*out = (some_t *)malloc(sizeof(some_t));
	(*out)->a = a;
	strncpy((*out)->b, g, 5);
	(*out)->c = (float)q;
	(*out)->qwe = gg;
	return true;
}

some_t *new_some() {
	struct Some *n = (some_t *)malloc(sizeof(struct Some));
	memset(n, 0, sizeof(*n));
	return n;
}

int main(int argc, char **argv) {
	float a, b;
	a = 5.4;
	b = 0.000008;
	double c = a - b + a * b;
	printf("a = %f b = %f c = %e\n", a, b, c);
	some_t *s = new_some();
	if (!s) {
		return -1;
	}
	struct Some *gg = new_some();
	if (!fn1((int)a, strdup("blabla"), c, gg, &s)) {
		return -1;
	}

	printf("Some.a = %d Some.b = %c%c%c%c%c%c Some.c = %f\n", s->a,
			s->b[0], s->b[1], s->b[2], s->b[3], s->b[4], s->b[5], s->c);
	return 0;
}
