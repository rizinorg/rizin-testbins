#!/bin/bash

TIMEOUT_QEMU="30"
TIMEOUT_RZTRACETEST="180"

TEST_BINS=""
for f in $(find . -executable | grep -o "test_.*" | sort); do
   ESSENTIAL_TESTS="$f $ESSENTIAL_TESTS"
done

ESSENTIAL_TESTS="$ESSENTIAL_TESTS invalid-slots usr v68_scalar v73_scalar test-vma load_align multi_result overflow first mem_noshuf preg_alias dual_stores mem_noshuf_exception read_write_overlap reg_mut misc"
FLOAT_TESTS="fpstuff"
# Produces traces of >1G. Some of the easily 100G in size
BIGTRACE_TESTS="brev circ load_unpack scatter_gather sha1 sha512 float_convd float_convs float_madds"

run_test() {
   if [ "$2" == "NO_OUTPUT" ]; then
      timeout --signal=9 "$TIMEOUT_RZTRACETEST" ~/repos/rz-tracetest/rz-tracetest/build/rz-tracetest -n -e -p "$1.trace" 2> /dev/null
   else
      timeout --signal=9 "$TIMEOUT_RZTRACETEST" ~/repos/rz-tracetest/rz-tracetest/build/rz-tracetest -n -e -p "$1.trace"
   fi
}

run_qemu() {
   if [ "$2" == "NO_OUTPUT" ]; then
      timeout --signal=9 "$TIMEOUT_QEMU" /home/user/repos/qemu/build/qemu-hexagon --tracefile "$1.trace" "$1" > /dev/null 2>&1
   else
      timeout --signal=9 "$TIMEOUT_QEMU" /home/user/repos/qemu/build/qemu-hexagon --tracefile "$1.trace" "$1"
   fi
}

print_help_exit() {
   echo "$0 -t [essentials,float,bigtrace] [-s]"
   echo "    -t    Comma separated list of test sets to run."
   echo "    -s    Fail and print error on first occurance."
   echo "    -q    Run Qemu for each file to generate new traces."
   echo ""
   echo "Test sets:"
   echo "   essentials: Basic tests (scalar, branches, mem read/write etc.)."
   echo "   float:      Float instruction tests."
   echo "   bigtrace:   Tests which produce very big trace files (>10GB)"
   echo ""
   echo "Binaries:"
   echo "   essentials: $ESSENTIAL_TESTS"
   echo "   float:      $FLOAT_TESTS"
   echo "   bigtrace:   $BIGTRACE_TESTS"
   echo ""
   echo "Timeouts:"
   echo "   qemu:         $TIMEOUT_QEMU sec"
   echo "   rz-tracetest: $TIMEOUT_RZTRACETEST sec"
   exit 1
}

PRINT_HELP=$( echo "$*" | grep -Eo "(\-h)|(--help)")
FAIL_ON_ERROR=$( echo "$*" | grep -o "\-s")
RUN_QEMU=$( echo "$*" | grep -o "\-q")
TEST_SET=$( echo "$*" | grep -Eo "\-t [a-zA-Z,]+")

if [ "$PRINT_HELP" == "-h" ] || [ "$PRINT_HELP" == "--help" ]; then
   print_help_exit
fi

if [[ "$TEST_SET" == *"essentials"* ]]; then
   TEST_BINS="$TEST_BINS $ESSENTIAL_TESTS"
fi

if [[ "$TEST_SET" == *"float"* ]]; then
   TEST_BINS="$TEST_BINS $FLOAT_TESTS"
fi

if [[ "$TEST_SET" == *"bigtrace"* ]]; then
   TEST_BINS="$TEST_BINS $BIGTRACE_TESTS"
fi

if [ "$TEST_BINS" == "" ]; then
   print_help_exit
fi

for f in ${TEST_BINS}; do
   echo -n "$f "

   if [ "$RUN_QEMU" == "-q" ]; then
      run_qemu "$f" "NO_OUTPUT"
   fi

   RES=$(run_test "$f" "NO_OUTPUT")
   if [[ $(echo "$RES" | grep -E "success: .+ 100.00%") ]]; then
      echo "[PASS]"
      continue
   fi

   echo "[FAIL]"
   if [ "$FAIL_ON_ERROR" == "-s" ]; then
      run_test "$f"
      exit 1
   fi
done
