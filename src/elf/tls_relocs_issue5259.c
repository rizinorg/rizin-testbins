#include <stdio.h>

//TLS Relocations
__thread int my_tls_var = 1337;
extern __thread int ext_tls_var;

//IRELATIVE (Indirect Functions)
static int my_ifunc_impl() {return 42; }
void* my_ifunc_resolver()  {return (void*)my_ifunc_impl; }
int my_ifunc() __attribute__ (  (ifunc("my_ifunc_resolver"))  );

//GOT and PLT 
extern int external_var;
extern void external_func();

int do_everything() {
    external_func(); // Triggers PLT
    my_ifunc();      // This triggers IRELATIVE
    return my_tls_var + ext_tls_var + external_var; // to trigger TLS and GOT
}
