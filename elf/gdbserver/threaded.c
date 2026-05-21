#include <pthread.h>
#include <unistd.h>

static void *worker(void *arg) {
    (void)arg;
    for (;;) sleep(1);
    return NULL;
}

int main(void) {
    pthread_t t;
    pthread_create(&t, NULL, worker, NULL);
    __asm__("int3"); /* stop here; both threads exist at this point */
    pthread_join(t, NULL);
    return 0;
}
