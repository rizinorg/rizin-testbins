
extern void add_insns();
extern void sub_insns();
extern void store_insns();
extern void load_insns();
extern void compare_insns();
extern void branch_insns();
extern void rotate_insns();
extern void logical_insns();
extern void set_gpr_to_0();

int main() {
    add_insns();
    set_gpr_to_0();
    sub_insns();
    set_gpr_to_0();
    store_insns();
    set_gpr_to_0();
    load_insns();
    set_gpr_to_0();
    compare_insns();
    set_gpr_to_0();
    rotate_insns();
    set_gpr_to_0();
    logical_insns();
    set_gpr_to_0();
    branch_insns();
    return 0;
}