// Test forward branch at +254 bytes (maximum forward range)
int test_forward_max(int x) {
  // 2 bytes
  if (x == 0)
    goto target;

  // Need 252 bytes of padding
  // c.nop is 2 bytes, so we need 126 nops
  __asm__ volatile(".rept 126\n" // 2 * 126 + 2 = 252 + 2 = 254 bytes
                   "c.nop\n"
                   ".endr\n");

target:
  return 1;
}

// Test forward branch at +256 bytes (beyond maximum)
int test_forward_over(int x) {
  // 2 bytes
  if (x == 0)
    goto target;

  // 254 to equal 256 bytes gap total and exceed maximum
  __asm__ volatile(".rept 127\n" // 2 * 127 + 2 = 254 + 2 = 256 bytes
                   "c.nop\n"
                   ".endr\n");

target:
  return 2;
}

// Test backward branch at -256 bytes (maximum backward range)
int test_backward_max(int x) {
loop_start:
  __asm__ volatile(".rept 128\n" // 2 * 128 = 256 bytes
                   "c.nop\n"
                   ".endr\n");

  if (x != 0)
    goto loop_start;

  return 3;
}

// Test backward branch beyond maximum
int test_backward_over(int x) {
loop_start:
  __asm__ volatile(".rept 129\n" // 2 * 129 = 258 bytes
                   "c.nop\n"
                   ".endr\n");

  if (x != 0)
    goto loop_start;

  return 4;
}
