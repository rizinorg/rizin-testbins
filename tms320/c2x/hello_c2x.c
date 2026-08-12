/* Minimal C2x program for the COFF loader fixture. */
int total;

int add(int a, int b) {
	return a + b;
}

int main(void) {
	total = add(1, 2);
	return total;
}
