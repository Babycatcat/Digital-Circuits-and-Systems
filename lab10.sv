`include "synchronizer.v"

module CDC(// Input signals
			clk_1,
			clk_2,
			in_valid,
			rst_n,
			in_a,
			mode,
			in_b,
		  //  Output signals
			out_valid,
			out
			);		
input clk_1; 
input clk_2;			
input rst_n;
input in_valid;
input[3:0]in_a,in_b;
input mode;
output logic out_valid;
output logic [7:0]out; 			
//---------------------------------------------------------------------
//   your design  (Using synchronizer)       
// Example :
//logic P,Q,Y;
//synchronizer x5(.D(P),.Q(Y),.clk(clk_2),.rst_n(rst_n));           
//---------------------------------------------------------------------		
logic in_valid_reg; // CDC.sv D output
logic Q,Q_reg;
logic out_valid_nxt;
logic [7:0] out_nxt;
logic CDC_res;
logic [3:0] in_a_nxt,in_a_reg;
logic [3:0] in_b_nxt,in_b_reg;
logic mode_nxt,mode_reg;
synchronizer x5(.D(in_valid_reg),.Q(Q),.clk(clk_2),.rst_n(rst_n));           

logic [1:0] state,state_nxt;
parameter IDLE = 0;
parameter COMPUTE = 1;
parameter OUT = 2;
always_ff @(posedge clk_2 or negedge rst_n) begin
    if(!rst_n) begin
        state <= IDLE;
        out_valid <= 0;
        out <= 0;
    end
    else begin
        state <= state_nxt;
        out_valid <= out_valid_nxt;
        out <= out_nxt;
    end
end
always_comb begin
    case(state)
        IDLE: begin
            if(CDC_res) state_nxt = COMPUTE;
            else state_nxt = IDLE;
        end
        COMPUTE:
            state_nxt = OUT;
        OUT:
            state_nxt = IDLE;
        default: state_nxt = IDLE;
    endcase
end
always_ff @(posedge clk_1 or negedge rst_n) begin
    if(!rst_n) begin
        in_valid_reg <= 0;
        mode_reg <= 0;
        in_a_reg <= 0;
        in_b_reg <= 0;
    end
    else begin
        in_valid_reg <= in_valid;
        mode_reg <= mode_nxt;
        in_a_reg <= in_a_nxt;
        in_b_reg <= in_b_nxt;
    end
end
always_comb begin
    if(in_valid) begin
        mode_nxt = mode;
        in_a_nxt = in_a;
        in_b_nxt = in_b;
    end
    else begin
        mode_nxt = mode_reg;
        in_a_nxt = in_a_reg;
        in_b_nxt = in_b_reg;
    end
end
always_ff @(posedge clk_2) begin
    Q_reg <= Q;
end
always_comb begin
    if(Q_reg ^ Q) CDC_res = 1;
    else CDC_res = 0;
    if(state_nxt == OUT) out_valid_nxt = 1;
    else out_valid_nxt = 0;
    if(state_nxt == COMPUTE && mode_reg ) out_nxt = in_a_reg * in_b_reg;
    else if(state_nxt == COMPUTE && !mode_reg) out_nxt = in_a_reg + in_b_reg;
	else if(out_valid_nxt) out_nxt = out; 
    else out_nxt = 0;
end
		
endmodule