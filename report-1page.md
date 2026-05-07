# FIT4012 - Lab 4: DES / TripleDES

## Mục tiêu
- Nắm vững nguyên lý mã hóa khối DES (Feistel network) và sinh round keys (PC-1/PC-2 + vòng dịch trái).
- Cài đặt DES encrypt/decrypt đúng theo standard (IP, 16 round, S-box, P permutation, IP^-1).
- Mở rộng sang TripleDES với chuỗi thao tác **E(K3, D(K2, E(K1, P)))**.

## Cách làm / Method
- Biểu diễn dữ liệu dưới dạng **bitstring**.
- Với mỗi key 64-bit: thực hiện PC-1 để lấy 56-bit, chia 2 nửa 28-bit, sau đó theo lịch shift sinh 16 round keys bằng PC-2 (ra 48-bit/round).
- Với mỗi block 64-bit: áp dụng IP, tách L/R 32-bit; mỗi round:
  - mở rộng R từ 32 -> 48 bằng expansion table
  - XOR với round key
  - chia 6-bit qua 8 S-box để thu về 4-bit/8 S-box (tổng 32-bit)
  - hoán vị sau S-box (P permutation)
  - Feistel swap và XOR với L.
- Sau 16 vòng: đảo ghép (swap final halves) và áp dụng IP^-1.
- Multi-block + padding: plaintext/ciphertext được chia thành nhiều block 64-bit; block cuối dùng **zero padding** nếu không đủ 64-bit.

## Kết quả / Result
- Implement hỗ trợ đầy đủ 4 chế độ (DES encrypt/decrypt, TripleDES encrypt/decrypt).
- Chạy test round-trip: `decrypt(encrypt(P)) == P` với multi-block và zero padding.
- Có test negative:
  - tamper ciphertext (flip byte/bit) khiến plaintext sau decrypt không còn khớp.
  - sai key khiến decrypt không phục hồi plaintext đúng.

## Kết luận / Conclusion
- Cài đặt DES/TripleDES theo đúng contract input/output và xác minh bằng các test bao gồm cả case đúng và case negative.
- Zero padding và xử lý multi-block giúp chương trình hoạt động ổn định với plaintext không tròn bội 64-bit.

