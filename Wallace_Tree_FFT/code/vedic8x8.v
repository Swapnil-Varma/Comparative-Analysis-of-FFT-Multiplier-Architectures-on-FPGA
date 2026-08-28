// vedic8x8.v
// 8-bit x 8-bit unsigned Vedic multiplier, built from four vedic4x4 blocks.

module vedic8x8 (
    input  [7:0] a,
    input  [7:0] b,
    output [15:0] p
);

    wire [3:0] Ah = a[7:4];
    wire [3:0] Al = a[3:0];
    wire [3:0] Bh = b[7:4];
    wire [3:0] Bl = b[3:0];

    wire [7:0] AhBh, AhBl, AlBh, AlBl;

    vedic4x4 m1 (.a(Ah), .b(Bh), .p(AhBh));
    vedic4x4 m2 (.a(Ah), .b(Bl), .p(AhBl));
    vedic4x4 m3 (.a(Al), .b(Bh), .p(AlBh));
    vedic4x4 m4 (.a(Al), .b(Bl), .p(AlBl));

    wire [8:0] cross_sum = AhBl + AlBh;   // max 255+255=510, fits 9 bits

    wire [15:0] hi_term    = {AhBh, 8'b0};             // shifted by 8
    wire [15:0] cross_term = {3'b0, cross_sum, 4'b0};  // shifted by 4
    wire [15:0] lo_term    = {8'b0, AlBl};

    assign p = hi_term + cross_term + lo_term;

endmodule
