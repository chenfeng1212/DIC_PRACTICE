module MCH (
    input               clk,
    input               reset,
    input       [ 7:0]  X,
    input       [ 7:0]  Y,
    output              Done,
    output      [16:0]  area
);

/////////////////////////////////
// Please write your code here //
/////////////////////////////////

parameter READ = 3'd0, SORT = 3'd1, DELETE = 3'd2, CAL = 3'd3, OUT = 3'd4;

reg [2:0] next_state, curr_state;
reg [4:0] count, ptr1, ptr2, check, valid, counter;
reg [7:0] X_reg [0:19];
reg [7:0] Y_reg [0:19];
reg signed [17:0] area_reg;
reg signed [17:0] cal_x1, cal_x2, cal_y1, cal_y2;
reg [7:0] temp1, temp2;
integer i;


wire signed [17:0] cp;

assign Done = (curr_state == OUT);
assign area = area_reg;
assign cp = (cal_x1 * cal_y2) - (cal_x2 * cal_y1);

always @(*) begin
    if (reset) next_state = READ;
    else begin
        case (curr_state)
            READ   : next_state = (count == 19) ? SORT : READ;
            SORT   : next_state = (ptr1 == 20) ? DELETE : SORT;
            DELETE : next_state = (check >= valid) ? CAL : DELETE;
            CAL    : next_state = (counter == valid) ? OUT : CAL;
            default: next_state = READ;
        endcase
    end
end

always @(posedge clk or posedge reset) begin
    if (reset) curr_state <= READ;
    else curr_state <= next_state;
end

always @(*) begin
    case (curr_state)
        SORT: begin
            if (ptr1 == ptr2 + 1) begin
                cal_x1 = X_reg[ptr2] - X_reg[0];
                cal_x2 = X_reg[ptr1] - X_reg[0];
                cal_y1 = Y_reg[ptr2] - Y_reg[0];
                cal_y2 = Y_reg[ptr1] - Y_reg[0];
            end
            else begin
                cal_x1 = X_reg[ptr2] - X_reg[0];
                cal_x2 = temp1 - X_reg[0];
                cal_y1 = Y_reg[ptr2] - Y_reg[0];
                cal_y2 = temp2 - Y_reg[0];
            end
        end
        DELETE: begin
            if (check == 0) begin
                cal_x1 = X_reg[0] - X_reg[valid];
                cal_x2 = X_reg[1] - X_reg[0];
                cal_y1 = Y_reg[0] - Y_reg[valid];
                cal_y2 = Y_reg[1] - Y_reg[0];
            end else if (check == valid) begin
                cal_x1 = X_reg[valid] - X_reg[valid - 1];
                cal_x2 = X_reg[0] - X_reg[valid];
                cal_y1 = Y_reg[valid] - Y_reg[valid - 1];
                cal_y2 = Y_reg[0] - Y_reg[valid];
            end else begin
                cal_x1 = X_reg[check] - X_reg[check - 1];
                cal_x2 = X_reg[check + 1] - X_reg[check];
                cal_y1 = Y_reg[check] - Y_reg[check - 1];
                cal_y2 = Y_reg[check + 1] - Y_reg[check];
            end
        end
        CAL: begin
            if (counter == valid) begin
                cal_x1 = X_reg[valid];
                cal_x2 = X_reg[0];
                cal_y1 = Y_reg[valid];
                cal_y2 = Y_reg[0];
            end else begin
                cal_x1 = X_reg[counter];
                cal_x2 = X_reg[counter + 1];
                cal_y1 = Y_reg[counter];
                cal_y2 = Y_reg[counter + 1];
            end
        end
        default: begin
            cal_x1 = 0; cal_x2 = 0; cal_y1 = 0; cal_y2 = 0;
        end
    endcase
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        count <= 0;
        for (i = 0; i < 20; i = i + 1) begin
            X_reg[i] <= 0;
            Y_reg[i] <= 0;
        end
        temp1 <= 0;
        temp2 <= 0;
    end else if (curr_state == READ) begin
        if ((Y_reg[0] > Y) || (Y_reg[0] == Y && X_reg[0] > X)) begin
            X_reg[count] <= X_reg[0];
            Y_reg[count] <= Y_reg[0];
            X_reg[0] <= X;
            Y_reg[0] <= Y;
        end else begin
            X_reg[count] <= X;
            Y_reg[count] <= Y;
        end
        count <= count + 1;
    end else if (curr_state == SORT) begin
        if (ptr1 == ptr2 + 1) begin
            temp1 <= X_reg[ptr1];
            temp2 <= Y_reg[ptr1];
        end
        if (ptr2 < 1 || cp >= 0) begin
            if ((ptr1 == ptr2 + 1) && (cp == 0) && (X_reg[ptr1] < X_reg[ptr2]) && (Y_reg[ptr1] == Y_reg[ptr2])) begin
                X_reg[ptr2 + 1] <= X_reg[ptr2];
                Y_reg[ptr2 + 1] <= Y_reg[ptr2];
            end 
            else if ((ptr1 != ptr2 + 1) && (cp == 0) && (temp1 < X_reg[ptr2]) && (temp2 == Y_reg[ptr2])) begin
                X_reg[ptr2 + 1] <= X_reg[ptr2];
                Y_reg[ptr2 + 1] <= Y_reg[ptr2];
            end
            else if (ptr1 != ptr2 + 1) begin
                X_reg[ptr2 + 1] <= temp1;
                Y_reg[ptr2 + 1] <= temp2;
            end
        end else begin
            X_reg[ptr2 + 1] <= X_reg[ptr2];
            Y_reg[ptr2 + 1] <= Y_reg[ptr2];
        end
    end else if (curr_state == DELETE && cp <= 0 && valid > 0) begin
        for (i = 0; i < 19; i = i + 1) begin
            if (i >= check && i < valid) begin
                X_reg[i] <= X_reg[i + 1];
                Y_reg[i] <= Y_reg[i + 1];
            end
        end
    end else if (curr_state == OUT) begin
        count <= 0;
        X_reg[0] <= 0;
        Y_reg[0] <= 0;
        temp1 <= 0;
        temp2 <= 0;
    end
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        ptr1 <= 0;
        ptr2 <= 0;
    end else if (curr_state == READ) begin
        ptr1 <= 2;
        ptr2 <= 1;
    end else if (curr_state == SORT) begin
        if (ptr2 < 1 || cp >= 0) begin
            if ((ptr1 == ptr2 + 1) && (cp == 0) && (X_reg[ptr1] < X_reg[ptr2]) && (Y_reg[ptr1] == Y_reg[ptr2])) begin
                ptr2 <= ptr2 - 1;
            end 
            else if ((ptr1 != ptr2 + 1) && (cp == 0) && (temp1 < X_reg[ptr2]) && (temp2 == Y_reg[ptr2])) begin
                ptr2 <= ptr2 - 1;
            end
            else begin
                ptr1 <= ptr1 + 1;
                ptr2 <= ptr1;
            end
            
        end else begin
            ptr2 <= ptr2 - 1;
        end
    end
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        check <= 0;
        valid <= 0;
    end else if (curr_state == READ) begin
        check <= 0;
        valid <= 19;
    end else if (curr_state == DELETE) begin
        if (cp <= 0 && valid > 0) begin
            valid <= valid - 1;
            if (check > 0) check <= check - 1;
        end else begin
            check <= check + 1;
        end
    end
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        area_reg <= 0;
        counter <= 0;
    end else if (curr_state == READ) begin
        area_reg <= 0;
        counter <= 0;
    end else if (curr_state == CAL) begin
        area_reg <= area_reg + cp;
        counter <= counter + 1;
    end
end


endmodule