// Four-digit decimal display for Basys 3.
// Products 0..9999 display as decimal with leading zeros.
// Products above 9999 display O L _ _ (O is represented by digit 0).
// Segment outputs are active-low. an[0] is the rightmost digit.
module decimal_overload_display (
    input  wire        clk,
    input  wire [31:0] product,
    input  wire        valid,
    output reg  [6:0]  seg,
    output wire        dp,
    output reg  [3:0]  an
);
    reg [19:0] refresh = 20'd0;
    reg [3:0] thousands;
    reg [3:0] hundreds;
    reg [3:0] tens;
    reg [3:0] ones;
    reg [3:0] digit;
    integer value_int;

    always @(posedge clk)
        refresh <= refresh + 1'b1;

    always @* begin
        // Default blank display before operands are entered.
        thousands = 4'hC;
        hundreds  = 4'hC;
        tens      = 4'hC;
        ones      = 4'hC;

        if (valid) begin
            if (product > 32'd9999) begin
                // Left-to-right display: O L blank blank.
                thousands = 4'hA; // O, rendered as 0
                hundreds  = 4'hB; // L
                tens      = 4'hC; // blank
                ones      = 4'hC; // blank
            end else begin
                value_int = product;
                thousands = (value_int / 1000) % 10;
                hundreds  = (value_int / 100)  % 10;
                tens      = (value_int / 10)   % 10;
                ones      = value_int % 10;
            end
        end

        // Digit multiplexing. Basys 3 anodes are active-low.
        case (refresh[19:18])
            2'b00: begin an = 4'b1110; digit = ones;      end
            2'b01: begin an = 4'b1101; digit = tens;      end
            2'b10: begin an = 4'b1011; digit = hundreds;  end
            default: begin an = 4'b0111; digit = thousands; end
        endcase

        // seg[0]=a, seg[1]=b, ..., seg[6]=g; active-low.
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
            4'hA:  seg = 7'b1000000; // O approximated by 0
            4'hB:  seg = 7'b1000111; // L
            default: seg = 7'b1111111; // blank
        endcase
    end

    assign dp = 1'b1; // decimal point off
endmodule
