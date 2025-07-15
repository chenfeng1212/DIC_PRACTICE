`include "Comparator2.v"
`include "MedianFinder_5num.v"
module MedianFinder_7num(
    input  	[3:0]  	num1  , 
	input  	[3:0]  	num2  , 
	input  	[3:0]  	num3  , 
	input  	[3:0]  	num4  , 
	input  	[3:0]  	num5  , 
	input  	[3:0]  	num6  , 
	input  	[3:0]  	num7  ,  
    output 	[3:0] 	median,
	wire   [3:0] 	temp1_min,
	wire   [3:0] 	temp1_max,
	wire   [3:0] 	temp2_min,
	wire   [3:0] 	temp2_max,
	wire   [3:0] 	temp3_min,
	wire   [3:0] 	temp3_max,
	wire   [3:0] 	temp4_min,
	wire   [3:0] 	temp4_max,
	wire   [3:0] 	temp5_min,
	wire   [3:0] 	temp5_max,
	wire   [3:0] 	temp6_min,
	wire   [3:0] 	temp6_max,
	wire   [3:0] 	temp7_min,
	wire   [3:0] 	temp7_max
);

///////////////////////////////
//	Write Your Design Here ~ //
///////////////////////////////

Comparator2 comp1(.A(num1), .B(num2), .min(temp1_min), .max(temp1_max));
Comparator2 comp2(.A(num3), .B(num4), .min(temp2_min), .max(temp2_max));
Comparator2 comp3(.A(num5), .B(num6), .min(temp3_min), .max(temp3_max));
Comparator2 comp4(.A(temp1_min), .B(temp2_min), .min(temp4_min), .max(temp4_max));
Comparator2 comp5(.A(temp1_max), .B(temp2_max), .min(temp5_min), .max(temp5_max));
Comparator2 comp6(.A(temp4_min), .B(temp3_min), .min(temp6_min), .max(temp6_max));
Comparator2 comp7(.A(temp3_max), .B(temp5_max), .min(temp7_min), .max(temp7_max));
MedianFinder_5num comp8(.num1(temp4_max), .num2(temp5_min), .num3(temp6_max), .num4(temp7_min), .num5(num7), .median(median));

endmodule
