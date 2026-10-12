// 16x16 unsigned Wallace Tree multiplier.
// Logic preserved from the uploaded Wallace_Tree(1).v.
module wallace_multiplier (
    input  wire [15:0] a,
    input  wire [15:0] b,
    output wire [31:0] product
);
    wire [31:0] pp [0:15];
    genvar gi;
    generate
        for (gi = 0; gi < 16; gi = gi + 1) begin : GEN_PP
            assign pp[gi] = b[gi] ? ({16'b0, a} << gi) : 32'b0;
        end
    endgenerate

    function [31:0] csa_sum;
        input [31:0] x, y, z;
        begin csa_sum = x ^ y ^ z; end
    endfunction

    function [31:0] csa_carry;
        input [31:0] x, y, z;
        begin csa_carry = ((x & y) | (y & z) | (x & z)) << 1; end
    endfunction

    wire [31:0] s1_0 = csa_sum  (pp[0],  pp[1],  pp[2]);
    wire [31:0] c1_0 = csa_carry(pp[0],  pp[1],  pp[2]);
    wire [31:0] s1_1 = csa_sum  (pp[3],  pp[4],  pp[5]);
    wire [31:0] c1_1 = csa_carry(pp[3],  pp[4],  pp[5]);
    wire [31:0] s1_2 = csa_sum  (pp[6],  pp[7],  pp[8]);
    wire [31:0] c1_2 = csa_carry(pp[6],  pp[7],  pp[8]);
    wire [31:0] s1_3 = csa_sum  (pp[9],  pp[10], pp[11]);
    wire [31:0] c1_3 = csa_carry(pp[9],  pp[10], pp[11]);
    wire [31:0] s1_4 = csa_sum  (pp[12], pp[13], pp[14]);
    wire [31:0] c1_4 = csa_carry(pp[12], pp[13], pp[14]);
    wire [31:0] pt1_0 = pp[15];

    wire [31:0] s2_0 = csa_sum  (s1_0, c1_0, s1_1);
    wire [31:0] c2_0 = csa_carry(s1_0, c1_0, s1_1);
    wire [31:0] s2_1 = csa_sum  (c1_1, s1_2, c1_2);
    wire [31:0] c2_1 = csa_carry(c1_1, s1_2, c1_2);
    wire [31:0] s2_2 = csa_sum  (s1_3, c1_3, s1_4);
    wire [31:0] c2_2 = csa_carry(s1_3, c1_3, s1_4);
    wire [31:0] pt2_0 = c1_4;
    wire [31:0] pt2_1 = pt1_0;

    wire [31:0] s3_0 = csa_sum  (s2_0, c2_0, s2_1);
    wire [31:0] c3_0 = csa_carry(s2_0, c2_0, s2_1);
    wire [31:0] s3_1 = csa_sum  (c2_1, s2_2, c2_2);
    wire [31:0] c3_1 = csa_carry(c2_1, s2_2, c2_2);
    wire [31:0] pt3_0 = pt2_0;
    wire [31:0] pt3_1 = pt2_1;

    wire [31:0] s4_0 = csa_sum  (s3_0, c3_0, s3_1);
    wire [31:0] c4_0 = csa_carry(s3_0, c3_0, s3_1);
    wire [31:0] s4_1 = csa_sum  (c3_1, pt3_0, pt3_1);
    wire [31:0] c4_1 = csa_carry(c3_1, pt3_0, pt3_1);

    wire [31:0] s5_0 = csa_sum  (s4_0, c4_0, s4_1);
    wire [31:0] c5_0 = csa_carry(s4_0, c4_0, s4_1);
    wire [31:0] pt5_0 = c4_1;

    wire [31:0] s6_0 = csa_sum  (s5_0, c5_0, pt5_0);
    wire [31:0] c6_0 = csa_carry(s5_0, c5_0, pt5_0);

    assign product = s6_0 + c6_0;
endmodule
