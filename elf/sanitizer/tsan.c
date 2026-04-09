// clang -fsanitize=thread -fPIE -pie -fno-omit-frame-pointer -g -O2 -o tsan.elf tsan.c
#include <pthread.h>
#include <stdio.h>

int a = 0;

void *thread_func(void *arg) {
  a = 1; // Thread 1 writes
  return NULL;
}

int main() {
  pthread_t t;
  pthread_create(&t, NULL, thread_func, NULL);
  a = 2; // Main thread writes
  pthread_join(t, NULL);
  return 0;
}
