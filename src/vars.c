
#include <stdio.h>

void leaffunc()
{
}

int varfunc()
{
	int lightbulb;
	int sun;
	int last;
	int chance;

	lightbulb = 1;
	sun = 2;
	last = 3;
	chance = 4;

	leaffunc();

	sun = chance;
	return lightbulb;
}

int main(int argc, const char *argv[])
{
	printf("res: %d\n", varfunc());
}
