// Basys 3 top-level module.
// Input procedure:
// 1) Set SW[15:0] to A and press/release BTNU.
// 2) Set SW[15:0] to B and press/release BTNU.
// LEDs show product[15:0]. Seven-segment display shows decimal 0000..9999,
// or O L when the full 32-bit product is greater than 9999.
// BTNC resets the operand-entry state and blanks the display/LEDs.
module top_array_multiplier #(
    parameter integer DEBOUNCE_COUNT = 1_999_999
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
    wire rst_db;
    wire start_db;
    reg start_prev = 1'b0;
    wire start_press;

    reg [15:0] a_reg = 16'd0;
    reg [15:0] b_reg = 16'd0;
    reg load_b = 1'b0;
    reg valid = 1'b0;
    wire [31:0] product;

    button_debounce #(.COUNTER_MAX(DEBOUNCE_COUNT)) U_RST_DB (
        .clk(clk), .btn_in(btn_rst), .btn_out(rst_db)
    );
    button_debounce #(.COUNTER_MAX(DEBOUNCE_COUNT)) U_START_DB (
        .clk(clk), .btn_in(btn_start), .btn_out(start_db)
    );

    // Convert debounced button level to a one-clock rising-edge pulse.
    always @(posedge clk) begin
        start_prev <= start_db;
    end
    assign start_press = start_db & ~start_prev;

    always @(posedge clk) begin
        if (rst_db) begin
            a_reg  <= 16'd0;
            b_reg  <= 16'd0;
            load_b <= 1'b0;
            valid  <= 1'b0;
        end else if (start_press) begin
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

    // Existing multiplier module and its logic are unchanged.
    array_multiplier U_ARRAY (
        .a(a_reg),
        .b(b_reg),
        .product(product)
    );

    // Keep original LED behavior: lower 16 bits only.
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
