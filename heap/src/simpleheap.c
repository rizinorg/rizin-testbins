
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#ifdef USE_JEMALLOC
#include <jemalloc/jemalloc.h>
#endif

int main() {
    printf("PID: %d\n", getpid());

#ifdef USE_JEMALLOC
    printf("Allocator: jemalloc %s\n", JEMALLOC_VERSION);
#else
    printf("Allocator: glibc malloc\n");
#endif

    // Allocate small chunk (32 bytes)
    char *small = malloc(32);
    strcpy(small, "hello world");
    printf("Small chunk at %p: %s\n", small, small);

    // Allocate big chunk (1024 bytes)
    char *big = malloc(1024);
    strcpy(big, "hello world");
    printf("Big chunk at %p: %s\n", big, big);

    printf("\nWaiting... (press Enter to exit)\n");
    getchar();

    free(small);
    free(big);

#ifdef USE_JEMALLOC
    // Print jemalloc stats
    printf("\nJemalloc statistics:\n");
    malloc_stats_print(NULL, NULL, NULL);
#endif

    return 0;
}
