#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] Running tamper negative test"

if ! g++ -std=c++17 -Wall -Wextra -pedantic ../des.cpp -o ../des_tamper_exec; then
  echo "[FAIL] compile failed"
  exit 1
fi

PLAINTEXT="000111000111000111000111000111000111000111000111"  # multi-block-ish
KEY="0001001100110100010101110111100110011011101111001101111111110001"

CIPH_LINE=$(printf "1\n%s\n%s\n" "$PLAINTEXT" "$KEY" | ../des_tamper_exec | tail -n 1)
CIPH_BITS=${CIPH_LINE#Ciphertext: }

# flip last bit
LAST=${CIPH_BITS: -1}
if [ "$LAST" = "0" ]; then FLIPPED_LAST="1"; else FLIPPED_LAST="0"; fi
CIPH_TAMPERED=${CIPH_BITS%?}$FLIPPED_LAST

PLAIN_LINE=$(printf "2\n%s\n%s\n" "$CIPH_TAMPERED" "$KEY" | ../des_tamper_exec | tail -n 1)
PLAIN_BITS=${PLAIN_LINE#Plaintext: }

# expected padded plaintext
LEN=${#PLAINTEXT}
MOD=$((LEN%64))
if [ $MOD -eq 0 ]; then
  PADDED="$PLAINTEXT"
else
  PADLEN=$((64-MOD))
  PADDED="$PLAINTEXT$(printf '%*s' $PADLEN '' | tr ' ' '0')"
fi

if [ "$PLAIN_BITS" = "$PADDED" ]; then
  echo "[FAIL] tamper test failed (still matches)"
  rm -f ../des_tamper_exec
  exit 1
fi

echo "[PASS] tampered ciphertext does not decrypt to original"
rm -f ../des_tamper_exec

