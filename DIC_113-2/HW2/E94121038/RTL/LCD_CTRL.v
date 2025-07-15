module LCD_CTRL(
	input 	   	  clk	   ,
	input 		  rst	   ,
	input 	[3:0] cmd      , 
	input 		  cmd_valid,
	input 	[7:0] IROM_Q   ,
	output reg 		  IROM_rd  , 
	output reg  [5:0] IROM_A   ,
	output reg 		  IRAM_ceb ,
	output reg 		  IRAM_web ,
	output reg  [7:0] IRAM_D   ,
	output reg  [5:0] IRAM_A   ,
	input 	[7:0] IRAM_Q   ,
	output reg 		  busy	   ,
	output reg 		  done
);

/////////////////////////////////
// Please write your code here //
/////////////////////////////////

parameter IDLE = 0, READ = 1, PROCESS = 2, WRITE = 3, DONE = 4, MAX = 5, MIN = 6, AVG = 7;

reg [2:0] next_state;
reg [2:0] cur_state;
reg [5:0] origin_XY;
reg [6:0] counter;
reg [6:0] count;
reg [7:0] data [63:0];
reg [11:0] compare;

always @(*) begin
	if (rst) begin
		next_state = READ;
	end
	else begin
		case (cur_state)
			READ : begin
				if (counter == 7'd65) next_state = IDLE;
				else next_state = READ;
			end
			IDLE : begin
				if (cmd_valid && ~busy) begin
					if (cmd == 4'b0) next_state = WRITE;
					else if (cmd == 4'b0101) next_state = MAX;
					else if (cmd == 4'b0110) next_state = MIN;
					else if (cmd == 4'b0111) next_state = AVG;
					else next_state = IDLE;
				end
				else next_state = IDLE;
			end
			WRITE : begin
				if (count == 7'd64) next_state = DONE;
				else next_state = WRITE;
			end
			DONE : begin
				next_state = IDLE;
			end
			MAX : begin
				if (count == 7'd17) next_state = IDLE;
				else next_state = MAX;
			end
			MIN : begin
				if (count == 7'd17) next_state = IDLE;
				else next_state = MIN;
			end
			AVG : begin
				if (count == 7'd17) next_state = IDLE;
				else next_state = AVG;
			end
			default: next_state = IDLE;
		endcase
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) cur_state <= READ;
	else cur_state <= next_state;
end

integer i;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		counter <= 0;
		IROM_rd <= 0;
		for (i = 0; i < 64; i = i + 1) begin
			data[i] <= 0;
		end
	end
	else if (cur_state == READ) begin
		IROM_rd <= 1;
		counter <= counter + 1;
		if (counter < 64)
			IROM_A <= counter;
		if (counter != 0)
			data[counter - 1] <= IROM_Q;
	end
	else begin
		counter <= 0;
		IROM_rd <= 0;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		origin_XY <= 36;
	end
	else if (cur_state == IDLE && cmd_valid && ~busy) begin
		case (cmd)
			4'b0001 : begin //S_U
				if (origin_XY[5:3] > 2)
					origin_XY[5:3] <= origin_XY[5:3] - 1;
			end
			4'b0010 : begin //S_D
				if (origin_XY[5:3] < 6)
					origin_XY[5:3] <= origin_XY[5:3] + 1;
			end
			4'b0011 : begin //S_L
				if (origin_XY[2:0] > 2)
					origin_XY[2:0] <= origin_XY[2:0] - 1;
			end
			4'b0100 : begin //S_R
				if (origin_XY[2:0] < 6)
					origin_XY[2:0] <= origin_XY[2:0] + 1;
			end
		endcase
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		count <= 0;
		IRAM_ceb <= 0;
		IRAM_web <= 0;
		compare <= 0;
	end
	else begin
		case (cur_state)
			WRITE : begin
				count <= count + 1;
				IRAM_ceb <= 1;
				IRAM_web <= 0;
				IRAM_A <= count;
				IRAM_D <= data[count];
			end
			MAX : begin
				count <= count + 1;
				if (count == 16) begin
					for (i = 0; i < 16; i = i + 1) begin
						case (i)
							4'd0 : begin
								data[origin_XY - 18] <= compare;
							end
							4'd1 : begin
								data[origin_XY - 17] <= compare;
							end
							4'd2 : begin
								data[origin_XY - 16] <= compare;
							end
							4'd3 : begin
								data[origin_XY - 15] <= compare;
							end
							4'd4 : begin
								data[origin_XY - 10] <= compare;
							end
							4'd5 : begin
								data[origin_XY - 9] <= compare;
							end
							4'd6 : begin
								data[origin_XY - 8] <= compare;
							end
							4'd7 : begin
								data[origin_XY - 7] <= compare;
							end
							4'd8 : begin
								data[origin_XY - 2] <= compare;
							end
							4'd9 : begin
								data[origin_XY - 1] <= compare;
							end
							4'd10 : begin
								data[origin_XY] <= compare;
							end
							4'd11 : begin
								data[origin_XY + 1] <= compare;
							end
							4'd12 : begin
								data[origin_XY + 6] <= compare;
							end
							4'd13 : begin
								data[origin_XY + 7] <= compare;
							end
							4'd14 : begin
								data[origin_XY + 8] <= compare;
							end
							4'd15 : begin
								data[origin_XY + 9] <= compare;
							end
						endcase
					end
				end
				else begin
					case (count)
						4'd0 : begin
							if (data[origin_XY - 18] > compare) compare <= data[origin_XY - 18];
						end
						4'd1 : begin
							if (data[origin_XY - 17] > compare) compare <= data[origin_XY - 17];
						end
						4'd2 : begin
							if (data[origin_XY - 16] > compare) compare <= data[origin_XY - 16];
						end
						4'd3 : begin
							if (data[origin_XY - 15] > compare) compare <= data[origin_XY - 15];
						end
						4'd4 : begin
							if (data[origin_XY - 10] > compare) compare <= data[origin_XY - 10];
						end
						4'd5 : begin
							if (data[origin_XY - 9] > compare) compare <= data[origin_XY - 9];
						end
						4'd6 : begin
							if (data[origin_XY - 8] > compare) compare <= data[origin_XY - 8];
						end
						4'd7 : begin
							if (data[origin_XY - 7] > compare) compare <= data[origin_XY - 7];
						end
						4'd8 : begin
							if (data[origin_XY - 2] > compare) compare <= data[origin_XY - 2];
						end
						4'd9 : begin
							if (data[origin_XY - 1] > compare) compare <= data[origin_XY - 1];
						end
						4'd10 : begin
							if (data[origin_XY] > compare) compare <= data[origin_XY];
						end
						4'd11 : begin
							if (data[origin_XY + 1] > compare) compare <= data[origin_XY + 1];
						end
						4'd12 : begin
							if (data[origin_XY + 6] > compare) compare <= data[origin_XY + 6];
						end
						4'd13 : begin
							if (data[origin_XY + 7] > compare) compare <= data[origin_XY + 7];
						end
						4'd14 : begin
							if (data[origin_XY + 8] > compare) compare <= data[origin_XY + 8];
						end
						4'd15 : begin
							if (data[origin_XY + 9] > compare) compare <= data[origin_XY + 9];
						end
					endcase
				end
			end
			MIN : begin
				count <= count + 1;
				if (count == 16) begin
					for (i = 0; i < 16; i = i + 1) begin
						case (i)
							4'd0 : begin
								data[origin_XY - 18] <= compare;
							end
							4'd1 : begin
								data[origin_XY - 17] <= compare;
							end
							4'd2 : begin
								data[origin_XY - 16] <= compare;
							end
							4'd3 : begin
								data[origin_XY - 15] <= compare;
							end
							4'd4 : begin
								data[origin_XY - 10] <= compare;
							end
							4'd5 : begin
								data[origin_XY - 9] <= compare;
							end
							4'd6 : begin
								data[origin_XY - 8] <= compare;
							end
							4'd7 : begin
								data[origin_XY - 7] <= compare;
							end
							4'd8 : begin
								data[origin_XY - 2] <= compare;
							end
							4'd9 : begin
								data[origin_XY - 1] <= compare;
							end
							4'd10 : begin
								data[origin_XY] <= compare;
							end
							4'd11 : begin
								data[origin_XY + 1] <= compare;
							end
							4'd12 : begin
								data[origin_XY + 6] <= compare;
							end
							4'd13 : begin
								data[origin_XY + 7] <= compare;
							end
							4'd14 : begin
								data[origin_XY + 8] <= compare;
							end
							4'd15 : begin
								data[origin_XY + 9] <= compare;
							end
						endcase
					end
				end
				else if (count == 0) compare <= data[origin_XY - 18];
				else begin
					case (count)
						4'd1 : begin
							if (data[origin_XY - 17] < compare) compare <= data[origin_XY - 17];
						end
						4'd2 : begin
							if (data[origin_XY - 16] < compare) compare <= data[origin_XY - 16];
						end
						4'd3 : begin
							if (data[origin_XY - 15] < compare) compare <= data[origin_XY - 15];
						end
						4'd4 : begin
							if (data[origin_XY - 10] < compare) compare <= data[origin_XY - 10];
						end
						4'd5 : begin
							if (data[origin_XY - 9] < compare) compare <= data[origin_XY - 9];
						end
						4'd6 : begin
							if (data[origin_XY - 8] < compare) compare <= data[origin_XY - 8];
						end
						4'd7 : begin
							if (data[origin_XY - 7] < compare) compare <= data[origin_XY - 7];
						end
						4'd8 : begin
							if (data[origin_XY - 2] < compare) compare <= data[origin_XY - 2];
						end
						4'd9 : begin
							if (data[origin_XY - 1] < compare) compare <= data[origin_XY - 1];
						end
						4'd10 : begin
							if (data[origin_XY] < compare) compare <= data[origin_XY];
						end
						4'd11 : begin
							if (data[origin_XY + 1] < compare) compare <= data[origin_XY + 1];
						end
						4'd12 : begin
							if (data[origin_XY + 6] < compare) compare <= data[origin_XY + 6];
						end
						4'd13 : begin
							if (data[origin_XY + 7] < compare) compare <= data[origin_XY + 7];
						end
						4'd14 : begin
							if (data[origin_XY + 8] < compare) compare <= data[origin_XY + 8];
						end
						4'd15 : begin
							if (data[origin_XY + 9] < compare) compare <= data[origin_XY + 9];
						end
					endcase
				end
			end
			AVG : begin
				count <= count + 1;
				if (count == 16) begin
					for (i = 0; i < 16; i = i + 1) begin
						case (i)
							4'd0 : begin
								data[origin_XY - 18] <= compare >> 4;
							end
							4'd1 : begin
								data[origin_XY - 17] <= compare >> 4;
							end
							4'd2 : begin
								data[origin_XY - 16] <= compare >> 4;
							end
							4'd3 : begin
								data[origin_XY - 15] <= compare >> 4;
							end
							4'd4 : begin
								data[origin_XY - 10] <= compare >> 4;
							end
							4'd5 : begin
								data[origin_XY - 9] <= compare >> 4;
							end
							4'd6 : begin
								data[origin_XY - 8] <= compare >> 4;
							end
							4'd7 : begin
								data[origin_XY - 7] <= compare >> 4;
							end
							4'd8 : begin
								data[origin_XY - 2] <= compare >> 4;
							end
							4'd9 : begin
								data[origin_XY - 1] <= compare >> 4;
							end
							4'd10 : begin
								data[origin_XY] <= compare >> 4;
							end
							4'd11 : begin
								data[origin_XY + 1] <= compare >> 4;
							end
							4'd12 : begin
								data[origin_XY + 6] <= compare >> 4;
							end
							4'd13 : begin
								data[origin_XY + 7] <= compare >> 4;
							end
							4'd14 : begin
								data[origin_XY + 8] <= compare >> 4;
							end
							4'd15 : begin
								data[origin_XY + 9] <= compare >> 4;
							end
						endcase
					end
				end
				else begin
					case (count)
						4'd0 : begin
							compare <= compare + data[origin_XY - 18];
						end
						4'd1 : begin
							compare <= compare + data[origin_XY - 17];
						end
						4'd2 : begin
							compare <= compare + data[origin_XY - 16];
						end
						4'd3 : begin
							compare <= compare + data[origin_XY - 15];
						end
						4'd4 : begin
							compare <= compare + data[origin_XY - 10];
						end
						4'd5 : begin
							compare <= compare + data[origin_XY - 9];
						end
						4'd6 : begin
							compare <= compare + data[origin_XY - 8];
						end
						4'd7 : begin
							compare <= compare + data[origin_XY - 7];
						end
						4'd8 : begin
							compare <= compare + data[origin_XY - 2];
						end
						4'd9 : begin
							compare <= compare + data[origin_XY - 1];
						end
						4'd10 : begin
							compare <= compare + data[origin_XY];
						end
						4'd11 : begin
							compare <= compare + data[origin_XY + 1];
						end
						4'd12 : begin
							compare <= compare + data[origin_XY + 6];
						end
						4'd13 : begin
							compare <= compare + data[origin_XY + 7];
						end
						4'd14 : begin
							compare <= compare + data[origin_XY + 8];
						end
						4'd15 : begin
							compare <= compare + data[origin_XY + 9];
						end
					endcase
				end
			end
			default: begin
				count <= 0;
				compare <= 0;
			end
		endcase
	end
end

always @(*) begin
	if (rst) begin
		busy = 0;
		done = 0;
	end
	else if (cur_state == DONE) begin
		busy = 0;
		done = 1;
	end
	else if (cur_state == IDLE) begin
		busy = 0;
		done = 0;
	end
	else begin
		busy = 1;
		done = 0;
	end
end

endmodule