#!/bin/bash

if [ -z ${QEMU_BIN+x} ]; then
  echo "Set QEMU_BIN to the qemu binary which supports BAP's tracing."
  exit
fi

for f in $(find -executable); do
  if [ -d "$f" ]; then
    continue
  fi

  echo "BEGIN: $f"
  $QEMU_BIN -tracefile "$f.trace" "$f"
  echo "DONE: $f"
done