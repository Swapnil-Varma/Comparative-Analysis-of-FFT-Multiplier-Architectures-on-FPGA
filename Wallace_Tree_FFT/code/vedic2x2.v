// vedic2x2.v
// Base case of the recursive Vedic multiplier: 2-bit x 2-bit -> 4-bit,
// unsigned, using the Urdhva Tiryagbhyam ("vertically and crosswise") sutra.
//
// For A = a1 a0, B = b1 b0:
//   bit0        = a0.b0
//   bit1 + c1   = a1.b0 + a0.b1        (crosswise sum, with carry)
//   bit2 + c2   = a1.b1 + c1
//   bit3        = c2
//
// All four 4x4 Vedic blocks are built from four of these; 8x8 from four
// 4x4 blocks; 16x16 from four 8x8 blocks - see vedic4x4.v / vedic8x8.v /
// vedic16x16.v.

module vedic2x2 (
    input  [1:0] a,
    input  [1:0] b,
    output [3:0] p
);

    wire s0, s1, s2, s3, c1, c2;
    wire p1a, p1b, p2;

    assign s0  = a[0] & b[0];

    assign p1a = a[1] & b[0];
    assign p1b = a[0] & b[1];
    assign {c1, s1} = p1a + p1b;

    assign p2  = a[1] & b[1];
    assign {c2, s2} = p2 + c1;

    assign s3 = c2;

    assign p = {s3, s2, s1, s0};

endmodule
