// vedic16x16.v
// 16-bit x 16-bit unsigned Vedic multiplier, built from four vedic8x8 blocks.
// This is the size actually used by the FFT (Q1.15 magnitudes are 16-bit).

module vedic16x16 (
    input  [15:0] a,
    input  [15:0] b,
    output [31:0] p
);

    wire [7:0] Ah = a[15:8];
    wire [7:0] Al = a[7:0];
    wire [7:0] Bh = b[15:8];
    wire [7:0] Bl = b[7:0];

    wire [15:0] AhBh, AhBl, AlBh, AlBl;

    vedic8x8 m1 (.a(Ah), .b(Bh), .p(AhBh));
    vedic8x8 m2 (.a(Ah), .b(Bl), .p(AhBl));
    vedic8x8 m3 (.a(Al), .b(Bh), .p(AlBh));
    vedic8x8 m4 (.a(Al), .b(Bl), .p(AlBl));

    wire [16:0] cross_sum = AhBl + AlBh;   // max 65535+65535, fits 17 bits

    wire [31:0] hi_term    = {AhBh, 16'b0};              // shifted by 16
    wire [31:0] cross_term = {7'b0, cross_sum, 8'b0};    // shifted by 8
    wire [31:0] lo_term    = {16'b0, AlBl};

    assign p = hi_term + cross_term + lo_term;

endmodule
