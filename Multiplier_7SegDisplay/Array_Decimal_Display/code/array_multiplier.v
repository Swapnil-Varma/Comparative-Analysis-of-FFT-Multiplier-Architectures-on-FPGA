// 16x16 unsigned combinational array-style multiplier.
// Preserved from the supplied source.
module array_multiplier (
    input  wire [15:0] a,
    input  wire [15:0] b,
    output wire [31:0] product
);
    wire [31:0] pp  [0:15];
    wire [31:0] sum [0:16];
    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin : GEN_PP
            assign pp[i] = b[i] ? ({16'b0, a} << i) : 32'b0;
        end
    endgenerate

    assign sum[0] = 32'b0;
    generate
        for (i = 0; i < 16; i = i + 1) begin : GEN_ADD
            assign sum[i+1] = sum[i] + pp[i];
        end
    endgenerate

    assign product = sum[16];
endmodule
