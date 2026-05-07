#!/usr/bin/env bash
# TODO_STUDENT: Hoàn thiện negative test cho tamper / flip 1 byte / bit flip.
# Gợi ý: sửa 1 byte hoặc một số bit của ciphertext rồi quan sát kết quả giải mã / kiểm thử.
set -euo pipefail

echo "[INFO] Running tamper negative test"

g++ -std=c++17 -Wall -Wextra -pedantic ../des.cpp -o ../des_tamper_exec

PLAINTEXT="000111000111000111000111000111000111000111000111"  # multi-block-ish
KEY="0001001100110100010101110111100110011011101111001101111111110001"

CIPH=$(printf "1\n%s\n%s\n" "$PLAINTEXT" "$KEY" | ../des_tamper_exec | tail -n 1)
CIPH_BITS=${CIPH#Ciphertext: }

# flip last bit
LAST=${CIPH_BITS: -1}
if [ "$LAST" = "0" ]; then FLIPPED_LAST="1"; else FLIPPED_LAST="0"; fi
CIPH_TAMPERED=${CIPH_BITS%?}$FLIPPED_LAST

PLAIN_OUT=$(printf "2\n%s\n%s\n" "$CIPH_TAMPERED" "$KEY" | ../des_tamper_exec | tail -n 1)
PLAIN_BITS=${PLAIN_OUT#Plaintext: }

# expected padded plaintext
LEN=${#PLAINTEXT}
MOD=$((LEN%64))
if [ $MOD -eq 0 ]; then PADDED=$PLAINTEXT; else PADLEN=$((64-MOD)); PADDED="$PLAINTEXT$(printf '%*s' $PADLEN '' | tr ' ' '0')"; fi

if [ "$PLAIN_BITS" != "$PADDED" ]; then
  echo "[PASS] tampered ciphertext does not decrypt to original"
else
  echo "[FAIL] tamper test failed (still matches)"
  exit 1
fi

rm -f ../des_tamper_exec

