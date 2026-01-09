int a[] = {1, 2, 3, 4, 5};
int b[] = {10, 20, 30, 40, 50};

int result[sizeof(a)/sizeof(a[0])] = {0};

int main() {

    for (int i = 0; i < sizeof(a)/sizeof(a[0]); i++) {
        result[i] = a[i] + b[i];
    }
    return 0;
}
