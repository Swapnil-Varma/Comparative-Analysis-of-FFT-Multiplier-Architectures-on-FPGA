`timescale 1ns/1ps
module tb_top_vedic_multiplier;
    reg clk = 0;
    reg btn_rst = 0;
    reg btn_start = 0;
    reg [15:0] sw = 0;
    wire [15:0] led;
    wire [6:0] seg;
    wire dp;
    wire [3:0] an;

    // Small debounce interval for simulation only.
    top_vedic_multiplier #(.DEBOUNCE_CYCLES(3)) DUT (
        .clk(clk), .btn_rst(btn_rst), .btn_start(btn_start), .sw(sw),
        .led(led), .seg(seg), .dp(dp), .an(an)
    );

    always #5 clk = ~clk;

    task press_start;
        begin
            @(negedge clk); btn_start = 1'b1;
            repeat (8) @(negedge clk);
            btn_start = 1'b0;
            repeat (8) @(negedge clk);
        end
    endtask

    initial begin
        btn_rst = 1'b1;
        repeat (3) @(negedge clk);
        btn_rst = 1'b0;

        // A=12
        sw = 16'd12;
        press_start();

        // B=13; product=156 -> decimal display should read 0156.
        sw = 16'd13;
        press_start();
        #1;
        if (led !== 16'd156)
            $display("FAIL top LED: got %0d expected 156", led);
        else
            $display("PASS top LED: product 156");

        // Reset and test overload: 100 * 100 = 10000 -> OL.
        @(negedge clk); btn_rst = 1'b1;
        repeat (3) @(negedge clk);
        btn_rst = 1'b0;

        sw = 16'd100;
        press_start();
        sw = 16'd100;
        press_start();
        #1;
        if (led !== 16'd10000)
            $display("FAIL overload LED: got %0d expected 10000", led);
        else
            $display("PASS overload LED: product 10000; display should show OL");

        $display("Top-level integration simulation finished.");
        $finish;
    end
endmodule
