#include <iostream>
#include <string>
#include <vector>
#include <bitset>

using namespace std;

static string to4(int v) { return bitset<4>(v).to_string(); }
static int fromBin(const string &s) { return stoi(s, nullptr, 2); }

static string XorBits(const string &a, const string &b) {
    string r;
    r.reserve(a.size());
    for (size_t i = 0; i < a.size(); i++) r.push_back(a[i] == b[i] ? '0' : '1');
    return r;
}

static string IP(const string &in) {
    static const int ip[64] = {
        58,50,42,34,26,18,10,2,
        60,52,44,36,28,20,12,4,
        62,54,46,38,30,22,14,6,
        64,56,48,40,32,24,16,8,
        57,49,41,33,25,17,9,1,
        59,51,43,35,27,19,11,3,
        61,53,45,37,29,21,13,5,
        63,55,47,39,31,23,15,7
    };
    string out; out.reserve(64);
    for (int i = 0; i < 64; i++) out.push_back(in[ip[i]-1]);
    return out;
}

static string IP_INV(const string &in) {
    static const int inv[64] = {
        40,8,48,16,56,24,64,32,
        39,7,47,15,55,23,63,31,
        38,6,46,14,54,22,62,30,
        37,5,45,13,53,21,61,29,
        36,4,44,12,52,20,60,28,
        35,3,43,11,51,19,59,27,
        34,2,42,10,50,18,58,26,
        33,1,41,9,49,17,57,25
    };
    string out; out.reserve(64);
    for (int i = 0; i < 64; i++) out.push_back(in[inv[i]-1]);
    return out;
}

class KeySchedule {
    string key; // 64 bits
    vector<string> roundKeys; // 16 x 48 bits

    static const int pc1[56];
    static const int pc2[48];

    static string rotL(const string &chunk, int n) {
        string r = chunk;
        for (int i = 0; i < n; i++) r = r.substr(1) + r[0];
        return r;
    }

public:
    explicit KeySchedule(const string &k) : key(k) {}

    void generate() {
        roundKeys.clear();
        string perm56; perm56.reserve(56);
        for (int i = 0; i < 56; i++) perm56.push_back(key[pc1[i]-1]);

        string C = perm56.substr(0,28);
        string D = perm56.substr(28,28);

        static const int shifts[16] = {1,1,2,2,2,2,2,2,1,2,2,2,2,2,2,1};

        for (int i = 0; i < 16; i++) {
            C = rotL(C, shifts[i]);
            D = rotL(D, shifts[i]);
            string CD = C + D;

            string rk; rk.reserve(48);
            for (int j = 0; j < 48; j++) rk.push_back(CD[pc2[j]-1]);
            roundKeys.push_back(rk);
        }
    }

    const vector<string>& keys() const { return roundKeys; }
};

const int KeySchedule::pc1[56] = {
    57,49,41,33,25,17,9,
    1,58,50,42,34,26,18,
    10,2,59,51,43,35,27,
    19,11,3,60,52,44,36,
    63,55,47,39,31,23,15,
    7,62,54,46,38,30,22,
    14,6,61,53,45,37,29,
    21,13,5,28,20,12,4
};

const int KeySchedule::pc2[48] = {
    14,17,11,24,1,5,
    3,28,15,6,21,10,
    23,19,12,4,26,8,
    16,7,27,20,13,2,
    41,52,31,37,47,55,
    30,40,51,45,33,48,
    44,49,39,56,34,53,
    46,42,50,36,29,32
};

class DESBlock {
    vector<string> roundKeys; // 16 x 48

    static const int E[48];
    static const int P[32];
    static const int SBOX[8][4][16];

    string f(const string &R, const string &rk) const {
        // Expansion 32->48
        string ER; ER.reserve(48);
        for (int i = 0; i < 48; i++) ER.push_back(R[E[i]-1]);

        string x = XorBits(ER, rk);

        // S-boxes -> 32
        string out; out.reserve(32);
        for (int box = 0; box < 8; box++) {
            string six = x.substr(box*6, 6);
            int row = fromBin(string() + six[0] + six[5]);
            int col = fromBin(six.substr(1,4));
            out += to4(SBOX[box][row][col]);
        }

        // P permutation
        string perm; perm.reserve(32);
        for (int i = 0; i < 32; i++) perm.push_back(out[P[i]-1]);
        return perm;
    }

public:
    explicit DESBlock(const vector<string> &keys) : roundKeys(keys) {}

    string encryptBlock(const string &block) const {
        string perm = IP(block);
        string L = perm.substr(0,32);
        string R = perm.substr(32,32);

        for (int i = 0; i < 16; i++) {
            string newR = XorBits(L, f(R, roundKeys[i]));
            L = R;
            R = newR;
        }
        string preoutput = R + L;
        return IP_INV(preoutput);
    }

    string decryptBlock(const string &block) const {
        string perm = IP(block);
        string L = perm.substr(0,32);
        string R = perm.substr(32,32);

        for (int i = 15; i >= 0; i--) {
            string newR = XorBits(L, f(R, roundKeys[i]));
            L = R;
            R = newR;
        }
        string preoutput = R + L;
        return IP_INV(preoutput);
    }
};

const int DESBlock::E[48] = {
    32,1,2,3,4,5,4,5,
    6,7,8,9,8,9,10,11,
    12,13,12,13,14,15,16,17,
    16,17,18,19,20,21,20,21,
    22,23,24,25,24,25,26,27,
    28,29,28,29,30,31,32,1
};

const int DESBlock::P[32] = {
    16,7,20,21,29,12,28,17,
    1,15,23,26,5,18,31,10,
    2,8,24,14,32,27,3,9,
    19,13,30,6,22,11,4,25
};

const int DESBlock::SBOX[8][4][16] = {
    {
        {14,4,13,1,2,15,11,8,3,10,6,12,5,9,0,7},
        {0,15,7,4,14,2,13,1,10,6,12,11,9,5,3,8},
        {4,1,14,8,13,6,2,11,15,12,9,7,3,10,5,0},
        {15,12,8,2,4,9,1,7,5,11,3,14,10,0,6,13}
    },
    {
        {15,1,8,14,6,11,3,4,9,7,2,13,12,0,5,10},
        {3,13,4,7,15,2,8,14,12,0,1,10,6,9,11,5},
        {0,14,7,11,10,4,13,1,5,8,12,6,9,3,2,15},
        {13,8,10,1,3,15,4,2,11,6,7,12,0,5,14,9}
    },
    {
        {10,0,9,14,6,3,15,5,1,13,12,7,11,4,2,8},
        {13,7,0,9,3,4,6,10,2,8,5,14,12,11,15,1},
        {13,6,4,9,8,15,3,0,11,1,2,12,5,10,14,7},
        {1,10,13,0,6,9,8,7,4,15,14,3,11,5,2,12}
    },
    {
        {7,13,14,3,0,6,9,10,1,2,8,5,11,12,4,15},
        {13,8,11,5,6,15,0,3,4,7,2,12,1,10,14,9},
        {10,6,9,0,12,11,7,13,15,1,3,14,5,2,8,4},
        {3,15,0,6,10,1,13,8,9,4,5,11,12,7,2,14}
    },
    {
        {2,12,4,1,7,10,11,6,8,5,3,15,13,0,14,9},
        {14,11,2,12,4,7,13,1,5,0,15,10,3,9,8,6},
        {4,2,1,11,10,13,7,8,15,9,12,5,6,3,0,14},
        {11,8,12,7,1,14,2,13,6,15,0,9,10,4,5,3}
    },
    {
        {12,1,10,15,9,2,6,8,0,13,3,4,14,7,5,11},
        {10,15,4,2,7,12,9,5,6,1,13,14,0,11,3,8},
        {9,14,15,5,2,8,12,3,7,0,4,10,1,13,11,6},
        {4,3,2,12,9,5,15,10,11,14,1,7,6,0,8,13}
    },
    {
        {4,11,2,14,15,0,8,13,3,12,9,7,5,10,6,1},
        {13,0,11,7,4,9,1,10,14,3,5,12,2,15,8,6},
        {1,4,11,13,12,3,7,14,10,15,6,8,0,5,9,2},
        {6,11,13,8,1,4,10,7,9,5,0,15,14,2,3,12}
    },
    {
        {13,2,8,4,6,15,11,1,10,9,3,14,5,0,12,7},
        {1,15,13,8,10,3,7,4,12,5,6,11,0,14,9,2},
        {7,11,4,1,9,12,14,2,0,6,10,13,15,3,5,8},
        {2,1,14,7,4,10,8,13,15,12,9,0,3,5,6,11}
    }
};

static string zeroPadToMultiple64(const string &bits) {
    size_t mod = bits.size() % 64;
    if (mod == 0) return bits;
    return bits + string(64 - mod, '0');
}

static vector<string> split64(const string &bits) {
    string padded = zeroPadToMultiple64(bits);
    vector<string> blocks;
    for (size_t i = 0; i < padded.size(); i += 64) blocks.push_back(padded.substr(i, 64));
    return blocks;
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int mode;
    if (!(cin >> mode)) return 0;

    if (mode == 1 || mode == 2) {
        string data, key;
        cin >> data >> key;

        KeySchedule ks(key);
        ks.generate();
        DESBlock des(ks.keys());

        vector<string> blocks = split64(data);
        string out;
        for (auto &b : blocks) {
            out += (mode == 1) ? des.encryptBlock(b) : des.decryptBlock(b);
        }
        cout << ((mode == 1) ? "Ciphertext: " : "Plaintext: ") << out << "\n";
        return 0;
    }

    if (mode == 3 || mode == 4) {
        string data, K1, K2, K3;
        cin >> data >> K1 >> K2 >> K3;

        KeySchedule ks1(K1), ks2(K2), ks3(K3);
        ks1.generate(); ks2.generate(); ks3.generate();
        DESBlock des1(ks1.keys()), des2(ks2.keys()), des3(ks3.keys());

        vector<string> blocks = split64(data);
        string out;

        for (auto &blk : blocks) {
            if (mode == 3) {
                // E(K3, D(K2, E(K1, P)))
                string t1 = des1.encryptBlock(blk);
                string t2 = des2.decryptBlock(t1);
                out += des3.encryptBlock(t2);
            } else {
                // D(K3, E(K2, D(K1, C)))
                string t1 = des3.decryptBlock(blk);
                string t2 = des2.encryptBlock(t1);
                out += des1.decryptBlock(t2);
            }
        }

        cout << ((mode == 3) ? "Ciphertext: " : "Plaintext: ") << out << "\n";
        return 0;
    }

    return 0;
}

