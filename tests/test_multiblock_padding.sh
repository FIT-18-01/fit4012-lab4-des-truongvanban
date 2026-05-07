#!/usr/bin/env bash
# TODO_STUDENT: Hoàn thiện test cho trường hợp multi-block và padding.
# Gợi ý: kiểm tra plaintext dài hơn 64 bit, chia block đúng và zero padding đúng.
set -euo pipefail

echo "[INFO] Running multi-block + zero padding test"

g++ -std=c++17 -Wall -Wextra -pedantic ../des.cpp -o ../des_pad_exec

PLAINTEXT="1010101010111100000011110000"  # 28 bits -> padded to 64
KEY="0001001100110100010101110111100110011011101111001101111111110001"

CIPH=$(printf "1\n%s\n%s\n" "$PLAINTEXT" "$KEY" | ../des_pad_exec | tail -n 1)
CIPH_BITS=${CIPH#Ciphertext: }

PLAIN_OUT=$(printf "2\n%s\n%s\n" "$CIPH_BITS" "$KEY" | ../des_pad_exec | tail -n 1)
PLAIN_BITS=${PLAIN_OUT#Plaintext: }

EXPECTED="$PLAINTEXT$(printf '%*s' $((64-${#PLAINTEXT})) '' | tr ' ' '0')"

test "$PLAIN_BITS" = "$EXPECTED" && echo "[PASS] padding to 64 bits works" || { echo "[FAIL] padding mismatch"; echo "Expected: $EXPECTED"; echo "Actual:   $PLAIN_BITS"; exit 1; }

rm -f ../des_pad_exec

