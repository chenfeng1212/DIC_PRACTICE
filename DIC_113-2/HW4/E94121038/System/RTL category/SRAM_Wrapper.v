`timescale 1ns/10ps
`include "./include/define.v"

module SRAM_Wrapper(
	input 	   						bus_clk ,
	input 	   						bus_rst ,
	input      [`BUS_ADDR_BITS-1:0] ADDR_S  ,
	input      [`BUS_DATA_BITS-1:0] WDATA_S ,
	input      [`BUS_LEN_BITS -1:0] BLEN_S  ,
	input      						WLAST_S ,
	input      						WVALID_S,
	input      						RVALID_S,
	output     [`BUS_DATA_BITS-1:0] RDATA_S ,
	output  						RLAST_S ,
	output     						WREADY_S,
	output     						RREADY_S,
	output     [`BUS_DATA_BITS-1:0] SRAM_D  ,
	output     [`BUS_ADDR_BITS-1:0] SRAM_A  ,
	input	   [`BUS_DATA_BITS-1:0] SRAM_Q  ,
	output							SRAM_ceb,
	output							SRAM_web		
);
	/////////////////////////////////
	// Please write your code here //
	/////////////////////////////////
	
assign RREADY_S = RVALID_S;
assign WREADY_S = WVALID_S;
assign SRAM_ceb = (RREADY_S || WREADY_S);
assign SRAM_web = RVALID_S; 
assign SRAM_A = (RVALID_S || WVALID_S)? ADDR_S : 0;
assign SRAM_D = (WVALID_S)? WDATA_S : 0;
assign RDATA_S = (RVALID_S)? SRAM_Q : 0;
assign RLAST_S = (RVALID_S)? 1 : 0;

endmodule