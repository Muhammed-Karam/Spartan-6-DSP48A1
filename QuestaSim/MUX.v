module MUX(in0, in1, in2, in3, sel, out);
    parameter WIDTH = 1;
    parameter INPUTS = 2;
    input [WIDTH-1:0] in0;
    input [WIDTH-1:0] in1;
    input [WIDTH-1:0] in2;
    input [WIDTH-1:0] in3;
    input [$clog2(INPUTS)-1:0] sel;
    output reg [WIDTH-1:0] out;
    always @(*) begin
        case (sel)
            0 : out = in0;
            1 : out = in1;
            2 : out = in2;
            3 : out = in3;
        endcase
    end
endmodule