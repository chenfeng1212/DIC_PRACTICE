`include "Comparator2.v"
module MedianFinder_3num(
    input  [3:0]    num1    , 
    input  [3:0]    num2    , 
    input  [3:0]    num3    ,  
    output [3:0]    median  ,
    wire   [3:0]    temp1_max,
    wire   [3:0]    temp1_min,
    wire   [3:0]    temp2_max,
    wire   [3:0]    temp2_min,
    wire   [3:0]    min  
);

///////////////////////////////
//	Write Your Design Here ~ //
///////////////////////////////

Comparator2 comp1(.A(num1), .B(num2), .min(temp1_min), .max(temp1_max));
Comparator2 comp2(.A(temp1_max), .B(num3), .min(temp2_min), .max(temp2_max));
Comparator2 comp3(.A(temp1_min), .B(temp2_min), .min(min), .max(median));

endmodule
