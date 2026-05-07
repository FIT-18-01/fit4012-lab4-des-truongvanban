#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] Running DES sample test (Mode 1)"

# compile
if ! g++ -std=c++17 -Wall -Wextra -pedantic ../des.cpp -o ../des_test_exec; then
  echo "[FAIL] compile failed"
  exit 1
fi

EXPECTED="Ciphertext: 0111111010111111010001001001001100100011111110101111101011111000"

INPUT_P="0001001000110100010101100111100010011010101111001101111011110001"
INPUT_K="0001001100110100010101110111100110011011101111001101111111110001"

OUTPUT=$(printf "1\n%s\n%s\n" "$INPUT_P" "$INPUT_K" | ../des_test_exec | tail -n 1)

test "$OUTPUT" = "$EXPECTED" && echo "[PASS] sample DES ciphertext matches" || { echo "[FAIL] Unexpected output"; echo "Expected: $EXPECTED"; echo "Actual:   $OUTPUT"; exit 1; }

rm -f ../des_test_exec

