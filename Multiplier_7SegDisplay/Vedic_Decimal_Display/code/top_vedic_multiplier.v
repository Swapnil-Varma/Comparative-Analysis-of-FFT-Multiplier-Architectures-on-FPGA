// Basys 3 top module for the user's 16x16 Vedic multiplier.
// Workflow:
//   1. Set A on SW[15:0], press BTNU.
//   2. Set B on SW[15:0], press BTNU again.
//   3. LEDs show product[15:0].
//   4. Seven-segment display shows decimal product if <=9999, otherwise OL.
// BTNC resets the input-entry sequence and blanks the outputs.
module top_vedic_multiplier #(
    parameter integer DEBOUNCE_CYCLES = 1_000_000
) (
    input  wire        clk,
    input  wire        btn_rst,
    input  wire        btn_start,
    input  wire [15:0] sw,
    output wire [15:0] led,
    output wire [6:0]  seg,
    output wire        dp,
    output wire [3:0]  an
);
    reg [15:0] a_reg = 16'd0;
    reg [15:0] b_reg = 16'd0;
    reg load_b = 1'b0;
    reg valid = 1'b0;

    wire start_clean;
    reg start_prev = 1'b0;
    wire start_pulse;

    wire [31:0] product;

    button_debounce #(
        .DEBOUNCE_CYCLES(DEBOUNCE_CYCLES)
    ) U_START_DEBOUNCE (
        .clk(clk),
        .button_in(btn_start),
        .button_out(start_clean)
    );

    assign start_pulse = start_clean & ~start_prev;

    always @(posedge clk) begin
        start_prev <= start_clean;

        if (btn_rst) begin
            a_reg  <= 16'd0;
            b_reg  <= 16'd0;
            load_b <= 1'b0;
            valid  <= 1'b0;
        end else if (start_pulse) begin
            if (!load_b) begin
                a_reg  <= sw;
                load_b <= 1'b1;
                valid  <= 1'b0;
            end else begin
                b_reg  <= sw;
                load_b <= 1'b0;
                valid  <= 1'b1;
            end
        end
    end

    vedic_multiplier U_VEDIC (
        .a(a_reg),
        .b(b_reg),
        .product(product)
    );

    // Keep the original LED behavior: low 16 product bits.
    assign led = valid ? product[15:0] : 16'b0;

    decimal_overload_display U_DISPLAY (
        .clk(clk),
        .product(product),
        .valid(valid),
        .seg(seg),
        .dp(dp),
        .an(an)
    );
endmodule
