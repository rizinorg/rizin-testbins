// SPDX-FileCopyrightText: 2024 Rot127 <unisono@quyllur.org>
// SPDX-License-Identifier: LGPL-3.0-only

static int z = 42;
static int *some_ptr() { return &z; };

static int *function_0() { return some_ptr(); }
static int *function_1() { return some_ptr(); }
static int *function_2() { return some_ptr(); }

typedef int *(*fcn)();

static fcn fcn_arr_mutable[] = {
    function_0,
    function_1,
    function_2,
};

// const makes sure this array lands in .rodata
// volatile makes gcc not constant-fold (it would do so even with -O0)
static const volatile fcn fcn_arr_const[] = {
    function_0,
    function_1,
    function_2,
};

int indirect_call_single() {
	return *fcn_arr_const[0 + 1]() + *fcn_arr_mutable[1]();
}

int indirect_calls_in_loop() {
	/// Same code calls multiple functions that could be statically known
	unsigned x = 0;
	for (unsigned i = 0; i < 3; ++i) {
		x += *fcn_arr_mutable[i]();
		x += *fcn_arr_const[i]();
	}
	return x;
}

int main() {
	return indirect_call_single() + indirect_calls_in_loop();
}
