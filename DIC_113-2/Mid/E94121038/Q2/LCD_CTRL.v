module LCD_CTRL(
	input 			 clk	  ,
	input 			 rst	  ,
	input 	   [3:0] cmd      , 
	input 			 cmd_valid,
	input 	   [7:0] IROM_Q   ,
	output 			 IROM_rd  , 
	output reg [5:0] IROM_A   ,
	output reg		 IRAM_ceb ,
	output 		  	 IRAM_web ,
	output reg [7:0] IRAM_D	  ,
	output reg [5:0] IRAM_A	  ,
	input 	   [7:0] IRAM_Q	  ,
	output 			 busy	  ,
	output 			 done
);

reg [3:0] curr_state, next_state;
reg [7:0] img[0:7][0:7];
reg [7:0] cimg[0:8];
reg [2:0] x, y;
reg [2:0] idx_wx, idx_wy;
reg count;

parameter IDLE = 0, READ_IMG = 1, READ_CMD = 2, WRITE = 3, MOVE = 4, MAX = 5, MIN = 6, AVG = 7, WHITE = 8, BLACK = 9, ROTATE = 10, RESTORE = 11, COPY = 12, PASTE = 13, FINISH = 15;

assign busy = (curr_state == READ_CMD)? 0 : 1;
assign IROM_rd = (curr_state == READ_IMG)? 1 : 0;
// assign IRAM_ceb = ((curr_state == WRITE) || (curr_state == RESTORE))? 1 : 0;
assign IRAM_web = (curr_state == WRITE)? 0 : 1;
assign done = (curr_state == FINISH)? 1 : 0;

always @(*) begin
	if(rst) begin
		IRAM_ceb <= 0;
	end
	else if (curr_state == WRITE || cmd == RESTORE) begin
		IRAM_ceb <= 1;
	end
	else begin
		IRAM_ceb <= 0;
	end
end

wire [7:0] win [0:8];
assign win[0]  = img[x-1][y-1];
assign win[1]  = img[x][y-1];
assign win[2]  = img[x+1][y-1];
assign win[3]  = img[x-1][y];
assign win[4]  = img[x][y];
assign win[5]  = img[x+1][y];
assign win[6]  = img[x-1][y+1];
assign win[7]  = img[x][y+1];
assign win[8]  = img[x+1][y+1];

wire[11:0] sum;
assign sum = (win[0]  + win[1] + win[2] + win[3]  + win[4]  + win[5]  + win[6]  + 
			  win[7]  + win[8]);
wire [7:0] average;
assign average = sum / 9;

reg [7:0] max, max1, max2, max3, max4, max5, max6, max7;
reg [7:0] min, min1, min2, min3, min4, min5, min6, min7;

always @(*) begin
	max1  = (win[0]  > win[1] ) ? win[0]   : win[1] ;
    max2  = (win[2]  > win[3] ) ? win[2]   : win[3] ;
    max3  = (win[4]  > win[5] ) ? win[4]   : win[5] ;
    max4  = (win[6]  > win[7] ) ? win[6]   : win[7] ;

    max5  = (max1 > max2) ? max1 : max2;
    max6 = (max3 > max4) ? max3 : max4;
    max7 = (max5 > max6) ? max5 : max6;
    max = (max7 > win[8]) ? max7 : win[8];
end

// Pairwise comparison to find min value
always @(*) begin
    min1  = (win[0]  < win[1] ) ? win[0]  : win[1] ;
    min2  = (win[2]  < win[3] ) ? win[2]  : win[3] ;
    min3  = (win[4]  < win[5] ) ? win[4]  : win[5] ;
    min4  = (win[6]  < win[7] ) ? win[6]  : win[7] ;

    min5  = (min1  < min2) ? min1  : min2;
    min6 = (min3  < min4) ? min3  : min4;
    min7 = (min5  < min6) ? min5  : min6;
    min = (min7 < win[8]) ? min7 : win[8];
end

always @(*) begin
	if(curr_state == WRITE) begin
		if(IRAM_A[2:0] == 3'd7)begin
			idx_wx = 3'd0;
			idx_wy = IRAM_A[5:3] + 3'd1;
		end
		else begin
			idx_wx = IRAM_A[2:0] + 3'd1;
			idx_wy = IRAM_A[5:3];
		end
	end	
	else begin
		idx_wx = 3'd0;
		idx_wy = 3'd0;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		IRAM_D <= 8'd0;
	end	
	else if(next_state == WRITE) begin
		IRAM_D <= img[idx_wx][idx_wy];
	end	
	else begin
		IRAM_D <= 8'd0;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst)begin
		IRAM_A <= 6'd0;
	end	
	else if(curr_state == WRITE)begin
		IRAM_A <= IRAM_A + 6'd1;
	end	
	else if (curr_state == RESTORE) begin
		IRAM_A <= x + y * 8;
		count <= 1;
	end
	else begin
		IRAM_A <= 6'd0;
		count <= 0;
	end
end
integer c;
always @(posedge clk or posedge rst) begin
	if(rst) begin
		for(c=0; c<9; c=c+1) begin
			cimg[c] <= 8'd0;
		end
	end
	else if(curr_state == COPY) begin
		cimg[0] <= img[x-1][y-1];
		cimg[1] <= img[x  ][y-1];
		cimg[2] <= img[x+1][y-1];
		cimg[3] <= img[x-1][y  ];
		cimg[4] <= img[x  ][y  ];
		cimg[5] <= img[x+1][y  ];
		cimg[6] <= img[x-1][y+1];
		cimg[7] <= img[x  ][y+1];
		cimg[8] <= img[x+1][y+1];
	end
end

integer i_x, i_y;
always @(posedge clk or posedge rst) begin
	if(rst) begin
		for(i_x=0; i_x<8; i_x=i_x+1) begin
			for(i_y=0; i_y<8; i_y=i_y+1) begin
				img[i_x][i_y] <= 8'd0;
			end
		end
	end
	else if(curr_state == READ_IMG) begin
		img[IROM_A[2:0]][IROM_A[5:3]] <= IROM_Q;
	end
	else if(curr_state == MAX) begin
		img[x-1][y-1] <= max;
		img[x  ][y-1] <= max;
		img[x+1][y-1] <= max;
		img[x-1][y  ] <= max;
		img[x  ][y  ] <= max;
		img[x+1][y  ] <= max;
		img[x-1][y+1] <= max;
		img[x  ][y+1] <= max;
		img[x+1][y+1] <= max;

	end	
	else if(curr_state == MIN) begin
		img[x-1][y-1] <= min;
		img[x  ][y-1] <= min;
		img[x+1][y-1] <= min;
		img[x-1][y  ] <= min;
		img[x  ][y  ] <= min;
		img[x+1][y  ] <= min;
		img[x-1][y+1] <= min;
		img[x  ][y+1] <= min;
		img[x+1][y+1] <= min;
	end
	else if(curr_state == AVG) begin
		img[x-1][y-1] <= average;
		img[x  ][y-1] <= average;
		img[x+1][y-1] <= average;
		img[x-1][y  ] <= average;
		img[x  ][y  ] <= average;
		img[x+1][y  ] <= average;
		img[x-1][y+1] <= average;
		img[x  ][y+1] <= average;
		img[x+1][y+1] <= average;
	end
	else if(curr_state == WHITE) begin
		img[x-1][y-1] <= 8'hFF;
		img[x  ][y-1] <= 8'hFF;
		img[x+1][y-1] <= 8'hFF;
		img[x-1][y  ] <= 8'hFF;
		img[x  ][y  ] <= 8'hFF;
		img[x+1][y  ] <= 8'hFF;
		img[x-1][y+1] <= 8'hFF;
		img[x  ][y+1] <= 8'hFF;
		img[x+1][y+1] <= 8'hFF;
	end
	else if(curr_state == BLACK) begin
		img[x-1][y-1] <= 8'h00;
		img[x  ][y-1] <= 8'h00;
		img[x+1][y-1] <= 8'h00;
		img[x-1][y  ] <= 8'h00;
		img[x  ][y  ] <= 8'h00;
		img[x+1][y  ] <= 8'h00;
		img[x-1][y+1] <= 8'h00;
		img[x  ][y+1] <= 8'h00;
		img[x+1][y+1] <= 8'h00;
	end
	else if(curr_state == ROTATE) begin
		img[x-1][y-1] <= img[x-1][y  ];
		img[x  ][y-1] <= img[x-1][y-1];
		img[x+1][y-1] <= img[x  ][y-1];
		img[x-1][y  ] <= img[x-1][y+1];
		img[x+1][y  ] <= img[x+1][y-1];
		img[x-1][y+1] <= img[x  ][y+1];
		img[x  ][y+1] <= img[x+1][y+1];
		img[x+1][y+1] <= img[x+1][y  ];
	end
	else if(curr_state == RESTORE && count == 1) begin
		img[x  ][y  ] <= IRAM_Q;
	end
	else if (curr_state == PASTE) begin
		img[x-1][y-1] <= cimg[0];
		img[x  ][y-1] <= cimg[1];
		img[x+1][y-1] <= cimg[2];
		img[x-1][y  ] <= cimg[3];
		img[x  ][y  ] <= cimg[4];
		img[x+1][y  ] <= cimg[5];
		img[x-1][y+1] <= cimg[6];
		img[x  ][y+1] <= cimg[7];
		img[x+1][y+1] <= cimg[8];
	end
end		

always@(posedge clk or posedge rst)begin
	if(rst) begin
		x <= 3'd4;
		y <= 3'd4;
	end	
	else if(curr_state == MOVE) begin
		case(cmd)
			4'd1 : y <= (y == 3'd1) ? 3'd1 : (y - 3'd1);
			4'd2 : y <= (y == 3'd6) ? 3'd6 : (y + 3'd1);
			4'd3 : x <= (x == 3'd1) ? 3'd1 : (x - 3'd1);
			4'd4 : x <= (x == 3'd6) ? 3'd6 : (x + 3'd1);
		endcase 
	end
end

always@(posedge clk or posedge rst)begin
	if(rst) begin
		IROM_A <= 6'd0;
	end
	else if(curr_state == READ_IMG) begin
		IROM_A <= IROM_A + 6'd1;
	end
	else begin
		IROM_A <= 6'd0;
	end
end

always @(*) begin
	case(curr_state)
		IDLE : 
			next_state = READ_IMG;
		READ_IMG : 
			next_state = (IROM_A == 6'd63) ? READ_CMD : READ_IMG;
		READ_CMD : begin
			case(cmd)
				4'd0 : next_state = WRITE;
				4'd1, 4'd2, 4'd3, 4'd4 : next_state = MOVE;
				4'd5 : next_state = MAX;
				4'd6 : next_state = MIN;
				4'd7 : next_state = AVG;
				4'd8 : next_state = WHITE;
				4'd9 : next_state = BLACK;
				4'd10 : next_state = ROTATE;
				4'd11 : next_state = RESTORE;
				4'd12 : next_state = COPY;
				4'd13 : next_state = PASTE;
				4'd15 : next_state = FINISH;
				default : next_state = READ_CMD;
			endcase
		end
		WRITE : 
			next_state = (IRAM_A == 6'd63) ? READ_CMD : WRITE;
		MOVE : 
			next_state = READ_CMD;
		MAX : 
			next_state = READ_CMD;
		MIN : 
			next_state = READ_CMD;
		AVG : 
			next_state = READ_CMD;
		WHITE : 
			next_state = READ_CMD;
		BLACK :
			next_state = READ_CMD;
		ROTATE :
			next_state = READ_CMD;
		RESTORE :
			next_state = (count == 1)? READ_CMD : RESTORE;
		COPY :
			next_state = READ_CMD;
		PASTE : 
			next_state = READ_CMD;
		FINISH : 
			next_state = FINISH;
		default : 
			next_state = IDLE;
	endcase
end

always@(posedge clk or posedge rst)begin
	if(rst)
		curr_state <= IDLE;
	else
		curr_state <= next_state;
end

endmodule