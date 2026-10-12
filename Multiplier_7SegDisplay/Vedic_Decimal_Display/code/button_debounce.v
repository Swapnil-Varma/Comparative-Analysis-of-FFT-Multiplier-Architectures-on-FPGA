// Active-high push-button debouncer for the 100 MHz Basys 3 clock.
// A debounced level changes only after the raw input remains stable for
// DEBOUNCE_CYCLES clock cycles.
module button_debounce #(
    parameter integer DEBOUNCE_CYCLES = 1_000_000
) (
    input  wire clk,
    input  wire button_in,
    output reg  button_out = 1'b0
);
    localparam integer COUNT_WIDTH =
        (DEBOUNCE_CYCLES <= 1) ? 1 : $clog2(DEBOUNCE_CYCLES + 1);

    reg sync1 = 1'b0;
    reg sync2 = 1'b0;
    reg [COUNT_WIDTH-1:0] count = {COUNT_WIDTH{1'b0}};

    always @(posedge clk) begin
        sync1 <= button_in;
        sync2 <= sync1;

        if (sync2 == button_out) begin
            count <= {COUNT_WIDTH{1'b0}};
        end else if (DEBOUNCE_CYCLES <= 1 || count >= DEBOUNCE_CYCLES-1) begin
            button_out <= sync2;
            count <= {COUNT_WIDTH{1'b0}};
        end else begin
            count <= count + 1'b1;
        end
    end
endmodule
