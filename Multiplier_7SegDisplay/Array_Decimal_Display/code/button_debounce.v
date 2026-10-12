// Synchronizes and debounces an active-high push button.
// COUNTER_MAX=1,999,999 gives approximately 20 ms at 100 MHz.
module button_debounce #(
    parameter integer COUNTER_MAX = 1_999_999
) (
    input  wire clk,
    input  wire btn_in,
    output reg  btn_out = 1'b0
);
    reg sync_1 = 1'b0;
    reg sync_2 = 1'b0;
    reg [31:0] count = 32'd0;
    reg stable_sample = 1'b0;

    always @(posedge clk) begin
        sync_1 <= btn_in;
        sync_2 <= sync_1;

        if (sync_2 == stable_sample) begin
            count <= 32'd0;
        end else if (count >= COUNTER_MAX) begin
            count <= 32'd0;
            stable_sample <= sync_2;
            btn_out <= sync_2;
        end else begin
            count <= count + 1'b1;
        end
    end
endmodule
