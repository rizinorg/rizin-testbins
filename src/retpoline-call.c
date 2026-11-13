// gcc -O2 -fno-pic -mindirect-branch=thunk-extern -mfunction-return=thunk-extern -c retpoline-call.c -o retpoline-call.o
// `call __x86_indirect_thunk_rax` is `call *%rax`: hook() must continue after it.
extern long (*orig)(long);
extern void ext(long);

long hook(long x) {
	long r = orig(x);
	if (r > 0) {
		ext(r);
	}
	return r;
}
