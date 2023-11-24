// SPDX-FileCopyrightText: 2023 Rot127 <unisono@quyllur.org>
// SPDX-License-Identifier: LGPL-3.0-only

/**
 * \file Tests for iCFG generation.
 */

#include <stdio.h>

// Test tree like iCFG
void branch_A() {
  printf("\tbranch_A\n");
}

void branch_B() {
  printf("\tbranch_B\n");
}

void branch_C() {
  printf("\tbranch_C\n");
}

void branch_AB() {
  printf("\tbranch_AB\n");
  printf("\t");
  branch_A();
  printf("\t");
  branch_B();
}

void tree_iCFG() {
  printf("tree_iCFG\n");
  branch_A();
  branch_B();
  branch_AB();
  branch_C();
}

// Test loops in iCFG: S -> A -> B -> S
void loop_0(int i);

void loop_2(int i) {
  printf("loop_1: %d\n", i);
  loop_0(i);
}

void loop_1(int i) {
  printf("loop_0: %d\n", i);
  loop_2(i);
}

void loop_0(int i) {
  if (i == 0) {
    return;
  }
  printf("loop_iCFG: %d\n", i);
  loop_1(i - 1);
}

// Test direct recursive iCFG: S -> S -> S ...
void recurse_iCFG(int i) {
  printf("recurse_iCFG: %d\n", i);
  if (i == 0) {
    return;
  }
  recurse_iCFG(i - 1);
}

int lonley_fcn() {
  int x = 1 + 10;
  return x;
}

void multi_loop(int i) {
  printf("multi-loop 0\n");
  loop_0(i);
  printf("multi-loop 1\n");
  loop_1(i);
}

void test_recurse() {
  recurse_iCFG(3);
}

void test_multi_loop() {
  multi_loop(1);
  test_recurse();
}

void test_simple_loop() {
  loop_0(3);
  test_multi_loop();
}

void start() {
  tree_iCFG();
  test_simple_loop();
}

int main() {
  start();
}
