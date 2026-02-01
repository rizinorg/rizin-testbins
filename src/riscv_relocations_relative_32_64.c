int global_var = 42;

// For R_RISCV_32 and R_RISCV_64
int *ptr32 = &global_var;        // R_RISCV_32 (32-bit) or R_RISCV_64 (64-bit)

// For R_RISCV_RELATIVE
static int *ptr = &global_var;   // R_RISCV_RELATIVE (in PIE/PIC code)

int main() {
	return *ptr + *ptr32;
}
