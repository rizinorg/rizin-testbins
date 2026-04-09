// clang++ -fsanitize=memory,undefined -fPIE -pie -fno-omit-frame-pointer -g -O2 -o msan.elf msan.cc
#include <stdio.h>

int main(int argc, char **argv) {
  int *a = new int[10];
  a[5] = 0;
  if (a[argc])
    printf("xx\n");
  return 0;
}
