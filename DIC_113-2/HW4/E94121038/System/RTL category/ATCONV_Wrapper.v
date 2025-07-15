`timescale 1ns/10ps
`include "./include/define.v"
`include "../ATCONV/ATCONV.v"

module ATCONV_Wrapper(
    input		                        bus_clk  ,
    input		                        bus_rst  ,
    input         [`BUS_DATA_BITS-1:0]  RDATA_M  ,
    input 	      					 	RLAST_M  ,
    input 	      					 	WREADY_M ,
    input 	      					 	RREADY_M ,
    output        [`BUS_ID_BITS  -1:0]  ID_M	 ,
    output        [`BUS_ADDR_BITS-1:0]  ADDR_M	 ,
    output        [`BUS_DATA_BITS-1:0]  WDATA_M  ,
    output        [`BUS_LEN_BITS -1:0]  BLEN_M   ,
    output      			 	    WLAST_M  ,
    output    					    WVALID_M ,
    output    					    RVALID_M ,
    output                              done   
);

  /////////////////////////////////
	// Please write your code here //
	/////////////////////////////////

wire        ROM_rd;
wire [11:0] iaddr;
wire  [15:0] idata_reg;
wire        layer0_ceb, layer0_web;
wire [11:0] layer0_A;
wire [15:0] layer0_D;
wire [15:0] layer0_Q;
wire        layer1_ceb, layer1_web;
wire [11:0] layer1_A;
wire [15:0] layer1_D;
wire [15:0] layer1_Q;

ATCONV u_atconv(
    .clk(bus_clk),
    .rst(bus_rst),
    .ROM_rd(ROM_rd),
    .iaddr(iaddr),
    .idata(idata_reg),
    .layer0_ceb(layer0_ceb),
    .layer0_web(layer0_web),
    .layer0_A(layer0_A),
    .layer0_D(layer0_D),
    .layer0_Q(layer0_Q),
    .layer1_ceb(layer1_ceb),
    .layer1_web(layer1_web),
    .layer1_A(layer1_A),
    .layer1_D(layer1_D),
    .layer1_Q(layer1_Q),
    .done(done)
);

parameter IDLE = 0, R_ROM = 1, W_SRAM0 = 2, R_SRAM0 = 3, W_SRAM1 = 4, DONE = 5;

reg [3:0] count0;
reg [1:0] count1;
reg [2:0] curr_state, next_state;

assign RVALID_M = ROM_rd || (layer0_ceb && layer0_web);
assign WVALID_M = (layer0_ceb && !layer0_web) || (layer1_ceb && !layer1_web);
assign BLEN_M = (RVALID_M || WVALID_M)? 1 : 0;
assign WLAST_M = WVALID_M;
assign ID_M = (curr_state == R_ROM)? 0 :
              (curr_state == W_SRAM0 || curr_state == R_SRAM0)? 1 : 
              (curr_state == W_SRAM1)? 2 : 3;
assign ADDR_M = (curr_state == R_ROM)? iaddr :
                (curr_state == W_SRAM0 || curr_state == R_SRAM0)? layer0_A :
                (curr_state == W_SRAM1)? layer1_A : 0;
assign WDATA_M = (curr_state == W_SRAM0)? layer0_D : 
                 (curr_state == W_SRAM1)? layer1_D : 0;
assign idata_reg = (curr_state == R_ROM)? RDATA_M : 0;
assign layer0_Q = (curr_state == R_SRAM0)? RDATA_M : 0;
assign layer1_Q = 0;

always @(*) begin
  if (bus_rst) next_state = IDLE;
  else begin
    case (curr_state)
      R_ROM : next_state = (count0 == 8)? W_SRAM0 : R_ROM;
      W_SRAM0 : next_state = (layer0_A == 4095)? R_SRAM0 : R_ROM;
      R_SRAM0 : next_state = (count1 == 3)? W_SRAM1 : R_SRAM0;
      W_SRAM1 : next_state = (layer1_A == 1023)? DONE : R_SRAM0;
      DONE : next_state = DONE;
      default: next_state = R_ROM;
    endcase
  end  
end

always @(posedge bus_clk or posedge bus_rst) begin
  if (bus_rst) curr_state <= IDLE;
  else curr_state <= next_state;
end

always @(posedge bus_clk or posedge bus_rst) begin
  if (bus_rst) begin
    count0 <= 0;
    count1 <= 0;
  end
  else if (curr_state == R_ROM) begin
    count0 <= count0 + 1;
  end
  else if (curr_state == W_SRAM0) begin
    count0 <= 0;
  end
  else if (curr_state == R_SRAM0) begin
    count1 <= count1 + 1;
  end
  else if (curr_state == W_SRAM1) begin
    count1 <= 0;
  end
end

endmodule
