`timescale 1ns/10ps

module  ATCONV(
        input		clk       ,
        input		rst       ,
        output          ROM_rd    ,
        output [11:0]	iaddr     ,
        input signed [15:0]	idata     ,
        output          layer0_ceb,
        output          layer0_web,   
        output [11:0]   layer0_A  ,
        output [15:0]   layer0_D  ,
        input  [15:0]   layer0_Q  ,
        output          layer1_ceb,
        output          layer1_web,
        output [11:0]   layer1_A  ,
        output [15:0]   layer1_D  ,
        input  [15:0]   layer1_Q  ,
        output          done        
);

/////////////////////////////////
// Please write your code here //
/////////////////////////////////

parameter IDLE = 3'd0, 
          CONV = 3'd1,
          CONV_WRITE = 3'd2,
          POOL = 3'd3,
          POOL_WRITE = 3'd4,
          DONE = 3'd5;

reg signed [2:0] wx, wy;
reg [11:0] ox, oy;
reg ix, iy;
reg [10:0] px, py;
reg [2:0] curr_state, next_state;
reg signed [13:0] real_x, real_y;
reg signed [15:0] w [0:8];
reg signed [15:0] bias;
reg signed [31:0] acc;
reg [15:0] mx;

wire signed [15:0] out_data;
assign iaddr = (real_y << 6) + real_x;
assign ROM_rd = (curr_state == CONV);
assign out_data = acc[15:0] + bias;
assign layer0_D = (out_data[15])? 16'b0 : out_data;
assign layer0_ceb = (curr_state == CONV_WRITE || curr_state == POOL);
assign layer0_web = (curr_state == POOL);
assign layer0_A = (curr_state == CONV_WRITE)? (oy << 6) + ox : (((py << 1) + iy) << 6) + ((px << 1) + ix);
assign layer1_ceb = (curr_state == POOL_WRITE);
assign layer1_web = 0;
assign layer1_A = (py << 5) + px;
assign layer1_D = {mx[15:4] + |mx[3:0], 4'b0000 };
assign done = (curr_state == DONE);

always @(*) begin
        if (rst) begin
                real_x = 0;
                real_y = 0;
        end
        else begin
                if ($signed(ox) + wx < 0) real_x = 0;
                else if ($signed(ox) + wx > 63) real_x = 63;
                else real_x = $signed(ox) + wx ;

                if ($signed(oy) + wy < 0) real_y = 0;
                else if ($signed(oy) + wy > 63) real_y = 63;
                else real_y = $signed(oy) + wy ;
        end
end

always @(*) begin
        if (rst) begin
                next_state <= IDLE;
        end
        else begin
                case (curr_state)
                        DONE : next_state <= DONE;
                        CONV : next_state <= (wx == 2 && wy == 2)? CONV_WRITE : CONV;
                        CONV_WRITE : next_state <= (ox == 63 && oy == 63)? POOL : CONV;
                        POOL : next_state <= (ix == 1 && iy == 1)? POOL_WRITE : POOL;
                        POOL_WRITE : next_state <= (px == 31 && py == 31)? DONE : POOL; 
                        default: next_state <= CONV;
                endcase
        end
end

always @(posedge clk or posedge rst) begin
        if (rst) curr_state <= IDLE;
        else curr_state <= next_state;
end

always @(posedge clk or posedge rst) begin // state: IDLE
        if (rst) begin
                w[0] <= 16'h0;
                w[1] <= 16'h0;
                w[2] <= 16'h0;
                w[3] <= 16'h0;
                w[4] <= 16'h0;
                w[5] <= 16'h0;
                w[6] <= 16'h0;
                w[7] <= 16'h0;
                w[8] <= 16'h0;
                bias <= 16'h0;
        end
        else if (curr_state == IDLE) begin
                w[0] <= 16'hFFFF;
                w[1] <= 16'hFFFE;
                w[2] <= 16'hFFFF;
                w[3] <= 16'hFFFC;
                w[4] <= 16'h0010;
                w[5] <= 16'hFFFC;
                w[6] <= 16'hFFFF;
                w[7] <= 16'hFFFE;
                w[8] <= 16'hFFFF;
                bias <= 16'hFFF4;
        end
end

always @(posedge clk or posedge rst) begin // state: CONV & CONV_WRITE
        if (rst) begin
                acc <= 0;
        end
        else if (curr_state == CONV) begin
                acc <= acc + (idata * (
                        (wx == -2 && wy == -2)? w[0] :
                        (wx == 0 && wy == -2)? w[1] : 
                        (wx == 2 && wy == -2)? w[2] :
                        (wx == -2 && wy == 0)? w[3] :
                        (wx == 0 && wy == 0)? w[4] :
                        (wx == 2 && wy == 0)? w[5] :
                        (wx ==-2 && wy == 2)? w[6] :
                        (wx == 0 && wy == 2)? w[7] : w[8]) >> 4);
        end
        else if (curr_state == CONV_WRITE) begin
                acc <= 0;
        end
end

always @(posedge clk or posedge rst) begin // state: POOL
        if (rst) begin
                mx <= 0;
        end
        else if (curr_state == POOL) begin
                mx <= (layer0_Q > mx)? layer0_Q : mx;
        end
        else if (curr_state == POOL_WRITE) begin
                mx <= 0;
        end
end

always @(posedge clk or posedge rst) begin
        if (rst) begin
                wx <= 0;
                wy <= 0;        
        end
        else if (curr_state == CONV) begin
                if (wx == 2) begin
                        wx <= -2;
                        wy <= (wy == 2)? -2 : wy + 2;
                end
                else wx <= wx + 2;
        end
        else begin
                wx <= -2;
                wy <= -2;
        end
end

always @(posedge clk or posedge rst) begin
        if (rst) begin
                ox <= 0;
                oy <= 0;
        end
        else if (curr_state == CONV_WRITE) begin
                if (ox == 63) begin
                        ox <= 0;
                        oy <= (oy == 63)? 0 : oy + 1;
                end
                else ox <= ox + 1;
        end
end

always @(posedge clk or posedge rst) begin
        if (rst) begin
                ix <= 0;
                iy <= 0;
        end
        else if (curr_state == POOL) begin
                if (ix == 1) begin
                        ix <= ~ix;
                        iy <= ~iy;
                end
                else ix <= ~ix;
        end
        else begin
                ix <= 0;
                iy <= 0;
        end
end

always @(posedge clk or posedge rst) begin
        if (rst) begin
                px <= 0;
                py <= 0;
        end
        else if (curr_state == POOL_WRITE) begin
                if (px == 31) begin
                        px <= 0;
                        py <= (py == 31)? 0 : py + 1;
                end
                else px <= px + 1;
        end
end

endmodule
