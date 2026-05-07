#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] Running multi-block + zero padding test"

if ! g++ -std=c++17 -Wall -Wextra -pedantic ../des.cpp -o ../des_pad_exec; then
  echo "[FAIL] compile failed"
  exit 1
fi

PLAINTEXT="1010101010111100000011110000"  # 28 bits -> padded to 64
KEY="0001001100110100010101110111100110011011101111001101111111110001"

CIPH_LINE=$(printf "1\n%s\n%s\n" "$PLAINTEXT" "$KEY" | ../des_pad_exec | tail -n 1)
CIPH_BITS=${CIPH_LINE#Ciphertext: }

PLAIN_LINE=$(printf "2\n%s\n%s\n" "$CIPH_BITS" "$KEY" | ../des_pad_exec | tail -n 1)
PLAIN_BITS=${PLAIN_LINE#Plaintext: }

EXPECTED="$PLAINTEXT$(printf '%*s' $((64-${#PLAINTEXT})) '' | tr ' ' '0')"

if [ "$PLAIN_BITS" != "$EXPECTED" ]; then
  echo "[FAIL] padding mismatch"
  echo "Expected: $EXPECTED"
  echo "Actual:   $PLAIN_BITS"
  rm -f ../des_pad_exec
  exit 1
fi

echo "[PASS] padding to 64 bits works"
rm -f ../des_pad_exec

