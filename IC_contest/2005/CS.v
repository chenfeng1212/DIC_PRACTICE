`timescale 1ns/10ps
/*
 * IC Contest Computational System (CS)
*/
module CS(Y, X, reset, clk);

input clk, reset; 
input [7:0] X;
output [9:0] Y;

integer i;
integer j;

reg [9:0] Y;
reg [7:0] serial [0:8];
reg [11:0] Xsum;
reg [7:0] Xavg;
reg [7:0] Xappr;
reg [12:0] Xsums;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i <= 8; i = i + 1) begin
            serial[i] <= 8'b0;
        end
        i <= 0;
    end
    else begin
        for (i = 8; i > 0; i = i - 1) begin
            serial[i] <= serial[i-1];
        end
        serial[0] <= X;
    end
end

always @(*) begin
    Xsum = serial[0] + serial[1] + serial[2] + serial[3] + serial[4] + serial[5] + serial[6] + serial[7] + serial[8];
    Xavg = Xsum / 9;
    
    Xappr = 8'b0;
    for (j = 0; j <= 8; j = j + 1) begin
        if ((Xavg >= serial[j]) && (serial[j] > Xappr)) Xappr = serial[j];
    end

    Xsums = Xsum + ({Xappr, 3'b0} + Xappr);
    Y = Xsums >> 3;
end
endmodule