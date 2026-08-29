// complex_mult_vedic.v
// "Vedic" complex multiplier - same interface and rounding as
// complex_mult_array.v, but the four real multiplies inside are done by
// the recursive Urdhva Tiryagbhyam vedic16x16 core instead of a flat
// array multiply. Drop-in replacement: same ports, same Q1.15 rounding.
//
// vedic16x16 is UNSIGNED, so each signed multiply here is done via the
// standard sign-magnitude technique: take the absolute value of both
// operands, multiply magnitudes with the Vedic core, then re-apply the
// correct sign (XOR of the two input signs) to the result.

module vedic_mult16x16_signed (
    input  signed [15:0] a,
    input  signed [15:0] b,
    output signed [31:0] p
);

    wire sign_a = a[15];
    wire sign_b = b[15];

    wire [15:0] mag_a = sign_a ? (~a + 1'b1) : a;
    wire [15:0] mag_b = sign_b ? (~b + 1'b1) : b;

    wire [31:0] mag_p;
    vedic16x16 u_mag (.a(mag_a), .b(mag_b), .p(mag_p));

    wire result_sign = sign_a ^ sign_b;

    assign p = result_sign ? (~mag_p + 1'b1) : mag_p;

endmodule


module complex_mult_vedic (
    input  signed [15:0] a_re, a_im,
    input  signed [15:0] b_re, b_im,
    output signed [15:0] p_re, p_im
);

    wire signed [31:0] ac, bd, ad, bc;

    vedic_mult16x16_signed m_ac (.a(a_re), .b(b_re), .p(ac));
    vedic_mult16x16_signed m_bd (.a(a_im), .b(b_im), .p(bd));
    vedic_mult16x16_signed m_ad (.a(a_re), .b(b_im), .p(ad));
    vedic_mult16x16_signed m_bc (.a(a_im), .b(b_re), .p(bc));

    wire signed [31:0] re_full = ac - bd;
    wire signed [31:0] im_full = ad + bc;

    // same round-half-up as complex_mult_array.v
    wire signed [31:0] re_rounded = re_full + 32'sh0000_4000;
    wire signed [31:0] im_rounded = im_full + 32'sh0000_4000;

    assign p_re = re_rounded[30:15];
    assign p_im = im_rounded[30:15];

endmodule
