int arith(int num) {
    int x = num * num;
    int y = x / num;
    int z = ((x % y) & 0xFF) | 0x1;
    return z ^ 0xF0F0F0FF;
}

int main() {
    // easiest way to get a "random" non-compile-time-known value without reading random sources or user input
    int a = (int)(&arith);
    return arith(a) == 0;
}
