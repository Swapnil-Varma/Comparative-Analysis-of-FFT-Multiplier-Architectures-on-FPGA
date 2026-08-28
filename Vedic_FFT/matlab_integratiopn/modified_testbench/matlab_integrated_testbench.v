// fft8_tb.v
// MATLAB-integrated testbench for the VEDIC-multiplier 8-point FFT.
//
// Function:
// 1. Applies a fixed Q1.15 input vector.
// 2. Runs the Vedic FFT RTL.
// 3. Waits for the valid signal.
// 4. Writes the 8 FFT outputs to fft_output.csv.
// 5. MATLAB can read the same input vector and compare
//    the RTL result against MATLAB fft().
//
// CSV format:
// Bin,Real,Imaginary
// 0,...,...
// 1,...,...
// ...
// 7,...,...

`timescale 1ns/1ps

module fft8_tb;

    reg clk = 0;
    reg rst = 1;
    reg start = 0;

    // ============================================================
    // 8-point complex input
    // ============================================================

    reg signed [15:0] x0_re, x0_im;
    reg signed [15:0] x1_re, x1_im;
    reg signed [15:0] x2_re, x2_im;
    reg signed [15:0] x3_re, x3_im;
    reg signed [15:0] x4_re, x4_im;
    reg signed [15:0] x5_re, x5_im;
    reg signed [15:0] x6_re, x6_im;
    reg signed [15:0] x7_re, x7_im;

    // ============================================================
    // FFT outputs
    // ============================================================

    wire signed [15:0] X0_re, X0_im;
    wire signed [15:0] X1_re, X1_im;
    wire signed [15:0] X2_re, X2_im;
    wire signed [15:0] X3_re, X3_im;
    wire signed [15:0] X4_re, X4_im;
    wire signed [15:0] X5_re, X5_im;
    wire signed [15:0] X6_re, X6_im;
    wire signed [15:0] X7_re, X7_im;

    wire valid;

    // ============================================================
    // Clock
    // ============================================================

    always #5 clk = ~clk;

    // ============================================================
    // DUT
    // VEDIC multiplier FFT
    // ============================================================

    fft8_top #(.MULT_TYPE("VEDIC")) dut (
        .clk(clk),
        .rst(rst),
        .start(start),

        .x0_re(x0_re),
        .x0_im(x0_im),

        .x1_re(x1_re),
        .x1_im(x1_im),

        .x2_re(x2_re),
        .x2_im(x2_im),

        .x3_re(x3_re),
        .x3_im(x3_im),

        .x4_re(x4_re),
        .x4_im(x4_im),

        .x5_re(x5_re),
        .x5_im(x5_im),

        .x6_re(x6_re),
        .x6_im(x6_im),

        .x7_re(x7_re),
        .x7_im(x7_im),

        .X0_re(X0_re),
        .X0_im(X0_im),

        .X1_re(X1_re),
        .X1_im(X1_im),

        .X2_re(X2_re),
        .X2_im(X2_im),

        .X3_re(X3_re),
        .X3_im(X3_im),

        .X4_re(X4_re),
        .X4_im(X4_im),

        .X5_re(X5_re),
        .X5_im(X5_im),

        .X6_re(X6_re),
        .X6_im(X6_im),

        .X7_re(X7_re),
        .X7_im(X7_im),

        .valid(valid)
    );

    // ============================================================
    // CSV file
    // ============================================================

    integer csv_file;

    // ============================================================
    // Q1.15 conversion
    //
    // Verilog signed 16-bit:
    //     32767 -> +0.99997
    //    -32768 -> -1.00000
    //
    // MATLAB will therefore receive the same numerical values
    // used by the RTL.
    // ============================================================

    real rX0_re, rX0_im;
    real rX1_re, rX1_im;
    real rX2_re, rX2_im;
    real rX3_re, rX3_im;
    real rX4_re, rX4_im;
    real rX5_re, rX5_im;
    real rX6_re, rX6_im;
    real rX7_re, rX7_im;

    // ============================================================
    // Main simulation
    // ============================================================

    initial begin

        // --------------------------------------------------------
        // Initialize
        // --------------------------------------------------------

        rst   = 1;
        start = 0;

        x0_re = 16'sh0CCD;
        x0_im = 16'sh0000;

        x1_re = 16'sh199A;
        x1_im = 16'sh0000;

        x2_re = 16'shF333;
        x2_im = 16'sh0000;

        x3_re = 16'sh1333;
        x3_im = 16'sh0000;

        x4_re = 16'shE666;
        x4_im = 16'sh0000;

        x5_re = 16'sh0666;
        x5_im = 16'sh0000;

        x6_re = 16'sh2000;
        x6_im = 16'sh0000;

        x7_re = 16'shECCD;
        x7_im = 16'sh0000;


        // --------------------------------------------------------
        // Reset
        // --------------------------------------------------------

        repeat (3) @(posedge clk);

        #1 rst = 0;


        // --------------------------------------------------------
        // Start FFT
        // --------------------------------------------------------

        @(posedge clk);
        #1 start = 1;

        @(posedge clk);
        #1 start = 0;


        // --------------------------------------------------------
        // Wait for FFT completion
        // --------------------------------------------------------

        wait (valid == 1);

        @(posedge clk);


        // --------------------------------------------------------
        // Convert RTL Q1.15 outputs to real numbers
        // --------------------------------------------------------

        rX0_re = $itor(X0_re) / 32768.0;
        rX0_im = $itor(X0_im) / 32768.0;

        rX1_re = $itor(X1_re) / 32768.0;
        rX1_im = $itor(X1_im) / 32768.0;

        rX2_re = $itor(X2_re) / 32768.0;
        rX2_im = $itor(X2_im) / 32768.0;

        rX3_re = $itor(X3_re) / 32768.0;
        rX3_im = $itor(X3_im) / 32768.0;

        rX4_re = $itor(X4_re) / 32768.0;
        rX4_im = $itor(X4_im) / 32768.0;

        rX5_re = $itor(X5_re) / 32768.0;
        rX5_im = $itor(X5_im) / 32768.0;

        rX6_re = $itor(X6_re) / 32768.0;
        rX6_im = $itor(X6_im) / 32768.0;

        rX7_re = $itor(X7_re) / 32768.0;
        rX7_im = $itor(X7_im) / 32768.0;


        // --------------------------------------------------------
        // Display results
        // --------------------------------------------------------

        $display("");
        $display("===============================================");
        $display("       VEDIC MULTIPLIER FFT RESULTS");
        $display("===============================================");

        $display("X0 = %h , %h", X0_re, X0_im);
        $display("X1 = %h , %h", X1_re, X1_im);
        $display("X2 = %h , %h", X2_re, X2_im);
        $display("X3 = %h , %h", X3_re, X3_im);
        $display("X4 = %h , %h", X4_re, X4_im);
        $display("X5 = %h , %h", X5_re, X5_im);
        $display("X6 = %h , %h", X6_re, X6_im);
        $display("X7 = %h , %h", X7_re, X7_im);


        // --------------------------------------------------------
        // Open CSV file
        // --------------------------------------------------------

        csv_file = $fopen("fft_output.csv", "w");

        if (csv_file == 0) begin
            $display("ERROR: Could not create fft_output.csv");
            $finish;
        end


        // --------------------------------------------------------
        // CSV header
        // --------------------------------------------------------

        $fwrite(csv_file, "Bin,Real,Imaginary\n");


        // --------------------------------------------------------
        // Write FFT outputs
        // --------------------------------------------------------

        $fwrite(csv_file, "0,%.10f,%.10f\n", rX0_re, rX0_im);
        $fwrite(csv_file, "1,%.10f,%.10f\n", rX1_re, rX1_im);
        $fwrite(csv_file, "2,%.10f,%.10f\n", rX2_re, rX2_im);
        $fwrite(csv_file, "3,%.10f,%.10f\n", rX3_re, rX3_im);
        $fwrite(csv_file, "4,%.10f,%.10f\n", rX4_re, rX4_im);
        $fwrite(csv_file, "5,%.10f,%.10f\n", rX5_re, rX5_im);
        $fwrite(csv_file, "6,%.10f,%.10f\n", rX6_re, rX6_im);
        $fwrite(csv_file, "7,%.10f,%.10f\n", rX7_re, rX7_im);


        $fclose(csv_file);


        // --------------------------------------------------------
        // Confirmation
        // --------------------------------------------------------

        $display("");
        $display("===============================================");
        $display("FFT results written to fft_output.csv");
        $display("Use MATLAB fft() to compare RTL and software.");
        $display("===============================================");
        $display("");


        #20 $finish;

    end

endmodule