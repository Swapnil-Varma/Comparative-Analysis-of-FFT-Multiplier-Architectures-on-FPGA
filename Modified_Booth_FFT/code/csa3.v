// csa3.v
// 3:2 Carry-Save Adder (compressor): reduces three W-bit operands down to
// two (sum, carry) - this is the fundamental building block of a Wallace
// tree. It's just an array of full adders, one per bit position, with NO
// carry propagation between bit positions (that's the whole point - it's
// "carry SAVE", not "carry propagate", which is what makes Wallace-tree
// reduction fast: many of these can work in parallel instead of waiting
// for a carry chain to ripple through).
//
// carry_out[i] represents the carry generated at bit position i - the
// caller is responsible for shifting it left by 1 before using it as an
// operand in the next reduction stage (standard CSA convention).

module csa3 #(
    parameter W = 32
) (
    input  [W-1:0] a, b, c,
    output [W-1:0] sum,
    output [W-1:0] carry_out
);

    genvar i;
    generate
        for (i = 0; i < W; i = i + 1) begin : bitslice
            // full adder per bit position, no inter-bit carry chain
            assign sum[i]       = a[i] ^ b[i] ^ c[i];
            assign carry_out[i] = (a[i] & b[i]) | (b[i] & c[i]) | (a[i] & c[i]);
        end
    endgenerate

endmodule
