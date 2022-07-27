
extern void add_insns();
extern void branch_insns();
extern void cr_logical_insns();
extern void compare_insns();
extern void div_mul_insns();
extern void logical_insns();
extern void read_set_spr();
extern void rotate_insns();
extern void set_gpr_to_0();
extern void shift_insns();
extern void special_insns();
extern void store_insns();
extern void sub_insns();
extern void test_loads();

int main() {
    add_insns();
    set_gpr_to_0();
    sub_insns();
    set_gpr_to_0();
    store_insns();
    set_gpr_to_0();
    test_loads();
    set_gpr_to_0();
    compare_insns();
    set_gpr_to_0();
    rotate_insns();
    set_gpr_to_0();
    logical_insns();
    set_gpr_to_0();
    special_insns();
    set_gpr_to_0();
    shift_insns();
    set_gpr_to_0();
    read_set_spr();
    set_gpr_to_0();
    cr_logical_insns();
    set_gpr_to_0();
    div_mul_insns();
    // set_gpr_to_0();
    // branch_insns();
    return 0;
}