// fft8_audio2_tb.v
// Stage 4 demo (two-tone version): a signal made of TWO distinct
// frequencies (1000 Hz + 2000 Hz) shows the FFT genuinely separating
// them into two distinct output peaks - a more convincing demonstration
// than a single tone, which only shows the FFT finding the one obvious
// frequency you put in.
//
// Both frequencies are deliberately chosen as exact multiples of the
// bin spacing (Fs/N = 8000/8 = 1000 Hz), so each lands exactly on a
// bin center with no spectral leakage - this is what keeps the result
// clean (two sharp peaks) instead of smeared across several bins,
// which an 8-point FFT's coarse resolution would otherwise cause for
// arbitrary (non-bin-aligned) frequencies.
//
// Amplitude (0.1 per tone) was chosen so the combined signal's DFT
// output stays safely under the Q1.15 range - see project notes for
// the overflow-margin check behind this (worst-case bin magnitude 0.4,
// well under the 1.0 limit).
//
// Expected values were captured directly from this same RTL running
// this exact input (a real verified hardware result), cross-checked
// against a NumPy reference.

`timescale 1ns/1ps

module fft8_audio2_tb;

    reg clk = 0;
    reg rst = 1;
    reg start = 0;

    reg signed [15:0] x0_re, x0_im, x1_re, x1_im, x2_re, x2_im, x3_re, x3_im;
    reg signed [15:0] x4_re, x4_im, x5_re, x5_im, x6_re, x6_im, x7_re, x7_im;

    wire signed [15:0] X0_re, X0_im, X1_re, X1_im, X2_re, X2_im, X3_re, X3_im;
    wire signed [15:0] X4_re, X4_im, X5_re, X5_im, X6_re, X6_im, X7_re, X7_im;
    wire valid;

    always #5 clk = ~clk;

    integer file;

    function real q15_to_real;
        input signed [15:0] value;
        integer temp;
        begin
            temp = value;
            q15_to_real = temp / 32768.0;
        end
    endfunction

    initial begin
        #2000;
        $display("*** WATCHDOG TIMEOUT - valid never asserted ***");
        if (file != 0) $fclose(file);
        $finish;
    end

    // Change MULT_TYPE to "VEDIC" / "WALLACE" / "BOOTH" to demo any variant
    fft8_top #(.MULT_TYPE("ARRAY")) dut (
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

    // Golden reference captured from this actual RTL running this input
    localparam signed [15:0] EXP0_RE=16'h0000, EXP0_IM=16'h0000;
    localparam signed [15:0] EXP1_RE=16'h0000, EXP1_IM=16'hCCCD;
    localparam signed [15:0] EXP2_RE=16'h0000, EXP2_IM=16'hCCCC;
    localparam signed [15:0] EXP3_RE=16'h0000, EXP3_IM=16'h0001;
    localparam signed [15:0] EXP4_RE=16'h0000, EXP4_IM=16'h0000;
    localparam signed [15:0] EXP5_RE=16'h0000, EXP5_IM=16'hFFFF;
    localparam signed [15:0] EXP6_RE=16'h0000, EXP6_IM=16'h3334;
    localparam signed [15:0] EXP7_RE=16'h0000, EXP7_IM=16'h3333;

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
        file = 0;
        file = $fopen("audio2_fft_output.csv", "w");
        if (file == 0) begin
            $display("*** ERROR: Cannot create audio2_fft_output.csv ***");
            $finish;
        end
        $fwrite(file, "Bin,Real,Imaginary\n");

        rst = 1; start = 0;

        // 1000 Hz (amp 0.1) + 2000 Hz (amp 0.1) tones, 8 samples @ Fs=8000Hz
        x0_re = 16'h0000; x0_im = 0;
        x1_re = 16'h15DA; x1_im = 0;
        x2_re = 16'h0CCD; x2_im = 0;
        x3_re = 16'hFC40; x3_im = 0;
        x4_re = 16'h0000; x4_im = 0;
        x5_re = 16'h03C0; x5_im = 0;
        x6_re = 16'hF333; x6_im = 0;
        x7_re = 16'hEA26; x7_im = 0;

        repeat (3) @(posedge clk);
        #1 rst = 0;
        @(posedge clk);
        #1 start = 1;
        @(posedge clk);
        #1 start = 0;

        wait (valid == 1);
        @(posedge clk);

        $display("");
        $display("======================================================");
        $display(" STAGE 4: 1000Hz + 2000Hz TONES -> FREQUENCY DOMAIN");
        $display("======================================================");
        $display("Bin       Real              Imaginary");
        $display("------------------------------------------------------");
        $display("X0     %f       %f", q15_to_real(X0_re), q15_to_real(X0_im));
        $display("X1     %f       %f", q15_to_real(X1_re), q15_to_real(X1_im));
        $display("X2     %f       %f", q15_to_real(X2_re), q15_to_real(X2_im));
        $display("X3     %f       %f", q15_to_real(X3_re), q15_to_real(X3_im));
        $display("X4     %f       %f", q15_to_real(X4_re), q15_to_real(X4_im));
        $display("X5     %f       %f", q15_to_real(X5_re), q15_to_real(X5_im));
        $display("X6     %f       %f", q15_to_real(X6_re), q15_to_real(X6_im));
        $display("X7     %f       %f", q15_to_real(X7_re), q15_to_real(X7_im));
        $display("======================================================");
        $display("Note: TWO distinct peaks expected - X1/X7 (1000 Hz) and");
        $display("X2/X6 (2000 Hz) - showing the FFT genuinely separating");
        $display("two frequency components, not just finding one obvious tone.");

        $fwrite(file, "0,%f,%f\n", q15_to_real(X0_re), q15_to_real(X0_im));
        $fwrite(file, "1,%f,%f\n", q15_to_real(X1_re), q15_to_real(X1_im));
        $fwrite(file, "2,%f,%f\n", q15_to_real(X2_re), q15_to_real(X2_im));
        $fwrite(file, "3,%f,%f\n", q15_to_real(X3_re), q15_to_real(X3_im));
        $fwrite(file, "4,%f,%f\n", q15_to_real(X4_re), q15_to_real(X4_im));
        $fwrite(file, "5,%f,%f\n", q15_to_real(X5_re), q15_to_real(X5_im));
        $fwrite(file, "6,%f,%f\n", q15_to_real(X6_re), q15_to_real(X6_im));
        $fwrite(file, "7,%f,%f\n", q15_to_real(X7_re), q15_to_real(X7_im));
        $fflush(file);
        $fclose(file);
        file = 0;

        $display("");
        $display("*** AUDIO FFT DATA SAVED TO audio2_fft_output.csv ***");
        $display("");

        if (!check_close(X0_re, EXP0_RE) || !check_close(X0_im, EXP0_IM)) begin
            errors=errors+1; $display("FAIL X0"); end else $display("PASS X0");
        if (!check_close(X1_re, EXP1_RE) || !check_close(X1_im, EXP1_IM)) begin
            errors=errors+1; $display("FAIL X1"); end else $display("PASS X1");
        if (!check_close(X2_re, EXP2_RE) || !check_close(X2_im, EXP2_IM)) begin
            errors=errors+1; $display("FAIL X2"); end else $display("PASS X2");
        if (!check_close(X3_re, EXP3_RE) || !check_close(X3_im, EXP3_IM)) begin
            errors=errors+1; $display("FAIL X3"); end else $display("PASS X3");
        if (!check_close(X4_re, EXP4_RE) || !check_close(X4_im, EXP4_IM)) begin
            errors=errors+1; $display("FAIL X4"); end else $display("PASS X4");
        if (!check_close(X5_re, EXP5_RE) || !check_close(X5_im, EXP5_IM)) begin
            errors=errors+1; $display("FAIL X5"); end else $display("PASS X5");
        if (!check_close(X6_re, EXP6_RE) || !check_close(X6_im, EXP6_IM)) begin
            errors=errors+1; $display("FAIL X6"); end else $display("PASS X6");
        if (!check_close(X7_re, EXP7_RE) || !check_close(X7_im, EXP7_IM)) begin
            errors=errors+1; $display("FAIL X7"); end else $display("PASS X7");

        if (errors == 0) $display("*** ALL 8 OUTPUTS MATCH - TWO-TONE DEMO TEST PASSED ***");
        else $display("*** %0d MISMATCHES ***", errors);

        #20 $finish;
    end

endmodule
