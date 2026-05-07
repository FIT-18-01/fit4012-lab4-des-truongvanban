#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] Running round-trip test (DES encrypt -> decrypt)"

# compile
if ! g++ -std=c++17 -Wall -Wextra -pedantic ../des.cpp -o ../des_roundtrip_exec; then
  echo "[FAIL] compile failed"
  exit 1
fi

# plaintext longer than 64 bits to exercise multi-block + zero padding
PLAINTEXT="1111000011110000111100001111000011110000111100"  # 46 bits -> padded to 64
KEY="0001001100110100010101110111100110011011101111001101111111110001"

CIPH_LINE=$(printf "1\n%s\n%s\n" "$PLAINTEXT" "$KEY" | ../des_roundtrip_exec | tail -n 1)
CIPH_BITS=${CIPH_LINE#Ciphertext: }

PLAIN_LINE=$(printf "2\n%s\n%s\n" "$CIPH_BITS" "$KEY" | ../des_roundtrip_exec | tail -n 1)
PLAIN_BITS=${PLAIN_LINE#Plaintext: }

LEN=${#PLAINTEXT}
MOD=$((LEN%64))
if [ $MOD -eq 0 ]; then
  PADDED="$PLAINTEXT"
else
  PADLEN=$((64-MOD))
  PADDED="$PLAINTEXT$(printf '%*s' $PADLEN '' | tr ' ' '0')"
fi

if [ "$PLAIN_BITS" != "$PADDED" ]; then
  echo "[FAIL] mismatch"
  echo "Expected: $PADDED"
  echo "Actual:   $PLAIN_BITS"
  rm -f ../des_roundtrip_exec
  exit 1
fi

echo "[PASS] decrypt(encrypt(P)) matches padded plaintext"
rm -f ../des_roundtrip_exec

