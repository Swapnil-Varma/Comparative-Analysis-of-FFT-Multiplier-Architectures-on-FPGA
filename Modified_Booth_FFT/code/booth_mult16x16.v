// booth_mult16x16.v
// 16-bit x 16-bit SIGNED Modified Booth Radix-4 multiplier.
//
// Unlike the Vedic and Wallace multipliers, Booth recoding handles signed
// numbers natively - no separate sign-magnitude wrapper is needed here.
//
// Method:
//   1. Sign-extend A to 32 bits (a_ext) and compute 2*A (a2_ext).
//   2. Build the Booth recoding vector from B: y = {B[15], B, 1'b0}
//      (sign-extended by 1 bit at the top, 0 appended at the bottom).
//      This gives 8 overlapping 3-bit groups for a 16-bit operand
//      (radix-4 groups process 2 new bits per group, with 1 bit of
//      overlap from the previous group).
//   3. Each group selects one of {0, +A, +2A, -A, -2A} per the standard
//      Modified Booth table, shifted left by 2*i bits (i = 0..7).
//   4. Sum all 8 partial products directly - only 8 rows instead of the
//      array multiplier's 16, which is Booth's actual advantage: fewer
//      partial products to add, independent of how the adding is done.

module booth_mult16x16 (
    input  signed [15:0] a,
    input  signed [15:0] b,
    output signed [31:0] p
);

    wire signed [31:0] a_ext  = {{16{a[15]}}, a};
    wire signed [31:0] a2_ext = a_ext <<< 1;

    wire [17:0] y = {b[15], b, 1'b0};

    wire signed [31:0] pp [0:7];

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : booth_group
            wire [2:0] code = {y[2*i+2], y[2*i+1], y[2*i]};
            reg signed [31:0] sel;
            always @(*) begin
                case (code)
                    3'b000, 3'b111: sel = 32'sd0;
                    3'b001, 3'b010: sel = a_ext;
                    3'b011:         sel = a2_ext;
                    3'b100:         sel = -a2_ext;
                    3'b101, 3'b110: sel = -a_ext;
                    default:        sel = 32'sd0;
                endcase
            end
            assign pp[i] = sel <<< (2*i);
        end
    endgenerate

    assign p = pp[0] + pp[1] + pp[2] + pp[3] + pp[4] + pp[5] + pp[6] + pp[7];

endmodule
