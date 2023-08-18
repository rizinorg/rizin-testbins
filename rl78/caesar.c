#include <stdlib.h>
#include <string.h>

#define MAX_LEN 64

const char *encrypted = "Ozacgh og ghfcbu og hvs OSG";
const int key = 14;

struct operations {
    int (*decrypt)(char*, const char*, size_t);
    void (*make_uppercase)(char*, size_t);
};

int decrypt(char *decrypted, const char *encrypted, size_t n)
{
    for (size_t i = 0; i < n; i++) {
        decrypted[i] = encrypted[i] - key;
    }

    return 1;
}

void make_uppercase(char *buf, size_t n)
{
    for (size_t i = 0; i < n; i++) {
        if (buf[i] >= 'a' && buf[i] <= 'z') {
            buf[i] += 'A' - 'a';
        }
    }
}

int hash(const char *buf, size_t n)
{
    int sum = 0;
    for (size_t i = 0; i < n; i++) {
        sum = (sum + buf[i] * 32203) % 63439;
    }

    return sum;
}

int main(int argc, char *argv[])
{
    const struct operations ops = {
        .decrypt = &decrypt,
        .make_uppercase = &make_uppercase
    };

    const size_t len = strlen(encrypted);
    if (len > MAX_LEN) {
        return EXIT_FAILURE;
    }

    char *decrypted = malloc(len);
    if (!ops.decrypt(decrypted, encrypted, len)) {
        free(decrypted);
        return EXIT_FAILURE;
    }

    char *uppercase = strdup(decrypted);
    ops.make_uppercase(uppercase, len);

    const char *pw = "ALMOST AS STRONG AS THE AES";
    const size_t pwlen = strlen(pw);
    if (hash(uppercase, len) != hash(pw, pwlen)) {
        return EXIT_FAILURE;
    }

    free(decrypted);
    free(uppercase);
    return EXIT_SUCCESS;
}
