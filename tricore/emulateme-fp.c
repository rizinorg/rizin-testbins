#include <stdio.h>

int main(int argc, char **argv) {
	float a = 3.;
	float b = 38271.231;
	float c = 321732.13;
	float res_add = a + b;
	float res_sub = a - b;
	float res_m = a * b;
	float res_d = a / b;
	float res_madd = a * b + c;
	float res_msub = a * b - c;

	printf("%f %f %f %f %f %f\n", res_add, res_sub, res_m, res_d, res_madd, res_msub);
	return 0;
}
