// wallace16x16.v
// 16-bit x 16-bit unsigned Wallace tree multiplier.
//
// Structure:
//   1. Generate 16 partial-product rows (pp[i] = a[i] ? (b << i) : 0),
//      same AND-array generation as the array multiplier - the difference
//      is entirely in how these 16 rows get summed.
//   2. Reduce all 16 rows down to 2 rows using 6 layers of 3:2 CSA
//      compressors (csa3.v), working mostly in parallel per layer -
//      this is what makes it a "tree" instead of a sequential chain.
//      Schedule: 16 -> 11 -> 8 -> 6 -> 4 -> 3 -> 2 operands.
//   3. Add the final 2 rows with a plain ripple-carry adder to get the
//      32-bit product.
//
// IMPORTANT: each CSA's carry output represents a carry generated AT a
// bit position, which affects the NEXT bit position - so every carry
// output is shifted left by 1 bit before being used as an operand in
// the following stage. Getting this shift wrong is the single easiest
// way to silently produce a wrong product, so every carry use below is
// written as `{carry[30:0], 1'b0}` explicitly, right where it's used.

module wallace16x16 (
    input  [15:0] a,
    input  [15:0] b,
    output [31:0] p
);

    // ---- partial products ----
    wire [31:0] pp [0:15];
    genvar gi;
    generate
        for (gi = 0; gi < 16; gi = gi + 1) begin : pp_gen
            assign pp[gi] = a[gi] ? ({16'b0, b} << gi) : 32'b0;
        end
    endgenerate

    // ================= Stage 0: 16 -> 11 =================
    wire [31:0] s0_0, c0_0raw, s0_1, c0_1raw, s0_2, c0_2raw, s0_3, c0_3raw, s0_4, c0_4raw;
    csa3 #(32) u0_0 (.a(pp[0]),  .b(pp[1]),  .c(pp[2]),  .sum(s0_0), .carry_out(c0_0raw));
    csa3 #(32) u0_1 (.a(pp[3]),  .b(pp[4]),  .c(pp[5]),  .sum(s0_1), .carry_out(c0_1raw));
    csa3 #(32) u0_2 (.a(pp[6]),  .b(pp[7]),  .c(pp[8]),  .sum(s0_2), .carry_out(c0_2raw));
    csa3 #(32) u0_3 (.a(pp[9]),  .b(pp[10]), .c(pp[11]), .sum(s0_3), .carry_out(c0_3raw));
    csa3 #(32) u0_4 (.a(pp[12]), .b(pp[13]), .c(pp[14]), .sum(s0_4), .carry_out(c0_4raw));
    wire [31:0] c0_0 = {c0_0raw[30:0], 1'b0};
    wire [31:0] c0_1 = {c0_1raw[30:0], 1'b0};
    wire [31:0] c0_2 = {c0_2raw[30:0], 1'b0};
    wire [31:0] c0_3 = {c0_3raw[30:0], 1'b0};
    wire [31:0] c0_4 = {c0_4raw[30:0], 1'b0};
    // 11 operands into stage 1: s0_0,c0_0,s0_1,c0_1,s0_2,c0_2,s0_3,c0_3,s0_4,c0_4, pp[15](leftover)

    // ================= Stage 1: 11 -> 8 =================
    wire [31:0] s1_0, c1_0raw, s1_1, c1_1raw, s1_2, c1_2raw;
    csa3 #(32) u1_0 (.a(s0_0), .b(c0_0), .c(s0_1), .sum(s1_0), .carry_out(c1_0raw));
    csa3 #(32) u1_1 (.a(c0_1), .b(s0_2), .c(c0_2), .sum(s1_1), .carry_out(c1_1raw));
    csa3 #(32) u1_2 (.a(s0_3), .b(c0_3), .c(s0_4), .sum(s1_2), .carry_out(c1_2raw));
    wire [31:0] c1_0 = {c1_0raw[30:0], 1'b0};
    wire [31:0] c1_1 = {c1_1raw[30:0], 1'b0};
    wire [31:0] c1_2 = {c1_2raw[30:0], 1'b0};
    // 8 operands into stage 2: s1_0,c1_0,s1_1,c1_1,s1_2,c1_2, c0_4(leftover), pp[15](leftover)

    // ================= Stage 2: 8 -> 6 =================
    wire [31:0] s2_0, c2_0raw, s2_1, c2_1raw;
    csa3 #(32) u2_0 (.a(s1_0), .b(c1_0), .c(s1_1), .sum(s2_0), .carry_out(c2_0raw));
    csa3 #(32) u2_1 (.a(c1_1), .b(s1_2), .c(c1_2), .sum(s2_1), .carry_out(c2_1raw));
    wire [31:0] c2_0 = {c2_0raw[30:0], 1'b0};
    wire [31:0] c2_1 = {c2_1raw[30:0], 1'b0};
    // 6 operands into stage 3: s2_0,c2_0,s2_1,c2_1, c0_4(leftover), pp[15](leftover)

    // ================= Stage 3: 6 -> 4 =================
    wire [31:0] s3_0, c3_0raw, s3_1, c3_1raw;
    csa3 #(32) u3_0 (.a(s2_0), .b(c2_0), .c(s2_1), .sum(s3_0), .carry_out(c3_0raw));
    csa3 #(32) u3_1 (.a(c2_1), .b(c0_4), .c(pp[15]), .sum(s3_1), .carry_out(c3_1raw));
    wire [31:0] c3_0 = {c3_0raw[30:0], 1'b0};
    wire [31:0] c3_1 = {c3_1raw[30:0], 1'b0};
    // 4 operands into stage 4: s3_0, c3_0, s3_1, c3_1

    // ================= Stage 4: 4 -> 3 =================
    wire [31:0] s4_0, c4_0raw;
    csa3 #(32) u4_0 (.a(s3_0), .b(c3_0), .c(s3_1), .sum(s4_0), .carry_out(c4_0raw));
    wire [31:0] c4_0 = {c4_0raw[30:0], 1'b0};
    // 3 operands into stage 5: s4_0, c4_0, c3_1(leftover)

    // ================= Stage 5: 3 -> 2 =================
    wire [31:0] s5_0, c5_0raw;
    csa3 #(32) u5_0 (.a(s4_0), .b(c4_0), .c(c3_1), .sum(s5_0), .carry_out(c5_0raw));
    wire [31:0] c5_0 = {c5_0raw[30:0], 1'b0};
    // 2 operands: s5_0, c5_0

    // ================= Final: ripple-carry add of the last 2 rows =================
    assign p = s5_0 + c5_0;

endmodule
