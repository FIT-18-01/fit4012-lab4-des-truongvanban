#!/usr/bin/env bash
# TODO_STUDENT: Hoàn thiện test round-trip encrypt -> decrypt.
# Gợi ý: sau khi em viết thêm giải mã, cần kiểm tra decrypt(encrypt(plaintext)) = plaintext.
set -euo pipefail

echo "[INFO] Running round-trip test (DES encrypt -> decrypt)"

g++ -std=c++17 -Wall -Wextra -pedantic ../des.cpp -o ../des_roundtrip_exec

# plaintext longer than 64 bits to exercise multi-block + zero padding
PLAINTEXT="1111000011110000111100001111000011110000111100"  # 46 bits -> padded to 64

KEY="0001001100110100010101110111100110011011101111001101111111110001"

CIPH=$(printf "1\n%s\n%s\n" "$PLAINTEXT" "$KEY" | ../des_roundtrip_exec | tail -n 1)
# remove prefix "Ciphertext: "
CIPH_BITS=${CIPH#Ciphertext: }

PLAIN_OUT=$(printf "2\n%s\n%s\n" "$CIPH_BITS" "$KEY" | ../des_roundtrip_exec | tail -n 1)
# remove prefix "Plaintext: "
PLAIN_BITS=${PLAIN_OUT#Plaintext: }


# Expected plaintext after zero padding to multiple of 64
# pad right with zeros to next multiple of 64
LEN=${#PLAINTEXT}
MOD=$((LEN%64))
if [ $MOD -eq 0 ]; then PADDED=$PLAINTEXT; else PADLEN=$((64-MOD)); PADDED="$PLAINTEXT$(printf '%*s' $PADLEN '' | tr ' ' '0')"; fi

if [ "$PLAIN_BITS" = "$PADDED" ]; then
  echo "[PASS] decrypt(encrypt(P)) matches padded plaintext"
else
  echo "[FAIL] mismatch"
  echo "Expected: $PADDED"
  echo "Actual:   $PLAIN_BITS"
  exit 1
fi

rm -f ../des_roundtrip_exec

