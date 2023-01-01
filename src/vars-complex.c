
#include <stdio.h>

void leaffunc(int *a, int *b, int *c, int *d)
{
}

int varfunc(int a)
{
	int lightbulb;
	int sun;
	int last;
	int chance;

	if (a == 1) {
		lightbulb = 1;
		sun = 2;
		last = 3;
		chance = 4;
	} else if (a == 2) {
		lightbulb = 9;
		sun = 8;
		last = 7;
		chance = 6;
	} else {
		lightbulb = 42;
		sun = 42;
		last = 42;
		chance = 42;
	}

	leaffunc(&lightbulb, &sun, &last, &chance);

	sun = chance;
	return lightbulb;
}

int main(int argc, const char *argv[])
{
	printf("res: %d\n", varfunc(0));
}
