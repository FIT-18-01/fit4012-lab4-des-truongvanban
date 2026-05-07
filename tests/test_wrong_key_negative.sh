#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] Running wrong-key negative test"

if ! g++ -std=c++17 -Wall -Wextra -pedantic ../des.cpp -o ../des_wrongkey_exec; then
  echo "[FAIL] compile failed"
  exit 1
fi

PLAINTEXT="1100110011001100110011001100110011001100"  # 40 bits -> padded
KEY_GOOD="0001001100110100010101110111100110011011101111001101111111110001"
KEY_BAD="1111001100110100010101110111100110011011101111001101111111110000"

CIPH_LINE=$(printf "1\n%s\n%s\n" "$PLAINTEXT" "$KEY_GOOD" | ../des_wrongkey_exec | tail -n 1)
CIPH_BITS=${CIPH_LINE#Ciphertext: }

PLAIN_LINE=$(printf "2\n%s\n%s\n" "$CIPH_BITS" "$KEY_BAD" | ../des_wrongkey_exec | tail -n 1)
PLAIN_BITS=${PLAIN_LINE#Plaintext: }

LEN=${#PLAINTEXT}
MOD=$((LEN%64))
if [ $MOD -eq 0 ]; then
  PADDED="$PLAINTEXT"
else
  PADLEN=$((64-MOD))
  PADDED="$PLAINTEXT$(printf '%*s' $PADLEN '' | tr ' ' '0')"
fi

if [ "$PLAIN_BITS" = "$PADDED" ]; then
  echo "[FAIL] wrong-key test failed (unexpected plaintext match)"
  rm -f ../des_wrongkey_exec
  exit 1
fi

echo "[PASS] wrong key does not recover plaintext"
rm -f ../des_wrongkey_exec

