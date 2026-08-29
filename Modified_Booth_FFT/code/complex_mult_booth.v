// complex_mult_booth.v
// "Booth" complex multiplier - same interface and rounding as
// complex_mult_array.v / complex_mult_vedic.v / complex_mult_wallace.v.
//
// Unlike the Vedic and Wallace wrappers, no sign-magnitude conversion is
// needed here: booth_mult16x16 takes signed operands directly (that's
// the point of Booth recoding - it handles sign natively), so this
// wrapper is simpler than the other two.

module complex_mult_booth (
    input  signed [15:0] a_re, a_im,
    input  signed [15:0] b_re, b_im,
    output signed [15:0] p_re, p_im
);

    wire signed [31:0] ac, bd, ad, bc;

    booth_mult16x16 m_ac (.a(a_re), .b(b_re), .p(ac));
    booth_mult16x16 m_bd (.a(a_im), .b(b_im), .p(bd));
    booth_mult16x16 m_ad (.a(a_re), .b(b_im), .p(ad));
    booth_mult16x16 m_bc (.a(a_im), .b(b_re), .p(bc));

    wire signed [31:0] re_full = ac - bd;
    wire signed [31:0] im_full = ad + bc;

    // same round-half-up as the other three complex multiplier variants
    wire signed [31:0] re_rounded = re_full + 32'sh0000_4000;
    wire signed [31:0] im_rounded = im_full + 32'sh0000_4000;

    assign p_re = re_rounded[30:15];
    assign p_im = im_rounded[30:15];

endmodule
