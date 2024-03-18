//// 01 02 03 all pass catcat
module Fpc(
// input signals
clk,
rst_n,
in_valid,
in_a,
in_b,
mode,
// output signals
out_valid,
out
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid, mode;
input [15:0] in_a, in_b;
output logic out_valid;
output logic [15:0] out;
logic out_valid_nxt;
logic [15:0] out_nxt;
logic signed [4:0]power_a,power_b,max_power;
logic [8:0] fraction_a, fraction_b;
logic [8:0] shift_a,shift_b;
logic [8:0] adder_a,adder_b;
logic [9:0] sum;
logic [8:0] sum_complement;
logic [15:0] mul;
logic signed [4:0] mul_power;
//---------------------------------------------------------------------
//   Your design                       
//---------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 0;
        out <= 0;
    end
    else begin
        out_valid <= out_valid_nxt;
        out <= out_nxt;
    end
end
always_comb begin
    if(in_valid == 1) out_valid_nxt = 1;
    else out_valid_nxt = 0;
end
always_comb begin
    ////////////////////////////////initial
    power_a = in_a[14:7] - 127;
    power_b = in_b[14:7] - 127;
    fraction_a = {1'd0,1'd1,in_a[6:0]};
    fraction_b = {1'd0,1'd1,in_b[6:0]};
    if(!in_valid) begin
        out_nxt = 0;
    end
    else begin
        ///////////////////////////////////////////////plus
        if(!mode) begin
            if(power_a > power_b) begin/////shift
                max_power = power_a;
                shift_a = fraction_a;
                shift_b = (fraction_b >>> power_a - power_b) + fraction_b[0] ;
            end
            else if(power_b > power_a)begin
                max_power = power_b;
                shift_a = (fraction_a >>> power_b - power_a) + fraction_a[0] ;
                shift_b = fraction_b;
            end
            else begin
                max_power = power_a;
                shift_a = fraction_a;
                shift_b = fraction_b;
            end
            if(in_a[15] == 1) begin ////////// 2 complement
                adder_a = 512 - shift_a;
            end
            else begin
                adder_a = shift_a;
            end
            if(in_b[15] == 1) begin
                adder_b = 512 - shift_b;
            end
            else begin
                adder_b = shift_b;
            end
            //////////////////////////////// out sign
            if((in_a[15] == 1 && in_b[15] == 0 && shift_a > shift_b) || (in_a[15] == 0 && in_b[15] == 1 && shift_a < shift_b) || (in_a[15] == 1 && in_b[15] == 1)) out_nxt[15] = 1;
            else out_nxt[15] = 0;

            sum = {1'd0,adder_a} + {1'd0,adder_b};
            sum[9] = out_nxt[15];
            if(sum[9] == 1) begin  sum_complement = 512 - sum[8:0]; end
            else            begin sum_complement = sum[8:0]; end

            //if(sum_complement[8] == 1)      begin out_nxt[14:7] = max_power + 127 + 1; out_nxt[6:0] = sum_complement[7:1] + sum_complement[0]; end 
            if(sum_complement[8] == 1)      begin out_nxt[14:7] = max_power + 127 + 1; out_nxt[6:0] = sum_complement[7:1] ; end 
            else if(sum_complement[7] == 1) begin out_nxt[14:7] = max_power + 127;     out_nxt[6:0] = sum_complement[6:0]; end
            else if(sum_complement[6] == 1) begin out_nxt[14:7] = max_power + 127 - 1; out_nxt[6:0] = {sum_complement[5:0],1'd0}; end
            else if(sum_complement[5] == 1) begin out_nxt[14:7] = max_power + 127 - 2; out_nxt[6:0] = {sum_complement[4:0],2'd0}; end
            else if(sum_complement[4] == 1) begin out_nxt[14:7] = max_power + 127 - 3; out_nxt[6:0] = {sum_complement[3:0],3'd0}; end
            else if(sum_complement[3] == 1) begin out_nxt[14:7] = max_power + 127 - 4; out_nxt[6:0] = {sum_complement[2:0],4'd0}; end
            else if(sum_complement[2] == 1) begin out_nxt[14:7] = max_power + 127 - 5; out_nxt[6:0] = {sum_complement[1:0],5'd0}; end
            else if(sum_complement[1] == 1) begin out_nxt[14:7] = max_power + 127 - 6; out_nxt[6:0] = {sum_complement[0],6'd0}; end
            else if(sum_complement[0] == 1) begin out_nxt[14:7] = max_power + 127 - 7; out_nxt[6:0] = 0; end
            else begin out_nxt[14:7] = max_power + 127; out_nxt[6:0] = sum_complement[8:1] + sum_complement[0]; end
        end

        ///////////////////////////////////////////////// multiple
        else if(mode == 1) begin
            out_nxt[15] = in_a[15] + in_b[15];
            mul = fraction_a * fraction_b;
            mul_power = in_a[14:7] -127 + in_b[14:7] - 127 ;
            if(mul[15] == 1) begin out_nxt[14:7] = in_a[14:7] -127 + in_b[14:7] - 127 + 128;   out_nxt[6:0] = mul[14:8] + mul[7]; end
            else if(mul[14] == 1)  begin
                out_nxt[6:0] = mul[13:7] + mul[6];
                if(mul[13:7] == 127 && mul[6] == 1) out_nxt[14:7] = in_a[14:7] -127  + in_b[14:7] - 127 + 128;  
                else out_nxt[14:7] = in_a[14:7] -127  + in_b[14:7] - 127 + 127;
            end
            else begin out_nxt = 0; end
        end

        else begin
            out_nxt = 0;
        end
    end
end
endmodule