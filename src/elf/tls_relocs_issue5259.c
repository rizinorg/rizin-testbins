#include <stdio.h>

// This forces TLS relocations (DTPMOD, DTPOFF, TPOFF)
__thread int my_tls_var = 1337;
__thread int my_tls_var2 = 42;

int get_tls(){
    return my_tls_var + my_tls_var2;
}
