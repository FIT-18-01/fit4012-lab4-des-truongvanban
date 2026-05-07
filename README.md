# FIT4012 - Lab 4: DES / TripleDES (Trương Văn Bản)

Repo này là bài làm Lab 4 FIT4012 (DES / TripleDES). Chương trình cài đặt DES cho 4 chế độ input/output theo contract của lab.

## 1. Cách chạy

### Makefile
```bash
make
./des
```

### Compile trực tiếp
```bash
g++ -std=c++17 -Wall -Wextra -pedantic des.cpp -o des
./des
```

## 2. Input / Output (theo stdin/stdout contract)

Chương trình đọc từ **stdin**:

```text
Chọn mode:
1 = DES encrypt
2 = DES decrypt
3 = TripleDES encrypt
4 = TripleDES decrypt
```

### Mode 1: DES encrypt
Input:
1) `1`
2) plaintext (bitstring)
3) key 64-bit (bitstring)

Output:
- `Ciphertext: <bitstring>` (ciphertext ghép từ nhiều block, block cuối cùng dùng **zero padding** nếu thiếu bit)

### Mode 2: DES decrypt
Input:
1) `2`
2) ciphertext (bitstring, ghép từ nhiều block)
3) key 64-bit (bitstring)

Output:
- `Plaintext: <bitstring>`

### Mode 3: TripleDES encrypt
Input:
1) `3`
2) plaintext 64-bit
3) `K1` (64-bit)
4) `K2` (64-bit)
5) `K3` (64-bit)

Output:
- `Ciphertext: <bitstring>` theo công thức: **E(K3, D(K2, E(K1, P)))**

### Mode 4: TripleDES decrypt
Input:
1) `4`
2) ciphertext 64-bit
3) `K1`
4) `K2`
5) `K3`

Output:
- `Plaintext: <bitstring>` theo giải mã TripleDES (áp dụng ngược lại).

## 3. Padding / Multi-block
- DES block size: **64 bit**.
- Nếu plaintext < 64 bit: pad bằng `0` để đủ 64 bit.
- Nếu plaintext > 64 bit: chia thành nhiều block 64 bit từ trái sang phải.
- Block cuối cùng nếu thiếu bit sẽ zero pad.

## 4. Tests / Logs
- Có 5 test trong `tests/`.
- Có ít nhất 1 file log minh chứng trong `logs/`.

## 5. An toàn sử dụng

Dự án này chỉ phục vụ mục đích học tập.

Người dùng cần:
- Bảo vệ dữ liệu cá nhân
- Không sử dụng hệ thống cho mục đích trái phép
- Không truy cập trái phép vào dữ liệu của người khác

Mọi thông tin nhạy cảm cần được bảo mật an toàn.
