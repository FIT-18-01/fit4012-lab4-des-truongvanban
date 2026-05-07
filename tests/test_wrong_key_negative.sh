#!/usr/bin/env bash
# TODO_STUDENT: Hoàn thiện negative test cho wrong key / incorrect key / sai key.
# Gợi ý: giải mã với khóa sai và chứng minh không khôi phục đúng plaintext.
set -euo pipefail

echo "[INFO] Running wrong-key negative test"

g++ -std=c++17 -Wall -Wextra -pedantic ../des.cpp -o ../des_wrongkey_exec

PLAINTEXT="1100110011001100110011001100110011001100"  # 40 bits -> padded
KEY_GOOD="0001001100110100010101110111100110011011101111001101111111110001"
KEY_BAD="1111001100110100010101110111100110011011101111001101111111110000"

CIPH=$(printf "1\n%s\n%s\n" "$PLAINTEXT" "$KEY_GOOD" | ../des_wrongkey_exec | tail -n 1)
CIPH_BITS=${CIPH#Ciphertext: }

PLAIN_OUT=$(printf "2\n%s\n%s\n" "$CIPH_BITS" "$KEY_BAD" | ../des_wrongkey_exec | tail -n 1)
PLAIN_BITS=${PLAIN_OUT#Plaintext: }

LEN=${#PLAINTEXT}
MOD=$((LEN%64))
if [ $MOD -eq 0 ]; then PADDED=$PLAINTEXT; else PADLEN=$((64-MOD)); PADDED="$PLAINTEXT$(printf '%*s' $PADLEN '' | tr ' ' '0')"; fi

if [ "$PLAIN_BITS" != "$PADDED" ]; then
  echo "[PASS] wrong key does not recover plaintext"
else
  echo "[FAIL] wrong-key test failed (unexpected plaintext match)"
  exit 1
fi


rm -f ../des_wrongkey_exec

