`timescale 1ns/10ps
`include "./include/define.v"

module BUS(
	input 							bus_clk  ,
	input 							bus_rst  ,

	// MASTERS PORTS
	input      [`BUS_ID_BITS  -1:0] ID_M0	 ,
	input      [`BUS_ADDR_BITS-1:0] ADDR_M0	 ,
	input      [`BUS_DATA_BITS-1:0] WDATA_M0 ,
	input      [`BUS_LEN_BITS -1:0] BLEN_M0  ,
	input   						WLAST_M0 ,
	input   						WVALID_M0,
	input   						RVALID_M0,
	output 	   [`BUS_DATA_BITS-1:0] RDATA_M0 ,
	output 	   						RLAST_M0 ,
	output 	   						WREADY_M0,
	output 	   						RREADY_M0,
	
	// SLAVE S0 PORTS (Image ROM)
	output     [`BUS_ADDR_BITS-1:0] ADDR_S0  ,
	output     [`BUS_LEN_BITS -1:0] BLEN_S0  ,
	output     						RVALID_S0,
	input  	   [`BUS_DATA_BITS-1:0] RDATA_S0 ,
	input 							RLAST_S0 ,
	input 							RREADY_S0,
	
	// SLAVE S1 PORTS (Layer0 SRAM)
	output     [`BUS_ADDR_BITS-1:0] ADDR_S1  ,
	output     [`BUS_DATA_BITS-1:0] WDATA_S1 ,
	output     [`BUS_LEN_BITS -1:0] BLEN_S1  ,
	output     						WLAST_S1 ,
	output     						WVALID_S1,
	output     						RVALID_S1,
	input  	   [`BUS_DATA_BITS-1:0] RDATA_S1 ,
	input 							RLAST_S1 ,
	input 							WREADY_S1,
	input 							RREADY_S1,

	// SLAVE S2 PORTS (Layer1 SRAM)
	output     [`BUS_ADDR_BITS-1:0] ADDR_S2  ,
	output     [`BUS_DATA_BITS-1:0] WDATA_S2 ,
	output     [`BUS_LEN_BITS -1:0] BLEN_S2  ,
	output     						WLAST_S2 ,
	output     						WVALID_S2,
	output     						RVALID_S2,
	input  	   [`BUS_DATA_BITS-1:0] RDATA_S2 ,
	input 							RLAST_S2 ,
	input 							WREADY_S2,
	input 							RREADY_S2
);
	/////////////////////////////////
	// Please write your code here //
	/////////////////////////////////

assign RDATA_M0 = (ID_M0==0)? RDATA_S0 :
                  (ID_M0==1)? RDATA_S1 : RDATA_S2;
assign RLAST_M0 = (ID_M0==0)? RLAST_S0 :
                  (ID_M0==1)? RLAST_S1 : RLAST_S2;
assign WREADY_M0 = (ID_M0==1)? WREADY_S1 :
                   (ID_M0==2)? WREADY_S2 : 1'b0;
assign RREADY_M0 = (ID_M0==0)? RREADY_S0 :
                   (ID_M0==1)? RREADY_S1 : RREADY_S2;

assign ADDR_S0 = (ID_M0==0 && RVALID_M0) ? ADDR_M0 : {`BUS_ADDR_BITS{1'b0}};
assign BLEN_S0 = (ID_M0==0 && RVALID_M0)? BLEN_M0 : {`BUS_LEN_BITS{1'b0}};
assign RVALID_S0 = (ID_M0==0)? RVALID_M0 : 1'b0;

assign ADDR_S1 = (ID_M0==1)? ADDR_M0 : {`BUS_ADDR_BITS{1'b0}};
assign WDATA_S1 = (ID_M0==1 && WVALID_M0)? WDATA_M0 : {`BUS_DATA_BITS{1'b0}};
assign BLEN_S1 = (ID_M0==1)? BLEN_M0 : {`BUS_LEN_BITS{1'b0}};
assign WLAST_S1 = (ID_M0==1)? WLAST_M0  : 1'b0;
assign WVALID_S1 = (ID_M0==1)? WVALID_M0 : 1'b0;
assign RVALID_S1 = (ID_M0==1)? RVALID_M0 : 1'b0;

assign ADDR_S2 = (ID_M0==2 && WVALID_M0)? ADDR_M0 : {`BUS_ADDR_BITS{1'b0}};
assign WDATA_S2 = (ID_M0==2 && WVALID_M0) ? WDATA_M0 : {`BUS_DATA_BITS{1'b0}};
assign BLEN_S2 = (ID_M0==2 && WVALID_M0) ? BLEN_M0 : {`BUS_LEN_BITS{1'b0}};
assign WLAST_S2 = (ID_M0==2)? WLAST_M0  : 1'b0;
assign WVALID_S2 = (ID_M0==2)? WVALID_M0 : 1'b0;
assign RVALID_S2 = 0;

endmodule
