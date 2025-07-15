module BU(
	input signed [31:0] a,
	input signed [31:0] b,
	input signed [31:0] c,
	input signed [31:0] d,
	input signed [31:0] W_real,
	input signed [31:0] W_imag,
	
	output signed [31:0] result0_real,
	output signed [31:0] result0_imag,
	output signed [31:0] result1_real,
	output signed [31:0] result1_imag
);

/////////////////////////////////
// Please write your code here //
/////////////////////////////////

wire signed [64:0] part1, part2, part3, part4, part5, part6;
assign result0_real = a + c;
assign result0_imag = b + d;
assign part1 = (a - c) * W_real;
assign part2 = (d - b) * W_imag;
assign part3 = (a - c) * W_imag;
assign part4 = (b - d) * W_real;
assign part5 = part1 + part2;
assign part6 = part3 + part4;
assign result1_real = part5[47:16];
assign result1_imag = part6[47:16];

endmodule