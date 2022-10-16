// Example program for macOS that creates some memory maps at predictable
// addresses and writes and reads some data from it, for testing io during debug.

#include <stdio.h>
#include <unistd.h>
#include <sys/mman.h>
#include <string.h>

#define PAGESZ 0x4000

void *base = (void *)0x0000010000000000ULL;

void continue_until_here() {
	printf("Rizin!\n");
}

int main() {
	printf("Hello,\n");

	// First map
	size_t mapsz = PAGESZ;
	void *r = mmap(base, mapsz, PROT_READ | PROT_WRITE, MAP_FIXED | MAP_ANON | MAP_SHARED, -1, 0);
	if (r == MAP_FAILED) {
		perror("mapper mmap");
		return 1;
	}
	strcpy(r, "This is my map");
	const char *end = "This is the end, you know. Lady, the plans we had went all wrong. We ain't nothing but fight and shout and tears.";
	void *endstart = r + mapsz - strlen(end);
	memcpy(endstart, end, strlen(end));
	char *first_map = r;

	// Second map
	mapsz = PAGESZ;
	r = mmap(base + mapsz * 2, mapsz, PROT_READ | PROT_WRITE, MAP_FIXED | MAP_ANON | MAP_PRIVATE, -1, 0);
	if (r == MAP_FAILED) {
		perror("mapper mmap");
		return 1;
	}
	strcpy(r, "Here is another map!");
	end = "And the second map ends here.";
	endstart = r + mapsz - strlen(end);
	memcpy(endstart, end, strlen(end));
	mprotect(r, mapsz, PROT_READ);
	char *second_map = r;

	// Third map
	mapsz = PAGESZ;
	r = mmap(base + mapsz * 4, mapsz, PROT_READ | PROT_WRITE, MAP_FIXED | MAP_ANON | MAP_PRIVATE, -1, 0);
	if (r == MAP_FAILED) {
		perror("mapper mmap");
		return 1;
	}
	strcpy(r, "Here is yet another map!");
	end = "And the third map ends here.";
	endstart = r + mapsz - strlen(end);
	memcpy(endstart, end, strlen(end));
	mprotect(r, mapsz, PROT_NONE);
	char *third_map = r;

	continue_until_here();

	printf("First map says: %s\n", first_map);
	printf("Second map says: %s\n", second_map);
	mprotect(third_map, PAGESZ, PROT_READ);
	printf("Third map says: %s\n", third_map);

	return 0;
}
