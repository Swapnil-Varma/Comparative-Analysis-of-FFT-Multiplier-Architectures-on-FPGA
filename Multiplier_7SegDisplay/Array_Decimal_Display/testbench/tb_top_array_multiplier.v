`timescale 1ns/1ps

// Integration test with shortened debounce counters for simulation only.
module tb_top_array_multiplier;
    reg clk = 0;
    reg btn_rst = 0;
    reg btn_start = 0;
    reg [15:0] sw = 0;
    wire [15:0] led;
    wire [6:0] seg;
    wire dp;
    wire [3:0] an;

    top_array_multiplier #(.DEBOUNCE_COUNT(3)) DUT (
        .clk(clk), .btn_rst(btn_rst), .btn_start(btn_start), .sw(sw),
        .led(led), .seg(seg), .dp(dp), .an(an)
    );

    always #5 clk = ~clk;

    task press_start;
        begin
            @(negedge clk); btn_start = 1'b1;
            repeat (12) @(negedge clk);
            btn_start = 1'b0;
            repeat (12) @(negedge clk);
        end
    endtask

    task load_pair;
        input [15:0] a;
        input [15:0] b;
        input [31:0] expected;
        begin
            sw = a; press_start();
            sw = b; press_start();
            #1;
            if (DUT.product !== expected)
                $display("FAIL: %0d x %0d got %0d expected %0d", a, b, DUT.product, expected);
            else
                $display("PASS: %0d x %0d = %0d; LEDs=%h", a, b, DUT.product, led);
        end
    endtask

    initial begin
        // Allow button synchronizers to settle.
        repeat (10) @(negedge clk);
        load_pair(16'd12, 16'd10, 32'd120);       // decimal 0120
        load_pair(16'd100, 16'd100, 32'd10000);   // overload OL
        load_pair(16'hFFFF, 16'hFFFF, 32'hFFFE0001); // overload OL
        $display("Integration checks complete. Inspect display multiplexing in waveform/hardware.");
        $finish;
    end
endmodule
