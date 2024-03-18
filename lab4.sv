module Seq(
    input clk,
    input rst_n,
    input in_valid,
    input [3:0] in_data,
    output logic out_valid,
    output logic out_data
);

logic [3:0] fifo [0:2];
logic [1:0] head ;
logic [1:0] head_nxt;
logic [1:0] count;
logic [1:0] count_nxt;

logic out_valid_nxt;
logic out_data_nxt;


always_comb begin
    if(!in_valid) begin
        head_nxt = 0;
        count_nxt = 0;
        out_valid_nxt = 0;
        out_data_nxt = 0;
    end
    else  begin //in_valid = 1
        //fifo[head] = in_data;
        head_nxt = (head == 2)? 0 : head + 1;
        if(count < 3) begin 
            count_nxt = count + 1;
        end
        if(count == 3) begin
            out_valid_nxt = 1;
            if( head_nxt == 0 && (fifo[0] < fifo[1] && fifo[1] < fifo[2]) || (fifo[0] > fifo[1] && fifo[1] > fifo[2]) ||
                head_nxt == 1 && (fifo[1] < fifo[2] && fifo[2] < fifo[0]) || (fifo[1] > fifo[2] && fifo[2] > fifo[0]) || 
                head_nxt == 2 && (fifo[2] < fifo[0] && fifo[0] < fifo[1]) || (fifo[2] > fifo[0] && fifo[0] > fifo[1])  ) begin
                out_data_nxt = 1;
            end
            else begin
                out_data_nxt = 0;
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 0;
        out_data <= 0;
        head <= 0;
        count <= 0;
    end
    else begin
        if(in_valid == 1) begin
            fifo[head] <= in_data;
            head <= head_nxt;
            count <= count_nxt;
        end
        
        out_valid <= out_valid_nxt;
        out_data <= out_data_nxt;
    end
end

endmodule