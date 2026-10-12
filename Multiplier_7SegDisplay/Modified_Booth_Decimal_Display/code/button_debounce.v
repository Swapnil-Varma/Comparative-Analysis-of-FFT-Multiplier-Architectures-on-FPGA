module button_debounce #(
    parameter integer DEBOUNCE_CYCLES = 1_000_000
) (
    input wire clk,
    input wire button_in,
    output reg button_out = 1'b0
);
    localparam integer COUNT_WIDTH =
        (DEBOUNCE_CYCLES <= 1) ? 1 : $clog2(DEBOUNCE_CYCLES + 1);
    reg sync1 = 1'b0;
    reg sync2 = 1'b0;
    reg [COUNT_WIDTH-1:0] count = 0;

    always @(posedge clk) begin
        sync1 <= button_in;
        sync2 <= sync1;
        if (sync2 == button_out) begin
            count <= 0;
        end else if ((DEBOUNCE_CYCLES <= 1) ||
                     (count >= DEBOUNCE_CYCLES-1)) begin
            button_out <= sync2;
            count <= 0;
        end else begin
            count <= count + 1'b1;
        end
    end
endmodule
