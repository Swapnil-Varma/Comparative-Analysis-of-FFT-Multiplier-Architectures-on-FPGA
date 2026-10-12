// Basys 3 signed decimal display for a 32-bit Booth multiplier.
// Mapping: seg[0]=a/W7, seg[1]=b/W6, seg[2]=c/U8, seg[3]=d/V8,
// seg[4]=e/U5, seg[5]=f/V5, seg[6]=g/U7. Segment and AN signals active-low.
// Positive results 0..9999 display as 4 digits (leading zeros).
// Negative results -1..-999 display as -xxx.
// Values outside those ranges display OL.
module decimal_overload_display (
    input  wire               clk,
    input  wire signed [31:0]  product,
    input  wire               valid,
    output reg  [6:0]         seg,
    output wire               dp,
    output reg  [3:0]         an
);
    reg [19:0] refresh = 20'd0;
    reg [15:0] digits;
    reg [3:0] digit;
    reg [31:0] magnitude;
    integer thousands, hundreds, tens, ones;

    // A = O, B = L, C = blank, D = minus sign.
    // digits[15:12] is leftmost AN3; digits[3:0] is rightmost AN0.
    always @(*) begin
        digits = 16'hCCCC;
        magnitude = 32'd0;
        thousands = 0;
        hundreds = 0;
        tens = 0;
        ones = 0;

        if (valid) begin
            if (product < 0) begin
                magnitude = -product;
                if (magnitude <= 32'd999) begin
                    // Left-to-right: minus, hundreds, tens, ones.
                    hundreds = magnitude / 100;
                    tens     = (magnitude / 10) % 10;
                    ones     = magnitude % 10;
                    digits = {4'd13, hundreds[3:0], tens[3:0], ones[3:0]};
                end else begin
                    digits = 16'hABCC; // OL
                end
            end else if (product > 32'd9999) begin
                digits = 16'hABCC; // OL
            end else begin
                thousands = product / 1000;
                hundreds  = (product / 100) % 10;
                tens      = (product / 10) % 10;
                ones      = product % 10;
                digits = {thousands[3:0], hundreds[3:0],
                          tens[3:0], ones[3:0]};
            end
        end
    end

    always @(posedge clk)
        refresh <= refresh + 1'b1;

    always @(*) begin
        case (refresh[19:18])
            2'b00: begin an = 4'b1110; digit = digits[3:0];   end
            2'b01: begin an = 4'b1101; digit = digits[7:4];   end
            2'b10: begin an = 4'b1011; digit = digits[11:8]; end
            default: begin an = 4'b0111; digit = digits[15:12]; end
        endcase

        // Active-low patterns; seg[6:0] = gfedcba.
        case (digit)
            4'd0:  seg = 7'b1000000;
            4'd1:  seg = 7'b1111001;
            4'd2:  seg = 7'b0100100;
            4'd3:  seg = 7'b0110000;
            4'd4:  seg = 7'b0011001;
            4'd5:  seg = 7'b0010010;
            4'd6:  seg = 7'b0000010;
            4'd7:  seg = 7'b1111000;
            4'd8:  seg = 7'b0000000;
            4'd9:  seg = 7'b0010000;
            4'd10: seg = 7'b1000000; // O approximated by 0
            4'd11: seg = 7'b1000111; // L
            4'd13: seg = 7'b0111111; // minus sign (g segment on)
            default: seg = 7'b1111111; // blank
        endcase
    end

    assign dp = 1'b1;
endmodule
