// clang++ -fsanitize=address -fPIE -pie -fno-omit-frame-pointer -g -O2 -o asan.elf asan.cc

#include <iostream>
int main() {
    int *array = new int[4]{1, 2, 3, 4};
    // Error: Index 4 is out of bounds (0-3 valid)
    std::cout << array[4] << std::endl;
    delete[] array;
    return 0;
}
