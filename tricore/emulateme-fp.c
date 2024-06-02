#include <stdio.h>
#include <string.h>

static char ress[6][128] = {0};


int main(int argc, char **argv) {
        float a = 3.;
		float b = 38271.231;
		float c = 0x2p64;
		double res = 0;
		res = a + b;
        sprintf(ress[0], "%f + %f = %e\n", a, b, res);
		res = a - b;
        sprintf(ress[1], "%f - %f = %e\n", a, b, res);
		res = a * b;
        sprintf(ress[2], "%f * %f = %e\n", a, b, res);
		res = a / b;
        sprintf(ress[3], "%f / %f = %e\n", a, b, res);
		res = a * b + c;
        sprintf(ress[4], "%f * %f + %f = %e\n", a, b, c, res);
		res = a * b - c;
        sprintf(ress[5], "%f * %f - %f = %e\n", a, b, c, res);

		for(int i = 0; i<6; ++i){
			printf("%s", ress[i]);
		}
        return 0;
}
