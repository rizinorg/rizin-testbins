#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>

#ifdef USE_JEMALLOC
#include <jemalloc/jemalloc.h>
#else
#include <gnu/libc-version.h>
#endif

pthread_barrier_t barrier;

void breakpoint_here(void) {
    asm volatile("int3");
}

void *thread_func(void *arg) {
    int thread_idx = *(int *)arg;
    void *ptrs[100];

    // Wait for all threads to be ready
    pthread_barrier_wait(&barrier);

    // Allocate and hold - creates arena contention
    for (int i = 0; i < 100; i++) {
        ptrs[i] = malloc(1024);
    }

    // Allocate small chunk (32 bytes)
    char *small = malloc(32);
    strcpy(small, "hello world");
    printf("thread %d Small chunk at %p: %s\n", thread_idx, small, small);

    // Allocate big chunk (1024 bytes)
    char *big = malloc(1024);
    strcpy(big, "hello world");
    printf("thread %d Big chunk at %p: %s\n", thread_idx, big, big);

    if (thread_idx == 0) {
        printf("\nThreads allocated. Press Enter to continue...\n");
        breakpoint_here(); 
        getchar();
    }

    // Wait before freeing
    pthread_barrier_wait(&barrier);

    for (int i = 0; i < 100; i++) {
        free(ptrs[i]);
    }

    return NULL;
}

int main() {
    printf("PID: %d\n", getpid());

#ifdef USE_JEMALLOC
    printf("Allocator: jemalloc %s\n", JEMALLOC_VERSION);
#else
    printf("Allocator: glibc %s\n", gnu_get_libc_version());
#endif

    pthread_barrier_init(&barrier, NULL, 4);

    pthread_t threads[4];
    int idxs[4];
    for (int i = 0; i < 4; i++) {
        idxs[i] = i;
        pthread_create(&threads[i], NULL, thread_func, &idxs[i]);
    }
    
    for (int i = 0; i < 4; i++) {
        pthread_join(threads[i], NULL);
    }

    pthread_barrier_destroy(&barrier);

#ifdef USE_JEMALLOC
    // Print jemalloc stats
    printf("\nJemalloc statistics:\n");
    malloc_stats_print(NULL, NULL, NULL);
#endif

    return 0;
}
