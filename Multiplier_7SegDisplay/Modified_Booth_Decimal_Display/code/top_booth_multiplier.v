// Basys 3 top-level for signed sequential Booth multiplier.
// Set signed A on SW[15:0], press/release BTNU; set signed B and press BTNU.
// Inputs are 16-bit two's-complement signed values.
// LD[15:0] show product[15:0]. Seven-segment displays decimal/negative/OL.
// BTNC resets input sequence and multiplier.
module top_booth_multiplier #(
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
    reg signed [15:0] a_reg = 16'sd0;
    reg signed [15:0] b_reg = 16'sd0;
    reg load_b = 1'b0;
    reg start_mul = 1'b0;
    reg valid = 1'b0;
    reg busy = 1'b0;

    wire start_clean;
    reg start_prev = 1'b0;
    wire start_pulse;
    wire signed [31:0] product;
    wire done;

    button_debounce #(.DEBOUNCE_CYCLES(DEBOUNCE_CYCLES)) U_START_DEBOUNCE (
        .clk(clk), .button_in(btn_start), .button_out(start_clean)
    );
    assign start_pulse = start_clean & ~start_prev;

    always @(posedge clk) begin
        start_prev <= start_clean;
        start_mul <= 1'b0;

        if (btn_rst) begin
            a_reg <= 16'sd0;
            b_reg <= 16'sd0;
            load_b <= 1'b0;
            start_mul <= 1'b0;
            valid <= 1'b0;
            busy <= 1'b0;
        end else begin
            if (start_pulse && !busy) begin
                if (!load_b) begin
                    a_reg <= $signed(sw);
                    load_b <= 1'b1;
                    valid <= 1'b0;
                end else begin
                    b_reg <= $signed(sw);
                    load_b <= 1'b0;
                    start_mul <= 1'b1;
                    busy <= 1'b1;
                    valid <= 1'b0;
                end
            end

            if (done) begin
                busy <= 1'b0;
                valid <= 1'b1;
            end
        end
    end

    booth_multiplier U_BOOTH (
        .clk(clk),
        .rst(btn_rst),
        .start(start_mul),
        .multiplicand(a_reg),
        .multiplier(b_reg),
        .product(product),
        .done(done)
    );

    assign led = valid ? product[15:0] : 16'b0;

    decimal_overload_display U_DISPLAY (
        .clk(clk), .product(product), .valid(valid),
        .seg(seg), .dp(dp), .an(an)
    );
endmodule
