// Corrected Basys 3 decimal/overload display driver.
// XDC mapping: seg[0]=segment a, seg[1]=b, ... seg[6]=g.
// Therefore bit patterns below are written in g,f,e,d,c,b,a vector order.
// Segment outputs and digit enables are active-low.
module decimal_overload_display (
    input  wire        clk,
    input  wire [31:0] product,
    input  wire        valid,
    output reg  [6:0]  seg,
    output wire        dp,
    output reg  [3:0]  an
);
    reg [19:0] refresh = 20'd0;
    reg [15:0] digits;
    reg [3:0] digit;

    integer thousands;
    integer hundreds;
    integer tens;
    integer ones;

    always @(*) begin
        digits    = 16'hCCCC; // blank digits
        thousands = 0;
        hundreds  = 0;
        tens      = 0;
        ones      = 0;

        if (valid) begin
            if (product > 32'd9999) begin
                // Physical left-to-right: O, L, blank, blank
                // AN3 uses digits[15:12], AN0 uses digits[3:0].
                digits = 16'hABCC;
            end else begin
                thousands = product / 1000;
                hundreds  = (product / 100) % 10;
                tens      = (product / 10) % 10;
                ones      = product % 10;

                digits = {
                    thousands[3:0],
                    hundreds[3:0],
                    tens[3:0],
                    ones[3:0]
                };
            end
        end
    end

    always @(posedge clk)
        refresh <= refresh + 1'b1;

    always @(*) begin
        case (refresh[19:18])
            2'b00: begin an = 4'b1110; digit = digits[3:0];   end // AN0, rightmost
            2'b01: begin an = 4'b1101; digit = digits[7:4];   end
            2'b10: begin an = 4'b1011; digit = digits[11:8];  end
            default: begin an = 4'b0111; digit = digits[15:12]; end // AN3, leftmost
        endcase

        // seg[0]=a, seg[1]=b, ... seg[6]=g in the XDC.
        // In the 7-bit literal, the leftmost bit is seg[6]=g.
        case (digit)
            4'd0:  seg = 7'b0000001;
            4'd1:  seg = 7'b1001111;
            4'd2:  seg = 7'b0010010;
            4'd3:  seg = 7'b0000110;
            4'd4:  seg = 7'b1001100;
            4'd5:  seg = 7'b0100100;
            4'd6:  seg = 7'b0100000;
            4'd7:  seg = 7'b0001111;
            4'd8:  seg = 7'b0000000;
            4'd9:  seg = 7'b0000100;
            4'd10: seg = 7'b0000001; // O resembles 0
            4'd11: seg = 7'b1110001; // L in a,b,c,d,e,f,g notation
            default: seg = 7'b1111111; // blank
        endcase
    end

    assign dp = 1'b1;
endmodule
