module lcd_ctrl(clk, reset, datain, cmd, cmd_valid, dataout, output_valid, busy);
input           clk;
input           reset;
input   [7:0]   datain;
input   [2:0]   cmd;
input           cmd_valid;
output  [7:0]   dataout;
output reg         output_valid;
output reg          busy;

parameter REFLASH = 0, LOAD = 1, SHIFT_R = 2, SHIFT_L = 3, SHIFT_U = 4, SHIFT_D = 5, IDLE = 6;
integer i, j;

reg [2:0] next_state, curr_state;
reg [2:0] px, py, ox, oy, nx, ny;
reg [8:0] data [0:5][0:5];
reg [2:0] cmd_reg;

assign dataout = data[nx + ox][ny + oy];

always @(posedge clk or posedge reset) begin
    if (reset) cmd_reg <= 6;
    else if (cmd_valid) cmd_reg <= cmd;
end

always @(*) begin
    if (reset) begin
        next_state = IDLE;
    end
    else if (cmd_valid) begin
        case (cmd)
            0 : next_state = REFLASH;
            1 : next_state = LOAD;
            2 : next_state = SHIFT_R;
            3 : next_state = SHIFT_L;
            4 : next_state = SHIFT_U;
            5 : next_state = SHIFT_D;
            default: next_state = IDLE;
        endcase
    end
    else next_state = cmd_reg;
end

always @(posedge clk or posedge reset) begin
    if (reset) curr_state <= IDLE;
    else curr_state <= next_state;
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        px <= 0;
        py <= 0;
        for (i = 0; i < 6; i = i + 1) begin
            for (j = 0; j < 6; j = j + 1) begin
                data[i][j] <= 0;
            end
        end
    end
    else if (cmd_valid) begin
        px <= 0;
        py <= 0;
    end
    else if (curr_state == LOAD) begin
        if (px == 5) begin
            px <= 0;
            py <= py + 1;
        end
        else px <= px + 1;
        if (py < 6) data[px][py] <= datain;
    end
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        nx <= 0;
        ny <= 0;
        output_valid <= 0;
        busy <= 0;
    end
    else if (oy == 2 && ox == 2) begin
        output_valid <= 0;
        busy <= 0;
    end
    else if (curr_state == REFLASH) begin
        output_valid <= 1;
        busy <= 1;
    end
    else if (curr_state == LOAD) begin
        nx <= 2;
        ny <= 2;
        if (py > 5 && ox <= 2 && oy <= 2) output_valid <= 1;
        busy <= 1;
    end
    else if (curr_state == SHIFT_R && !cmd_valid) begin
        if (nx < 3 && !output_valid ) nx <= nx + 1;
        output_valid <= 1;
    end
    else if (curr_state == SHIFT_L && !cmd_valid) begin
        if (nx > 0 && !output_valid) nx <= nx - 1;
        output_valid <= 1;
    end
    else if (curr_state == SHIFT_U && !cmd_valid) begin
        if (ny > 0 && !output_valid) ny <= ny - 1;
        output_valid <= 1;
    end
    else if (curr_state == SHIFT_D && !cmd_valid) begin
        if (ny < 3 && !output_valid) ny <= ny + 1;
        output_valid <= 1;
    end
    else if (curr_state >= 2 && curr_state <= 5) begin
        busy <= 1;
    end
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        ox <= 0;
        oy <= 0;
    end
    else if (output_valid) begin
        if (ox == 2) begin
            ox <= 0;
            oy <= oy + 1;
        end
        else ox <= ox + 1;
    end
    else begin
        ox <= 0;
        oy <= 0;
    end
end
                                                                                     
endmodule
