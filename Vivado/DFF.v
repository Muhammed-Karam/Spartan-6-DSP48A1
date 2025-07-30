module DFF(clk, Q, D, rst, CE);
    parameter WIDTH = 1;
    parameter RSTTYPE = "SYNC";
    input clk;
    input rst;
    input CE;
    input [WIDTH-1:0] D;
    output reg [WIDTH-1:0] Q;
    generate
        if (RSTTYPE == "ASYNC") begin
            always @(posedge clk or posedge rst) begin
                if (rst) 
                    Q <= {WIDTH{1'b0}};
                else if (CE)
                    Q <= D;
            end
        end
        else begin // If -> RSTTYPE = "SYNC"
            always @(posedge clk) begin
                if (rst) 
                    Q <= {WIDTH{1'b0}};
                else if (CE)
                    Q <= D;
            end
        end
    endgenerate
endmodule