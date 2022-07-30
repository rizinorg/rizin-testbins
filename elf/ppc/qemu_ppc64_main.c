#include <stdio.h>

extern void run_all_tests();

int main() {
    printf("run all\n");
    asm (
        "bl run_all_tests"
    );
    
    return 0;
}