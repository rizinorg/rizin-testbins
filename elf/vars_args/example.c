#include <stdio.h>

int foo(int num) {
    int int_one = 1;
    long long_twenty = 20;
    short minus_seven = -7;
    int mult_int = int_one * 6;
    long add_long = long_twenty + 7;
    short sub_short = minus_seven - 9;

    printf("result %d %d %ld %ld\n", num, mult_int, add_long, sub_short);

    return 10;
}

int main(int argc, char const *argv[]) {
    return foo(10);
}
