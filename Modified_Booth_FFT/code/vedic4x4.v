// vedic4x4.v
// 4-bit x 4-bit unsigned Vedic multiplier, built from four vedic2x2 blocks.
// A = {Ah,Al}, B = {Bh,Bl}, each 2 bits.
//   P = (Ah*Bh << 4) + (Ah*Bl + Al*Bh) << 2 + (Al*Bl)

module vedic4x4 (
    input  [3:0] a,
    input  [3:0] b,
    output [7:0] p
);

    wire [1:0] Ah = a[3:2];
    wire [1:0] Al = a[1:0];
    wire [1:0] Bh = b[3:2];
    wire [1:0] Bl = b[1:0];

    wire [3:0] AhBh, AhBl, AlBh, AlBl;

    vedic2x2 m1 (.a(Ah), .b(Bh), .p(AhBh));
    vedic2x2 m2 (.a(Ah), .b(Bl), .p(AhBl));
    vedic2x2 m3 (.a(Al), .b(Bh), .p(AlBh));
    vedic2x2 m4 (.a(Al), .b(Bl), .p(AlBl));

    wire [4:0] cross_sum = AhBl + AlBh;   // max 15+15=30, fits 5 bits

    wire [7:0] hi_term    = {AhBh, 4'b0};        // shifted by 4
    wire [7:0] cross_term = {1'b0, cross_sum, 2'b0}; // shifted by 2
    wire [7:0] lo_term    = {4'b0, AlBl};

    assign p = hi_term + cross_term + lo_term;

endmodule
