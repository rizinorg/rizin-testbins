#!/bin/bash

TIMEOUT_QEMU=30
TIMEOUT_RZTRACETEST=180

TEST_BINS=""
for f in $(find . -executable | grep -o "test_.*" | sort); do
   ESSENTIAL_TESTS="$f $ESSENTIAL_TESTS"
done

ESSENTIAL_TESTS="$ESSENTIAL_TESTS usr v68_scalar v73_scalar test-vma load_align multi_result overflow first mem_noshuf preg_alias dual_stores mem_noshuf_exception read_write_overlap reg_mut misc"
FLOAT_TESTS="fpstuff"
# Produces traces of >1G. Some of the easily 100G in size
BIGTRACE_TESTS="sha1 sha512 brev circ load_unpack scatter_gather float_convd float_convs float_madds"

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
   echo "    -i    Pass also with unlifted."
   echo "    -q    Run Qemu for each file to generate new traces."
   echo ""
   echo "Results:"
   echo -e "   \e[1;32mPASS\e[0m = All succeeded"
   echo -e "   \e[1;36mPASS\e[0m = All succeeded some unlifted"
   echo -e "   \e[1;31mFAIL\e[0m = At least one error."
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

check_test_result() {
   SUCCESS=$( echo "$*" | grep -Eo "success: [0-9]+ [0-9.]+%" | grep -Eo "[0-9.]+%")
   SKIPPED=$( echo "$*" | grep -Eo "skipped: [0-9]+ [0-9.]+%" | grep -Eo "[0-9.]+%")
   UNLIFTED=$( echo "$*" | grep -Eo "unlifted: [0-9]+ [0-9.]+%" | grep -Eo "[0-9.]+%")
   INVALID=$( echo "$*" | grep -Eo "invalid il: [0-9]+ [0-9.]+%" | grep -Eo "[0-9.]+%")
   RUNTIME=$( echo "$*" | grep -Eo "vm runtime error: [0-9]+ [0-9.]+%" | grep -Eo "[0-9.]+%")
   MISEXEC=$( echo "$*" | grep -Eo "misexecuted: [0-9]+ [0-9.]+%" | grep -Eo "[0-9.]+%")

   if [[ $(echo "$INVALID $RUNTIME $MISEXEC" | grep -Eo "[1-9]") ]]; then
      # Signal failure
      return 2
   elif [[ $(echo "$UNLIFTED" | grep -Eo "[1-9]") ]]; then
      # Signal unlifted
      return 1
   elif [[ $(echo "$SUCCESS" | grep -Eo "100\.00%") ]]; then
      # Success
      return 0
   fi
   return 5
}

PRINT_HELP=$( echo "$*" | grep -Eo "(\-h)|(--help)")
FAIL_ON_ERROR=$( echo "$*" | grep -o "\-s")
RUN_QEMU=$( echo "$*" | grep -o "\-q")
IGNORE_UNLIFTED=$( echo "$*" | grep -o "\-i")
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
   check_test_result $RES
   RES="$?"
   if [ "$RES" == "0" ]; then
      echo -e "[\e[1;32mPASS\e[0m]"
      continue
   elif [ "$RES" == "1" ] && [ "$IGNORE_UNLIFTED" == "-i" ]; then
      echo -e "[\e[1;36mPASS\e[0m]"
      continue
   fi

   echo -e "[\e[1;31mFAIL\e[0m]"
   if [ "$FAIL_ON_ERROR" == "-s" ]; then
      run_test "$f"
      exit 1
   fi
done
