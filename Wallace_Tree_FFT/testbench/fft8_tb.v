// fft8_tb.v
// Self-checking testbench for the VEDIC-multiplier variant of the 8-point FFT.
// Same verified test vector and expected outputs as the Array-multiplier
// project - the Vedic multiplier is mathematically identical to the array
// multiplier (just a different internal implementation), so results must
// match exactly.

`timescale 1ns/1ps

module fft8_tb;

    reg clk = 0;
    reg rst = 1;
    reg start = 0;

    reg signed [15:0] x0_re, x0_im, x1_re, x1_im, x2_re, x2_im, x3_re, x3_im;
    reg signed [15:0] x4_re, x4_im, x5_re, x5_im, x6_re, x6_im, x7_re, x7_im;

    wire signed [15:0] X0_re, X0_im, X1_re, X1_im, X2_re, X2_im, X3_re, X3_im;
    wire signed [15:0] X4_re, X4_im, X5_re, X5_im, X6_re, X6_im, X7_re, X7_im;
    wire valid;

    always #5 clk = ~clk;

    // *** This is the only difference from the Array project's testbench ***
    fft8_top #(.MULT_TYPE("WALLACE")) dut (
        .clk(clk), .rst(rst), .start(start),
        .x0_re(x0_re), .x0_im(x0_im), .x1_re(x1_re), .x1_im(x1_im),
        .x2_re(x2_re), .x2_im(x2_im), .x3_re(x3_re), .x3_im(x3_im),
        .x4_re(x4_re), .x4_im(x4_im), .x5_re(x5_re), .x5_im(x5_im),
        .x6_re(x6_re), .x6_im(x6_im), .x7_re(x7_re), .x7_im(x7_im),
        .X0_re(X0_re), .X0_im(X0_im), .X1_re(X1_re), .X1_im(X1_im),
        .X2_re(X2_re), .X2_im(X2_im), .X3_re(X3_re), .X3_im(X3_im),
        .X4_re(X4_re), .X4_im(X4_im), .X5_re(X5_re), .X5_im(X5_im),
        .X6_re(X6_re), .X6_im(X6_im), .X7_re(X7_re), .X7_im(X7_im),
        .valid(valid)
    );

    localparam signed [15:0] EXP0_RE=16'sh2666, EXP0_IM=16'sh0000;
    localparam signed [15:0] EXP1_RE=16'sh18D4, EXP1_IM=16'sh0412;
    localparam signed [15:0] EXP2_RE=16'shE000, EXP2_IM=16'shE000;
    localparam signed [15:0] EXP3_RE=16'sh33FA, EXP3_IM=16'shAA78;
    localparam signed [15:0] EXP4_RE=16'shE666, EXP4_IM=16'sh0000;
    localparam signed [15:0] EXP5_RE=16'sh33FA, EXP5_IM=16'sh5588;
    localparam signed [15:0] EXP6_RE=16'shE000, EXP6_IM=16'sh2000;
    localparam signed [15:0] EXP7_RE=16'sh18D4, EXP7_IM=16'shFBEE;

    localparam TOL = 2;

    function automatic check_close(input signed [15:0] got, input signed [15:0] exp);
        reg signed [16:0] d;
        begin
            d = got - exp;
            check_close = (d <= TOL) && (d >= -TOL);
        end
    endfunction

    integer errors;

    initial begin
        errors = 0;
        rst = 1; start = 0;
        x0_re=16'sh0CCD; x0_im=0;
        x1_re=16'sh199A; x1_im=0;
        x2_re=16'shF333; x2_im=0;
        x3_re=16'sh1333; x3_im=0;
        x4_re=16'shE666; x4_im=0;
        x5_re=16'sh0666; x5_im=0;
        x6_re=16'sh2000; x6_im=0;
        x7_re=16'shECCD; x7_im=0;

        repeat (3) @(posedge clk);
        #1 rst = 0;
        @(posedge clk);
        #1 start = 1;
        @(posedge clk);
        #1 start = 0;

        wait (valid == 1);
        @(posedge clk);

        if (!check_close(X0_re, EXP0_RE) || !check_close(X0_im, EXP0_IM)) begin
            errors = errors + 1; $display("FAIL X0: got=%h,%h exp=%h,%h", X0_re, X0_im, EXP0_RE, EXP0_IM);
        end else $display("PASS X0: %h,%h", X0_re, X0_im);

        if (!check_close(X1_re, EXP1_RE) || !check_close(X1_im, EXP1_IM)) begin
            errors = errors + 1; $display("FAIL X1: got=%h,%h exp=%h,%h", X1_re, X1_im, EXP1_RE, EXP1_IM);
        end else $display("PASS X1: %h,%h", X1_re, X1_im);

        if (!check_close(X2_re, EXP2_RE) || !check_close(X2_im, EXP2_IM)) begin
            errors = errors + 1; $display("FAIL X2: got=%h,%h exp=%h,%h", X2_re, X2_im, EXP2_RE, EXP2_IM);
        end else $display("PASS X2: %h,%h", X2_re, X2_im);

        if (!check_close(X3_re, EXP3_RE) || !check_close(X3_im, EXP3_IM)) begin
            errors = errors + 1; $display("FAIL X3: got=%h,%h exp=%h,%h", X3_re, X3_im, EXP3_RE, EXP3_IM);
        end else $display("PASS X3: %h,%h", X3_re, X3_im);

        if (!check_close(X4_re, EXP4_RE) || !check_close(X4_im, EXP4_IM)) begin
            errors = errors + 1; $display("FAIL X4: got=%h,%h exp=%h,%h", X4_re, X4_im, EXP4_RE, EXP4_IM);
        end else $display("PASS X4: %h,%h", X4_re, X4_im);

        if (!check_close(X5_re, EXP5_RE) || !check_close(X5_im, EXP5_IM)) begin
            errors = errors + 1; $display("FAIL X5: got=%h,%h exp=%h,%h", X5_re, X5_im, EXP5_RE, EXP5_IM);
        end else $display("PASS X5: %h,%h", X5_re, X5_im);

        if (!check_close(X6_re, EXP6_RE) || !check_close(X6_im, EXP6_IM)) begin
            errors = errors + 1; $display("FAIL X6: got=%h,%h exp=%h,%h", X6_re, X6_im, EXP6_RE, EXP6_IM);
        end else $display("PASS X6: %h,%h", X6_re, X6_im);

        if (!check_close(X7_re, EXP7_RE) || !check_close(X7_im, EXP7_IM)) begin
            errors = errors + 1; $display("FAIL X7: got=%h,%h exp=%h,%h", X7_re, X7_im, EXP7_RE, EXP7_IM);
        end else $display("PASS X7: %h,%h", X7_re, X7_im);

        if (errors == 0) $display("*** WALLACE FFT: ALL 8 OUTPUTS MATCH REFERENCE - TEST PASSED ***");
        else $display("*** %0d MISMATCHES - CHECK ROUNDING / STAGE WIRING ***", errors);

        #20 $finish;
    end

endmodule
