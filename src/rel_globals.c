// gcc -g -gz=none -O0 -fno-common -fno-asynchronous-unwind-tables -fdebug-prefix-map=$PWD=. -c rel_globals.c -o rel_globals.o
int initialized_global = 42;
int uninitialized_global;
static long static_global = 1337;
const char *string_global = "hello";

long use_globals(void) {
	return initialized_global + uninitialized_global + static_global + string_global[0];
}
