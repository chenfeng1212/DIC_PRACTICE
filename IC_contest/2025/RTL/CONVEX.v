module CONVEX(
input CLK,
input RST,
input [4:0] PT_XY,
output reg READ_PT,
output reg [9:0] DROP_X,
output reg [9:0] DROP_Y,
output reg DROP_V);

parameter IDLE = 3'd0, READ_X = 3'd1, READ_Y = 3'd2, SORT = 3'd3, POINT = 3'd4, CO = 3'd5, SHIFT = 3'd6, WRITE = 3'd7;
reg is_l;
reg [2:0] CS, NS;
reg [9:0] X [12:0];
reg [9:0] Y [12:0];
reg has_tan;
reg [3:0] num; //number of point
reg [3:0] index; //current test point
reg [3:0] ptr1;
reg [3:0] ptr2;
reg [12:0] del_point;
reg [10:0] X_1, X_2, Y_1, Y_2;
wire [1:0] compare;
reg [1:0] index_point;
wire cross_done;  
reg [4:0] position [1:0];
reg compare_temp ;
reg enable;
reg is_tan;
integer i; 

CROSS c1(.clk(CLK), .enable(enable), .X_1(X_1), .X_2(X_2), .Y_1(Y_1), .Y_2(Y_2), .compare(compare), .valid(cross_done));

always @(*) begin   //NS
    if (RST) begin
        NS = IDLE;
    end
    else begin
        case (CS)
            READ_X : begin
                if(is_l) NS = READ_Y;
                else NS = READ_X;
            end
            READ_Y : begin
                if(is_l) begin
                    if (num < 2) begin
                        NS = READ_X;
                    end
                    else if(num == 2)NS = SORT;
                    else NS = POINT;
                end
                else NS = READ_Y;
            end
            SORT : begin    //判斷條件等實作完SORT
                if(ptr1 == num) NS = READ_X;
                else NS = SORT;
            end
            POINT : begin
                if (compare[1]) begin
                    NS = CO;
                end
                else begin
                    if (index == num - 1) begin
                        if (has_tan) NS = SHIFT;
                        else NS = WRITE;
                    end
                    else if (del_point[num - 1] == 1) NS = SHIFT;
                    else NS = POINT;
                end
            end
            CO : begin
                NS = POINT;
            end
            SHIFT : begin
                if(ptr1 == num - 1) NS = SORT;
                else NS = SHIFT;
            end
            WRITE : begin
                NS = READ_X;
            end
            default: begin  //IDLE
                NS = READ_X;
            end 
        endcase
    end
end

always @(posedge CLK or posedge RST) begin  //NS
    if(RST) CS <= IDLE;
    else CS <= NS;
end

always @(*) begin   //READ_PT 用NS感覺很邪門
    if(NS == READ_X) READ_PT = 1'b1;
    else READ_PT = 1'b0;
end
    
always @(posedge CLK or posedge RST) begin //is_l, num, X, Y, ptr
    if (RST) begin
        for (i = 0; i < 13; i = i + 1) begin
            X[i] <= 10'b0;
            Y[i] <= 10'b0;
        end
        is_l <= 1'b0;
        num <= 4'd0;
        ptr1 <= 4'd2;
        ptr2 <= 4'd1;
    end
    else begin
        case (CS)
            READ_X: begin
                if (is_l) begin
                    X[num][4:0] <= PT_XY;
                end
                else begin
                    X[num][9:5] <= PT_XY;
                end
                is_l <= ~is_l;
            end
            READ_Y: begin
                if (is_l) begin
                    Y[num][4:0] <= PT_XY;
                    num <= num + 1;
                end
                else begin
                    Y[num][9:5] <= PT_XY;
                end
                is_l <= ~is_l;
            end
            SORT: begin
                if (cross_done) begin
                    if (compare[0] || ptr2 == 0) begin
                        ptr2 <= ptr1;
                        ptr1 <= ptr1 + 4'd1;
                        for (i = 0; i < 12; i = i + 1) begin
                            if (i == ptr2 + 1) begin
                                X[i] <= X[ptr1];
                                Y[i] <= Y[ptr1];
                            end
                            else if (i > ptr2 + 1 && i <= ptr1) begin
                                X[i] <= X[i - 1];
                                Y[i] <= Y[i - 1];
                            end
                        end
                    end
                    else begin
                        ptr2 <= ptr2 - 4'd1;
                    end
                end
            end
            CO: begin
                //num <= num - 4'd1;
            end
            POINT: begin
                ptr1 <= 4'd0;
            end
            SHIFT: begin
                if(del_point) begin
                    if (del_point[0]) begin
                        for (i = 0; i < 12; i = i + 1) begin
                            if(i >= ptr1) begin
                                X[i] <= X[i+1];
                                Y[i] <= Y[i+1];
                            end
                        end
                        num <= num - 4'd1;
                    end
                    else ptr1 <= ptr1 + 4'd1;
                end
                else begin
                    ptr1 <= num - 1;
                    ptr2 <= num - 2;
                end
            end
            WRITE: begin
                num <= num - 1;
            end
        endcase
    end
end

always @(*) begin   //X_1, X_2, Y_1, Y_2
    if (CS == SORT) begin
        X_1 = X[0] - X[ptr1];
        Y_1 = Y[0] - Y[ptr1];
        X_2 = X[0] - X[ptr2];
        Y_2 = Y[0] - Y[ptr2];
    end
    else begin //POINT 控制cross
        X_1 = X[position[0]] - X[index];
        X_2 = X[position[1]] - X[index];
        Y_1 = Y[position[0]] - Y[index];
        Y_2 = Y[position[1]] - Y[index];
    end
end

always @(posedge CLK or posedge RST) begin //enable
    if (RST) begin
        enable <= 1'b0;
    end
    else begin
        case (CS)
            SORT: enable <= ~cross_done;
            POINT: enable <= ~cross_done;
            default: enable <= 1'b0;
        endcase
    end
end

always @(posedge CLK or posedge RST) begin  //DROP_X, DROP_Y, DROP_V, has_tan, index, del_point, index_point
    if (RST) begin
        position[0] <= 4'd0;
        position[1] <= 4'd0;
        index <= 4'd0;
        index_point <= 2'd0;
        compare_temp <= 0;
        has_tan <= 0;
        is_tan <= 0;
        del_point <= 0;
    end
    else if (CS == POINT) begin
        case (index_point)
            2'd0 : begin
                if (index == 0) position[0] <= num - 2;
                else position[0] <= index - 1;
                position[1] <= num - 1;
                if (cross_done) begin
                    if (compare == 2) compare_temp <= 0;
                    else begin
                        compare_temp <= compare;
                        index_point <= 1;
                    end
                end
                DROP_V <= 0;
                is_tan <= 0;
            end 
            2'd1 : begin
                if (index == num - 2) position[1] <= 0;
                else position[1] <= index + 1;
                if (cross_done) begin
                    if (compare_temp == compare) begin
                        is_tan <= 1;
                    end
                    index_point <= 2;
                end
            end
            2'd2 : begin
                if (index == num - 2) position[0] <= 0;
                else position[0] <= index + 1;
                position[1] <= num - 1;
                if (cross_done) begin 
                    if (compare == 2) begin 
                        compare_temp <= 1;
                    end
                    else begin
                        compare_temp <= compare;
                    end
                    index_point <= 3; 
                end
            end
            2'd3 : begin
                if (index == 0) position[1] <= num - 2;
                else position[1] <= index - 1;
                if (cross_done) begin
                    if (compare_temp != compare) begin
                        if (~is_tan) begin
                            del_point[index] <= 1;
                            DROP_X <= X[index];
                            DROP_Y <= Y[index];
                            DROP_V <= 1;
                        end
                        else begin
                            is_tan <= 1;
                            has_tan <= 1;
                        end
                    end
                    index_point <= 0;
                    index <= index + 1;
                end
            end
        endcase
    end
    else if(CS == CO)begin
        has_tan <= 1;
        if(index_point == 2'd0) begin
            if (X[position[0]] < X[index] && X[index] < X[num - 1]) begin
                DROP_X <= X[index];
                DROP_Y <= Y[index];
                del_point[index] <= 1'b1;
            end
            else if (X[position[0]] < X[num - 1] && X[num - 1] < X[index]) begin
                DROP_X <= X[num-1];
                DROP_Y <= Y[num-1];
                del_point[num-1] <= 1'b1;
            end
            else if (X[index] < X[position[0]] && X[position[0]] < X[num - 1]) begin
                DROP_X <= X[position[0]];
                DROP_Y <= Y[position[0]];
                del_point[position[0]] <= 1'b1;
            end
            else if (X[index] < X[num - 1] && X[num - 1] < X[position[0]]) begin
                DROP_X <= X[num-1];
                DROP_Y <= Y[num-1];
                del_point[num-1] <= 1'b1;
            end
            else if (X[num - 1] < X[position[0]] && X[position[0]] < X[index]) begin
                DROP_X <= X[position[0]];
                DROP_Y <= Y[position[0]];
                del_point[position[0]] <= 1'b1;
            end
            else if (X[num - 1] < X[index] && X[index] < X[position[0]]) begin
                DROP_X <= X[index];
                DROP_Y <= Y[index];
                del_point[index] <= 1'b1;
            end
            else begin
                DROP_X <= X[num-1];
                DROP_Y <= Y[num-1];
                del_point[num-1] <= 1'b1;
            end
            DROP_V <= 1'b1;
        end
        index_point <= 0;
        index <= index + 1;
    end
    else if (CS == WRITE) begin
        DROP_X <= X[num-1];
        DROP_Y <= Y[num-1];
        DROP_V <= 1;
    end
    else if (CS == SHIFT) begin
        del_point <= del_point >>1;
    end
    else begin
        index_point <= 0;
        compare_temp <= 0;
        is_tan <= 0;
        if (CS == READ_X) begin
            index <= 0;
            has_tan <= 0;
            DROP_V <= 0;
        end
    end
end




endmodule

module CROSS (clk, enable, X_1, X_2, Y_1, Y_2, compare, valid);

input clk;
input enable;
input signed [10:0] X_1;
input signed [10:0] X_2;
input signed [10:0] Y_1;
input signed [10:0] Y_2;
output reg valid;
output reg [1:0] compare;

parameter one = 2'd0, two = 2'd1, write = 2'd2, idle = 2'd3;
reg [1:0] cur_state;
reg [1:0] new_state;
reg signed [20:0] temp [1:0];


always@(*) begin
    if (enable) begin
        case (cur_state)
            one : begin
                new_state = two;
            end
            two : begin
                new_state = write;
            end
            write : begin
                new_state = idle;
            end
            default : begin
                new_state = one;
            end
        endcase
    end
    else begin
       new_state = idle;
    end
end

always @(posedge clk) begin
    cur_state <= new_state;
end

always @(*) begin
    if (~enable) begin
        compare = 0;
        temp[0] = 0;
        temp[1] = 0;
        valid = 0; 
    end
    else begin
        case (cur_state)
            one : begin
                compare = 0;
                temp[1] = 0;
                valid = 0; 
                temp[0] = X_1 * Y_2;
            end
            two : begin
                compare = 0;
                temp[0] = X_1 * Y_2;
                valid = 0; 
                temp[1] = X_2 * Y_1;
            end
            write : begin
                compare[1] = (temp[0] == temp[1]);
                compare[0] = (temp[0] > temp[1]);
                temp[0] = X_1 * Y_2;
                temp[1] = X_2 * Y_1;
                valid = 1;
            end
            default : begin
                valid = 0;
                compare = 0;
                temp[0] = X_1 * Y_2;
                temp[1] = 0;
            end
        endcase
    end
end
endmodule