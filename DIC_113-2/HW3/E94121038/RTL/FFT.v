module  FFT(
    input           clk      , 
    input           rst      , 
    input signed [15:0]   fir_d    , 
    input           fir_valid,
    output reg         fft_valid, 
    output reg         done     ,
    output reg[15:0]   fft_d1   , 
    output reg[15:0]   fft_d2   ,
    output reg[15:0]   fft_d3   , 
    output reg[15:0]   fft_d4   , 
    output reg[15:0]   fft_d5   , 
    output reg[15:0]   fft_d6   , 
    output reg[15:0]   fft_d7   , 
    output reg[15:0]   fft_d8   ,
    output reg[15:0]   fft_d9   , 
    output reg[15:0]   fft_d10  , 
    output reg[15:0]   fft_d11  , 
    output reg[15:0]   fft_d12  , 
    output reg[15:0]   fft_d13  , 
    output reg[15:0]   fft_d14  , 
    output reg[15:0]   fft_d15  , 
    output reg[15:0]   fft_d0
);

/////////////////////////////////
// Please write your code here //
/////////////////////////////////

reg signed[17:0] data_r [15:0];
reg signed[17:0] data_i [15:0];
reg signed[15:0] temp [4:0];

reg [3:0] count;
reg ready;
reg signed [17:0] wr [7:0];
reg signed [17:0] wi [7:0];

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
	 else if(count == 4)begin
        fft_d0 <= data_r[0][17:2];
        fft_d1 <= data_r[8][17:2];
        fft_d2 <= data_r[4][17:2];
        fft_d3 <= data_r[12][17:2];       
        fft_d4 <= data_r[2][17:2];
        fft_d5 <= data_r[10][17:2];
        fft_d6 <= data_r[6][17:2];
        fft_d7 <= data_r[14][17:2];
        fft_d8 <= data_r[1][17:2];
        fft_d9 <= data_r[9][17:2];
        fft_d10 <= data_r[5][17:2];
        fft_d11 <= data_r[13][17:2];
        fft_d12 <= data_r[3][17:2];
        fft_d13 <= data_r[11][17:2];
        fft_d14 <= data_r[7][17:2];
        fft_d15 <= data_r[15][17:2];
    end
    else begin
        fft_d0 <= data_i[0][17:2];
        fft_d1 <= data_i[8][17:2];
        fft_d2 <= data_i[4][17:2];
        fft_d3 <= data_i[12][17:2];       
        fft_d4 <= data_i[2][17:2];
        fft_d5 <= data_i[10][17:2];
        fft_d6 <= data_i[6][17:2];
        fft_d7 <= data_i[14][17:2];
        fft_d8 <= data_i[1][17:2];
        fft_d9 <= data_i[9][17:2];
        fft_d10 <= data_i[5][17:2];
        fft_d11 <= data_i[13][17:2];
        fft_d12 <= data_i[3][17:2];
        fft_d13 <= data_i[11][17:2];
        fft_d14 <= data_i[7][17:2];
        fft_d15 <= data_i[15][17:2];
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
    else if (count == 6 &&  ~fir_valid) begin
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
    else if (count == 6) begin
        ready <= 1;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        fft_valid  <= 0;
    end
    else if (ready && (count == 4 || count == 5)) begin
        fft_valid <= 1;
    end
    else begin
        fft_valid <= 0;
    end  
end

integer i; 

always @(posedge clk or posedge rst) begin
    if (rst) begin
		for (i = 0; i <= 15; i = i + 1) begin
			data_r[i] <= 0;
			data_i[i] <= 0;
		end
        wr[0] <= 0;
        wr[1] <= 0;
        wr[2] <= 0;
        wr[3] <= 0;
        wr[4] <= 0;
        wr[5] <= 0;
        wr[6] <= 0;
        wr[7] <= 0;
        wi[0] <= 0;
        wi[1] <= 0;
        wi[2] <= 0;
        wi[3] <= 0;
        wi[4] <= 0;
        wi[5] <= 0;
        wi[6] <= 0;
        wi[7] <= 0;
		temp[0] <= 0;
		temp[1] <= 0;
		temp[2] <= 0;
		temp[3] <= 0;
        temp[4] <= 0;
	end
	else begin
        case (count)
            4'd0 : begin
                temp[0] <= fir_d;

                data_r[0] <= data_r[0] + data_r[8];
                data_r[1] <= data_r[1] + data_r[9];
                data_r[2] <= data_r[2] + data_r[10];
                data_r[3] <= data_r[3] + data_r[11];
                data_r[4] <= data_r[4] + data_r[12];
                data_r[5] <= data_r[5] + data_r[13];
                data_r[6] <= data_r[6] + data_r[14];
                data_r[7] <= data_r[7] + data_r[15];

                data_i[0] <= 0;
                data_i[1] <= 0;
                data_i[2] <= 0;
                data_i[3] <= 0;
                data_i[4] <= 0;
                data_i[5] <= 0;
                data_i[6] <= 0;
                data_i[7] <= 0;

                data_r[8] <= data_r[0] - data_r[8];
                data_r[9] <= ((data_r[1] - data_r[9]) * wr[1] + $signed(50'd0)) >> 16;
                data_r[10] <= ((data_r[2] - data_r[10]) * wr[2] + $signed(50'd0)) >> 16;
                data_r[11] <= ((data_r[3] - data_r[11]) * wr[3] + $signed(50'd0)) >> 16;
                data_r[12] <= ((data_r[4] - data_r[12]) * wr[4] + $signed(50'd0)) >> 16;
                data_r[13] <= ((data_r[5] - data_r[13]) * wr[5] + $signed(50'd0)) >> 16;
                data_r[14] <= ((data_r[6] - data_r[14]) * wr[6] + $signed(50'd0)) >> 16;
                data_r[15] <= ((data_r[7] - data_r[15]) * wr[7] + $signed(50'd0)) >> 16;
                
                data_i[8] <= 0;
                data_i[9] <= ((data_r[1] - data_r[9]) * wi[1] + $signed(50'd0)) >> 16;
                data_i[10] <= ((data_r[2] - data_r[10]) * wi[2] + $signed(50'd0)) >> 16;
                data_i[11] <= ((data_r[3] - data_r[11]) * wi[3] + $signed(50'd0)) >> 16;
                data_i[12] <= ((data_r[4] - data_r[12]) * wi[4] + $signed(50'd0)) >> 16;
                data_i[13] <= ((data_r[5] - data_r[13]) * wi[5] + $signed(50'd0)) >> 16;
                data_i[14] <= ((data_r[6] - data_r[14]) * wi[6] + $signed(50'd0)) >> 16;
                data_i[15] <= ((data_r[7] - data_r[15]) * wi[7] + $signed(50'd0)) >> 16;
            end
            4'd1 : begin
                temp[1] <= fir_d;

                data_r[0] <= data_r[0] + data_r[4];
                data_r[1] <= data_r[1] + data_r[5];
                data_r[2] <= data_r[2] + data_r[6];
                data_r[3] <= data_r[3] + data_r[7];
                data_r[4] <= data_r[0] - data_r[4];
                data_r[5] <= ((data_r[1] - data_r[5]) * wr[2] + (data_i[5] - data_i[1]) * wi[2] + $signed(50'd0)) >> 16;
                data_r[6] <= ((data_r[2] - data_r[6]) * wr[4] + (data_i[6] - data_i[2]) * wi[4] + $signed(50'd0)) >> 16;
                data_r[7] <= ((data_r[3] - data_r[7]) * wr[6] + (data_i[7] - data_i[3]) * wi[6] + $signed(50'd0)) >> 16;
                data_r[8] <= data_r[8] + data_r[12];
                data_r[9] <= data_r[9] + data_r[13];
                data_r[10] <= data_r[10] + data_r[14];
                data_r[11] <= data_r[11] + data_r[15];
                data_r[12] <= data_r[8] - data_r[12];
                data_r[13] <= ((data_r[9] - data_r[13]) * wr[2] + (data_i[13] - data_i[9]) * wi[2] + $signed(50'd0)) >> 16;
                data_r[14] <= ((data_r[10] - data_r[14]) * wr[4] + (data_i[14] - data_i[10]) * wi[4] + $signed(50'd0)) >> 16;
                data_r[15] <= ((data_r[11] - data_r[15]) * wr[6] + (data_i[15] - data_i[11]) * wi[6] + $signed(50'd0)) >> 16;

                data_i[0] <= data_i[0] + data_i[4];
                data_i[1] <= data_i[1] + data_i[5];
                data_i[2] <= data_i[2] + data_i[6];
                data_i[3] <= data_i[3] + data_i[7];
                data_i[4] <= data_i[0] - data_i[4];
                data_i[5] <= ((data_r[1] - data_r[5]) * wi[2] + (data_i[1] - data_i[5]) * wr[2] + $signed(50'd0)) >> 16;
                data_i[6] <= ((data_r[2] - data_r[6]) * wi[4] + (data_i[2] - data_i[6]) * wr[4] + $signed(50'd0)) >> 16;
                data_i[7] <= ((data_r[3] - data_r[7]) * wi[6] + (data_i[3] - data_i[7]) * wr[6] + $signed(50'd0)) >> 16;
                data_i[8] <= data_i[8] + data_i[12];
                data_i[9] <= data_i[9] + data_i[13];
                data_i[10] <= data_i[10] + data_i[14];
                data_i[11] <= data_i[11] + data_i[15];
                data_i[12] <= data_i[8] - data_i[12];
                data_i[13] <= ((data_r[9] - data_r[13]) * wi[2] + (data_i[9] - data_i[13]) * wr[2] + $signed(50'd0)) >> 16;
                data_i[14] <= ((data_r[10] - data_r[14]) * wi[4] + (data_i[10] - data_i[14]) * wr[4] + $signed(50'd0)) >> 16;
                data_i[15] <= ((data_r[11] - data_r[15]) * wi[6] + (data_i[11] - data_i[15]) * wr[6] + $signed(50'd0)) >> 16;
            end 
            4'd2 : begin
                temp[2] <= fir_d;

                data_r[0] <= data_r[0] + data_r[2];
                data_r[1] <= data_r[1] + data_r[3];
                data_r[2] <= data_r[0] - data_r[2];
                data_r[3] <= ((data_r[1] - data_r[3]) * wr[4] + (data_i[3] - data_i[1]) * wi[4] + $signed(50'd0)) >> 16;
                data_r[4] <= data_r[4] + data_r[6];
                data_r[5] <= data_r[5] + data_r[7];
                data_r[6] <= data_r[4] - data_r[6];
                data_r[7] <= ((data_r[5] - data_r[7]) * wr[4] + (data_i[7] - data_i[5]) * wi[4] + $signed(50'd0)) >> 16;
                data_r[8] <= data_r[8] + data_r[10];
                data_r[9] <= data_r[9] + data_r[11];
                data_r[10] <= data_r[8] - data_r[10];
                data_r[11] <= ((data_r[9] - data_r[11]) * wr[4] + (data_i[11] - data_i[9]) * wi[4] + $signed(50'd0)) >> 16;
                data_r[12] <= data_r[12] + data_r[14];
                data_r[13] <= data_r[13] + data_r[15];
                data_r[14] <= data_r[12] - data_r[14];
                data_r[15] <= ((data_r[13] - data_r[15]) * wr[4] + (data_i[15] - data_i[13]) * wi[4] + $signed(50'd0)) >> 16;

                data_i[0] <= data_i[0] + data_i[2];
                data_i[1] <= data_i[1] + data_i[3];
                data_i[2] <= data_i[0] - data_i[2];
                data_i[3] <= ((data_r[1] - data_r[3]) * wi[4] + (data_i[1] - data_i[3]) * wr[4] + $signed(50'd0)) >> 16;
                data_i[4] <= data_i[4] + data_i[6];
                data_i[5] <= data_i[5] + data_i[7];
                data_i[6] <= data_i[4] - data_i[6];
                data_i[7] <= ((data_r[5] - data_r[7]) * wi[4] + (data_i[5] - data_i[7]) * wr[4] + $signed(50'd0)) >> 16;
                data_i[8] <= data_i[8] + data_i[10];
                data_i[9] <= data_i[9] + data_i[11];
                data_i[10] <= data_i[8] - data_i[10];
                data_i[11] <= ((data_r[9] - data_r[11]) * wi[4] + (data_i[9] - data_i[11]) * wr[4] + $signed(50'd0)) >> 16;
                data_i[12] <= data_i[12] + data_i[14];
                data_i[13] <= data_i[13] + data_i[15];
                data_i[14] <= data_i[12] - data_i[14];
                data_i[15] <= ((data_r[13] - data_r[15]) * wi[4] + (data_i[13] - data_i[15]) * wr[4] + $signed(50'd0)) >> 16;
            end
            4'd3 : begin
                temp[3] <= fir_d;

                data_r[0] <= data_r[0] + data_r[1];
                data_r[1] <= data_r[0] - data_r[1];
                data_r[2] <= data_r[2] + data_r[3];
                data_r[3] <= data_r[2] - data_r[3];
                data_r[4] <= data_r[4] + data_r[5];
                data_r[5] <= data_r[4] - data_r[5];
                data_r[6] <= data_r[6] + data_r[7];
                data_r[7] <= data_r[6] - data_r[7];
                data_r[8] <= data_r[8] + data_r[9];
                data_r[9] <= data_r[8] - data_r[9];
                data_r[10] <= data_r[10] + data_r[11];
                data_r[11] <= data_r[10] - data_r[11];
                data_r[12] <= data_r[12] + data_r[13];
                data_r[13] <= data_r[12] - data_r[13];
                data_r[14] <= data_r[14] + data_r[15];
                data_r[15] <= data_r[14] - data_r[15];

                data_i[0] <= data_i[0] + data_i[1];
                data_i[1] <= data_i[0] - data_i[1];
                data_i[2] <= data_i[2] + data_i[3];
                data_i[3] <= data_i[2] - data_i[3];
                data_i[4] <= data_i[4] + data_i[5];
                data_i[5] <= data_i[4] - data_i[5];
                data_i[6] <= data_i[6] + data_i[7];
                data_i[7] <= data_i[6] - data_i[7];
                data_i[8] <= data_i[8] + data_i[9];
                data_i[9] <= data_i[8] - data_i[9];
                data_i[10] <= data_i[10] + data_i[11];
                data_i[11] <= data_i[10] - data_i[11];
                data_i[12] <= data_i[12] + data_i[13];
                data_i[13] <= data_i[12] - data_i[13];
                data_i[14] <= data_i[14] + data_i[15];
                data_i[15] <= data_i[14] - data_i[15];
            end
            4'd4 : begin
                temp[4] <= fir_d;
            end
            4'd5 : begin
                data_r[0] <= temp[0] << 2;
                data_r[1] <= temp[1] << 2;
                data_r[2] <= temp[2] << 2;
                data_r[3] <= temp[3] << 2;
                data_r[4] <= temp[4] << 2;
                data_r[5] <= fir_d << 2;
                data_i[0] <= 0;
                data_i[1] <= 0;
                data_i[2] <= 0;
                data_i[3] <= 0;
                data_i[4] <= 0;
                data_i[5] <= 0;
                data_i[6] <= 0;
                data_i[7] <= 0;
                data_i[8] <= 0;
                data_i[9] <= 0;
                data_i[10] <= 0;
                data_i[11] <= 0;
                data_i[12] <= 0;
                data_i[13] <= 0;
                data_i[14] <= 0;
                data_i[15] <= 0;
            end
            4'd6 : begin
                data_r[6] <= fir_d << 2;

                wr[0] <= 32'h00010000;
                wr[1] <= 32'h0000EC83;
                wr[2] <= 32'h0000B504;
                wr[3] <= 32'h000061F7;
                wr[4] <= 32'h00000000;
                wr[5] <= 32'hFFFF9E09;
                wr[6] <= 32'hFFFF4AFC;
                wr[7] <= 32'hFFFF137D;
                wi[0] <= 32'h00000000;
                wi[1] <= 32'hFFFF9E09;
                wi[2] <= 32'hFFFF4AFC;
                wi[3] <= 32'hFFFF137D;
                wi[4] <= 32'hFFFF0000;
                wi[5] <= 32'hFFFF137D;
                wi[6] <= 32'hFFFF4AFC;
                wi[7] <= 32'hFFFF9E09;
            end
            default : begin
                data_r[count] <= fir_d << 2;
            end
        endcase
    end
end

endmodule