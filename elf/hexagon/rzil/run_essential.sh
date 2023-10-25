#!/bin/bash

TEST_BINS=""
for f in $(find . -executable | grep -o "test_.*" | sort); do
   TEST_BINS="$f $TEST_BINS"
done
TEST_BINS="$TEST_BINS load_align multi_result overflow first mem_noshuf preg_alias dual_stores mem_noshuf_exception read_write_overlap reg_mut misc"

run_test() {
   if [ "$2" == "NO_OUTPUT" ]; then
      timeout --signal=9 60 ~/repos/rz-tracetest/rz-tracetest/build/rz-tracetest -n -e -p "$1.trace" 2> /dev/null
   else
      timeout --signal=9 60 ~/repos/rz-tracetest/rz-tracetest/build/rz-tracetest -n -e -p "$1.trace"
   fi
}

run_qemu() {
   if [ "$2" == "NO_OUTPUT" ]; then
      /home/user/repos/qemu/build/qemu-hexagon --tracefile "$1.trace" "$1" > /dev/null 2>&1
   else
      /home/user/repos/qemu/build/qemu-hexagon --tracefile "$1.trace" "$1"
   fi
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
   echo "$0 [-s]"
   echo "    -s    Fail and print error on first occurance."
   echo "    -q    Run Qemu for each file to generate new traces."
   echo ""
   echo "Bins tested: $TEST_BINS"
   exit 1
fi

FAIL_ON_ERROR=$( echo "$*" | grep -o "\-s")
RUN_QEMU=$( echo "$*" | grep -o "\-q")

for f in ${TEST_BINS}; do
   echo -n "$f "

   if [ "$RUN_QEMU" == "-q" ]; then
      run_qemu "$f" "NO_OUTPUT"
   fi

   RES=$(run_test "$f" "NO_OUTPUT")
   if [[ $(echo "$RES" | grep -E "success: .+ 100.0%") ]]; then
      echo "[PASS]"
      continue
   fi

   echo "[FAIL]"
   if [ "$FAIL_ON_ERROR" == "-s" ]; then
      run_test "$f"
      exit 1
   fi
done
