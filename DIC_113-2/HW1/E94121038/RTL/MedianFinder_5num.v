`include "Comparator2.v"
`include "MedianFinder_3num.v"
module MedianFinder_5num(
    input  [3:0] 	num1  , 
	input  [3:0] 	num2  , 
	input  [3:0] 	num3  , 
	input  [3:0] 	num4  , 
	input  [3:0] 	num5  ,  
    output [3:0] 	median,  
	wire   [3:0] 	temp1_min,
	wire   [3:0] 	temp1_max,
	wire   [3:0] 	temp2_min,
	wire   [3:0] 	temp2_max,
	wire   [3:0] 	temp3_min,
	wire   [3:0] 	temp3_max,
	wire   [3:0] 	temp4_min,
	wire   [3:0] 	temp4_max
);

///////////////////////////////
//	Write Your Design Here ~ //
///////////////////////////////

Comparator2 comp1(.A(num1), .B(num2), .min(temp1_min), .max(temp1_max));
Comparator2 comp2(.A(num3), .B(num4), .min(temp2_min), .max(temp2_max));
Comparator2 comp3(.A(temp1_min), .B(temp2_min), .min(temp3_min), .max(temp3_max));
Comparator2 comp4(.A(temp1_max), .B(temp2_max), .min(temp4_min), .max(temp4_max));
MedianFinder_3num comp5(.num1(temp3_max), .num2(temp4_min), .num3(num5), .median(median));

endmodule
