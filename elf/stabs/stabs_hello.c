// Test program for the STABS debug format parser.
// Compile with GCC <= 12 (last version supporting STABS):
//   gcc-12 -gstabs -O0 -no-pie stabs_hello.c -o stabs_hello
#include <stdio.h>

int add(int a, int b) {
	int r = a + b;
	return r;
}

int main(void) {
	int x = add(3, 4);
	printf("%d\n", x);
	return 0;
}
