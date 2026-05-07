# Run log - FIT4012 Lab 4 DES/TripleDES

- Biên dịch:
  - `g++ -std=c++17 -Wall -Wextra -pedantic des.cpp -o des`
- Chạy mẫu demo (Mode 1 DES encrypt) với plaintext và key 64-bit theo code gốc:
  - Input plaintext:
    - 0001001000110100010101100111100010011010101111001101111011110001
  - Input key:
    - 0001001100110100010101110111100110011011101111001101111111110001
  - Output ciphertext (ciphertext cuối cùng):
    - 0111111010111111010001001001001100100011111110101111101011111000

- Đã implement đầy đủ 4 mode và multi-block padding theo yêu cầu lab.
- Đã hoàn thiện 5 test script trong `tests/` và loại bỏ placeholder `TODO_STUDENT`.

