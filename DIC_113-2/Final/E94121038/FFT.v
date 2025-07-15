module  FFT (
	input clk,
	input rst,
	input signed [15:0] fir_d, 
	input fir_valid, 
	output reg fftr_valid, 
	output reg ffti_valid, 
	output reg done,
	output reg [15:0] fft_d0,
 	output reg [15:0] fft_d1, 
	output reg [15:0] fft_d2,
	output reg [15:0] fft_d3,
	output reg [15:0] fft_d4,
	output reg [15:0] fft_d5,
	output reg [15:0] fft_d6,
	output reg [15:0] fft_d7,
	output reg [15:0] fft_d8,
 	output reg [15:0] fft_d9,
	output reg [15:0] fft_d10,
	output reg [15:0] fft_d11,
	output reg [15:0] fft_d12,
	output reg [15:0] fft_d13,
	output reg [15:0] fft_d14,
	output reg [15:0] fft_d15
);

/////////////////////////////////
// Please write your code here //
/////////////////////////////////

reg signed[17:0] data_r [31:0];
reg signed[17:0] data_i [31:0];
reg signed[17:0] temp [9:0];

reg [4:0] count;
reg ready;
reg signed [31:0] wr [15:0];
reg signed [31:0] wi [15:0];

always @(posedge clk or posedge rst) begin
    if (rst) begin
		fft_d0 <= 0;
        fft_d1 <= 0;
        fft_d2 <= 0;
        fft_d3 <= 0;       
        fft_d4 <= 0;
        fft_d5 <= 0;
        fft_d6 <= 0;
        fft_d7 <= 0;
        fft_d8 <= 0;
        fft_d9 <= 0;
        fft_d10 <= 0;
        fft_d11 <= 0;
        fft_d12 <= 0;
        fft_d13 <= 0;
        fft_d14 <= 0;
        fft_d15 <= 0;
	 end
	 else if (count == 5)begin
        fft_d0 <= data_r[0][17:2];
        fft_d1 <= data_r[1][17:2];
        fft_d2 <= data_r[2][17:2];
        fft_d3 <= data_r[3][17:2];       
        fft_d4 <= data_r[4][17:2];
        fft_d5 <= data_r[5][17:2];
        fft_d6 <= data_r[6][17:2];
        fft_d7 <= data_r[7][17:2];
        fft_d8 <= data_r[8][17:2];
        fft_d9 <= data_r[9][17:2];
        fft_d10 <= data_r[10][17:2];
        fft_d11 <= data_r[11][17:2];
        fft_d12 <= data_r[12][17:2];
        fft_d13 <= data_r[13][17:2];
        fft_d14 <= data_r[14][17:2];
        fft_d15 <= data_r[15][17:2];
    end
    else if (count == 6) begin
        fft_d0 <= data_r[16][17:2];
        fft_d1 <= data_r[17][17:2];
        fft_d2 <= data_r[18][17:2];
        fft_d3 <= data_r[19][17:2];       
        fft_d4 <= data_r[20][17:2];
        fft_d5 <= data_r[21][17:2];
        fft_d6 <= data_r[22][17:2];
        fft_d7 <= data_r[23][17:2];
        fft_d8 <= data_r[24][17:2];
        fft_d9 <= data_r[25][17:2];
        fft_d10 <= data_r[26][17:2];
        fft_d11 <= data_r[27][17:2];
        fft_d12 <= data_r[28][17:2];
        fft_d13 <= data_r[29][17:2];
        fft_d14 <= data_r[30][17:2];
        fft_d15 <= data_r[31][17:2];
    end
	else if (count == 7) begin
		fft_d0 <= data_i[0][17:2];
        fft_d1 <= data_i[1][17:2];
        fft_d2 <= data_i[2][17:2];
        fft_d3 <= data_i[3][17:2];       
        fft_d4 <= data_i[4][17:2];
        fft_d5 <= data_i[5][17:2];
        fft_d6 <= data_i[6][17:2];
        fft_d7 <= data_i[7][17:2];
        fft_d8 <= data_i[8][17:2];
        fft_d9 <= data_i[9][17:2];
        fft_d10 <= data_i[10][17:2];
        fft_d11 <= data_i[11][17:2];
        fft_d12 <= data_i[12][17:2];
        fft_d13 <= data_i[13][17:2];
        fft_d14 <= data_i[14][17:2];
        fft_d15 <= data_i[15][17:2];
	end
	else begin
		fft_d0 <= data_i[16][17:2];
        fft_d1 <= data_i[17][17:2];
        fft_d2 <= data_i[18][17:2];
        fft_d3 <= data_i[19][17:2];       
        fft_d4 <= data_i[20][17:2];
        fft_d5 <= data_i[21][17:2];
        fft_d6 <= data_i[22][17:2];
        fft_d7 <= data_i[23][17:2];
        fft_d8 <= data_i[24][17:2];
        fft_d9 <= data_i[25][17:2];
        fft_d10 <= data_i[26][17:2];
        fft_d11 <= data_i[27][17:2];
        fft_d12 <= data_i[28][17:2];
        fft_d13 <= data_i[29][17:2];
        fft_d14 <= data_i[30][17:2];
        fft_d15 <= data_i[31][17:2];
	end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        count <= 0;
    end
    else if (ready || fir_valid) begin
        count <= count + 1;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        done <= 0;
    end
    else if (count == 9 &&  ~fir_valid) begin
        done <= 1;
    end
    else begin
        done <= 0;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        ready <= 0;
    end
    else if (count == 9) begin
        ready <= 1;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        fftr_valid <= 0;
		ffti_valid <= 0;
    end
    else if (ready && (count == 5 || count == 6)) begin
        fftr_valid <= 1;
		ffti_valid <= 0;
    end
	else if (ready && (count == 7 || count == 8)) begin
        fftr_valid <= 0;
		ffti_valid <= 1;
    end
    else begin
        fftr_valid <= 0;
		ffti_valid <= 0;
    end  
end

integer i, j;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		for (i = 0; i <= 31; i = i + 1) begin
			data_i[i] <= 0;
			data_r[i] <= 0;
		end
		for (j = 0; j <= 15; j = j + 1) begin
			wi[j] <= 0;
			wr[j] <= 0;
		end
		temp[0] <= 0;
		temp[1] <= 0;
		temp[2] <= 0;
		temp[3] <= 0;
		temp[4] <= 0;
		temp[5] <= 0;
		temp[6] <= 0;
		temp[7] <= 0;
		temp[8] <= 0;
		temp[9] <= 0; 
	end
	else begin
		case (count)
			0 : begin
				for (i = 0; i <= 15; i = i + 1) begin
					data_r[i] <= data_r[i] + data_r[i + 16];
					data_i[i] <= 0;
				end
				for (j = 16; j <= 31; j = j + 1) begin
					data_r[j] <= ((data_r[j - 16] - data_r[j]) * wr[j - 16] + $signed(50'd0)) >> 16;
					data_i[j] <= ((data_r[j - 16] - data_r[j]) * wi[j - 16] + $signed(50'd0)) >> 16;
				end
				temp[0] <= fir_d;
			end 
			1 : begin
				for (i = 0; i <= 7; i = i + 1) begin
					data_r[i] <= data_r[i] + data_r[i + 8];
					data_r[i + 16] <= data_r[i + 16] + data_r[i + 24];
					data_i[i] <= data_i[i] + data_i[i + 8];
					data_i[i + 16] <= data_i[i + 16] + data_i[i + 24];
					data_r[i + 8] <= ((data_r[i] - data_r[i + 8]) * wr[i << 1] + (data_i[i + 8] - data_i[i]) * wi[i << 1] + $signed(50'd0)) >> 16;
					data_r[i + 24] <= ((data_r[i + 16] - data_r[i + 24]) * wr[i << 1] + (data_i[i + 24] - data_i[i + 16]) * wi[i << 1] + $signed(50'd0)) >> 16;
					data_i[i + 8] <= ((data_r[i] - data_r[i + 8]) * wi[i << 1] + (data_i[i] - data_i[i + 8]) * wr[i << 1] + $signed(50'd0)) >> 16;
					data_i[i + 24] <= ((data_r[i + 16] - data_r[i + 24]) * wi[i << 1] + (data_i[i + 16] - data_i[i + 24]) * wr[i << 1] + $signed(50'd0)) >> 16;
				end
				temp[1] <= fir_d;
			end
			2 : begin
				for (i = 0; i <= 3; i = i + 1) begin
					data_r[i] <= data_r[i] + data_r[i + 4];
					data_r[i + 8] <= data_r[i + 8] + data_r[i + 12];
					data_r[i + 16] <= data_r[i + 16] + data_r[i + 20];
					data_r[i + 24] <= data_r[i + 24] + data_r[i + 28];
					data_i[i] <= data_i[i] + data_i[i + 4];
					data_i[i + 8] <= data_i[i + 8] + data_i[i + 12];
					data_i[i + 16] <= data_i[i + 16] + data_i[i + 20];
					data_i[i + 24] <= data_i[i + 24] + data_i[i + 28];
					data_r[i + 4] <= ((data_r[i] - data_r[i + 4]) * wr[i << 2] + (data_i[i + 4] - data_i[i]) * wi[i << 2] + $signed(50'd0)) >> 16;
					data_r[i + 12] <= ((data_r[i + 8] - data_r[i + 12]) * wr[i << 2] + (data_i[i + 12] - data_i[i + 8]) * wi[i << 2] + $signed(50'd0)) >> 16;
					data_r[i + 20] <= ((data_r[i + 16] - data_r[i + 20]) * wr[i << 2] + (data_i[i + 20] - data_i[i + 16]) * wi[i << 2] + $signed(50'd0)) >> 16;
					data_r[i + 28] <= ((data_r[i + 24] - data_r[i + 28]) * wr[i << 2] + (data_i[i + 28] - data_i[i + 24]) * wi[i << 2] + $signed(50'd0)) >> 16;
					data_i[i + 4] <= ((data_r[i] - data_r[i + 4]) * wi[i << 2] + (data_i[i] - data_i[i + 4]) * wr[i << 2] + $signed(50'd0)) >> 16;
					data_i[i + 12] <= ((data_r[i + 8] - data_r[i + 12]) * wi[i << 2] + (data_i[i + 8] - data_i[i + 12]) * wr[i << 2] + $signed(50'd0)) >> 16;
					data_i[i + 20] <= ((data_r[i + 16] - data_r[i + 20]) * wi[i << 2] + (data_i[i + 16] - data_i[i + 20]) * wr[i << 2] + $signed(50'd0)) >> 16;
					data_i[i + 28] <= ((data_r[i + 24] - data_r[i + 28]) * wi[i << 2] + (data_i[i + 24] - data_i[i + 28]) * wr[i << 2] + $signed(50'd0)) >> 16;
				end
				temp[2] <= fir_d;
			end
			3 : begin
				for (i = 0; i <= 31; i = i + 4) begin
					data_r[i] <= data_r[i] + data_r[i + 2];
					data_i[i] <= data_i[i] + data_i[i + 2];
					data_r[i + 1] <= data_r[i + 1] + data_r[i + 3];
					data_i[i + 1] <= data_i[i + 1] + data_i[i + 3];
					data_r[i + 2] <= ((data_r[i] - data_r[i + 2]) * wr[0] + (data_i[i + 2] - data_i[i]) * wi[0] + $signed(50'd0)) >> 16;
					data_r[i + 3] <= ((data_r[i + 1] - data_r[i + 3]) * wr[8] + (data_i[i + 3] - data_i[i + 1]) * wi[8] + $signed(50'd0)) >> 16;
					data_i[i + 2] <= ((data_r[i] - data_r[i + 2]) * wi[0] + (data_i[i] - data_i[i + 2]) * wr[0] + $signed(50'd0)) >> 16;
					data_i[i + 3] <= ((data_r[i + 1] - data_r[i + 3]) * wi[8] + (data_i[i + 1] - data_i[i + 3]) * wr[8] + $signed(50'd0)) >> 16;
				end
				temp[3] <= fir_d;
			end
			4 : begin
				for (i = 0; i <= 31; i = i + 2) begin
					data_r[i] <= data_r[i] + data_r[i + 1];
					data_i[i] <= data_i[i] + data_i[i + 1];
					data_r[i + 1] <= ((data_r[i] - data_r[i + 1]) * wr[0] + (data_i[i + 1] - data_i[i]) * wi[0] + $signed(50'd0)) >> 16;
					data_i[i + 1] <= ((data_r[i] - data_r[i + 1]) * wi[0] + (data_i[i] - data_i[i + 1]) * wr[0] + $signed(50'd0)) >> 16;
				end
				temp[4] <= fir_d;
			end
			5 : begin
				temp[5] <= fir_d;
			end
			6 : begin
				temp[6] <= fir_d;
			end
			7 : begin
				temp[7] <= fir_d;
			end
			8 : begin
				temp[8] <= fir_d;
			end
			9 : begin
				for (i = 0; i <= 8; i = i + 1) begin
					data_r[i] <= temp[i] << 2;
				end
				data_r[9] <= fir_d << 2;
				for (j = 0; j <= 31; j = j + 1) begin
					data_i[j] <= 0;
				end
			end
			10 : begin
				data_r[10] <= fir_d << 2;

				wr[0] <= 32'h00010000;
				wr[1] <= 32'h0000FB15;
				wr[2] <= 32'h0000EC83;
				wr[3] <= 32'h0000D4DB;
				wr[4] <= 32'h0000B504;
				wr[5] <= 32'h00008E3A;
				wr[6] <= 32'h000061F7;
				wr[7] <= 32'h000031F1;
				wr[8] <= 32'h00000000;
				wr[9] <= 32'hFFFFCE0F;
				wr[10] <= 32'hFFFF9E09;
				wr[11] <= 32'hFFFF71C6;
				wr[12] <= 32'hFFFF4AFC;
				wr[13] <= 32'hFFFF2B25;
				wr[14] <= 32'hFFFF137D;
				wr[15] <= 32'hFFFF04EB;
				wi[0] <= 32'h00000000;
				wi[1] <= 32'hFFFFCE0F;
				wi[2] <= 32'hFFFF9E09;
				wi[3] <= 32'hFFFF71C6;
				wi[4] <= 32'hFFFF4AFC;
				wi[5] <= 32'hFFFF2B25;
				wi[6] <= 32'hFFFF137D;
				wi[7] <= 32'hFFFF04EB;
				wi[8] <= 32'hFFFF0000;
				wi[9] <= 32'hFFFF04EB;
				wi[10] <= 32'hFFFF137D;
				wi[11] <= 32'hFFFF2B25;
				wi[12] <= 32'hFFFF4AFC;
				wi[13] <= 32'hFFFF71C6;
				wi[14] <= 32'hFFFF9E09;
				wi[15] <= 32'hFFFFCE0F;
			end
			default : begin
                data_r[count] <= fir_d << 2;
            end
		endcase
	end
end

endmodule