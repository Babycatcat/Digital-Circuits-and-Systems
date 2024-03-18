//all pass
//area = 110695
//total latency = 13080
//version 3
module MIPS(
    //Input 
    clk,
    rst_n,
    in_valid,
    instruction,
	output_reg,
    //OUTPUT
    out_valid,
    out_1,
	out_2,
	out_3,
	out_4,
	instruction_fail
);

//Input 
input clk;
input rst_n;
input in_valid;
input [31:0] instruction;
input [19:0] output_reg;
//OUTPUT
output logic out_valid, instruction_fail;
output logic [15:0] out_1, out_2, out_3, out_4;
logic in_valid_reg;
logic fail_opcode, fail_rs, fail_rt, fail_rd, fail_func, op_0,fail_gcd;
logic instruction_fail_nxt,instruction_fail_delay;
logic op_0_delay;
logic [2:0] rs_address,rs_address_nxt,rt_address,rt_address_nxt,rd_address,rd_address_nxt,func,func_nxt,write_address,write_address_nxt;
logic [15:0] rs_reg,rt_reg,ans_reg,rs_nxt,rt_nxt,ans_nxt;
logic [15:0] imm,imm_nxt;
logic [3:0] shamt,shamt_nxt;
logic [19:0] output_address_reg,output_address_nxt;
logic [15:0]out_1_nxt,out_2_nxt,out_3_nxt,out_4_nxt,out_valid_nxt;
logic [15:0] Mem[0:5],Mem_nxt[0:5];
logic [15:0] GCD_A,GCD_B,GCD_A_nxt,GCD_B_nxt;
//logic [15:0] GCD_C,GCD_D,GCD_C_nxt,GCD_D_nxt;
logic [2:0] GCD_ans_address,GCD_ans_address_nxt;
//logic [15:0] GCD_ans,GCD_ans_nxt;
//logic GCD_done,GCD_done_nxt;
logic GCD_done;
logic [1:0] state,state_nxt;
parameter INPUT = 0;
parameter CALCULATE = 1;
parameter GCD = 2;
parameter OUTPUT = 3;
/////////////////////////////////////////////////////////////////////////////////// instruction fail
assign op_0 = (in_valid && instruction[31:26] == 6'b000000) ? 1 : 0;
assign fail_opcode = in_valid && !op_0 && instruction[31:26] != 6'b001000;
assign fail_rs = in_valid &&
                 instruction[25:21] != 5'b10001 &&
                 instruction[25:21] != 5'b10010 &&
                 instruction[25:21] != 5'b01000 &&
                 instruction[25:21] != 5'b10111 &&
                 instruction[25:21] != 5'b11111 &&
                 instruction[25:21] != 5'b10000;
assign fail_rt = in_valid &&
                 instruction[20:16] != 5'b10001 && 
                 instruction[20:16] != 5'b10010 &&
                 instruction[20:16] != 5'b01000 &&
                 instruction[20:16] != 5'b10111 &&
                 instruction[20:16] != 5'b11111 &&
                 instruction[20:16] != 5'b10000;
assign fail_rd = in_valid && op_0 && (instruction[15:11] != 5'b10001 &&
                                                        instruction[15:11] != 5'b10010 &&
                                                        instruction[15:11] != 5'b01000 &&
                                                        instruction[15:11] != 5'b10111 &&
                                                        instruction[15:11] != 5'b11111 &&
                                                        instruction[15:11] != 5'b10000);
assign fail_func = in_valid && op_0 && (instruction[6:0] != 7'b0100000 &&
                                                           instruction[6:0] != 7'b0100100 &&
                                                           instruction[6:0] != 7'b0100101 &&
                                                           instruction[6:0] != 7'b0100111 &&
                                                           instruction[6:0] != 7'b0000000 &&
                                                           instruction[6:0] != 7'b0000010 &&
                                                           instruction[6:0] != 7'b1111000);
assign fail_gcd = in_valid && op_0 && instruction[6:0] == 7'b1111000 && (!rs_nxt || !rt_nxt);
assign instruction_fail_nxt = fail_opcode || fail_rs || fail_rt || fail_rd || fail_func || fail_gcd;
//////////////////////////////////////////////////////////////////////////////////////////////////////FSM
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) state <= INPUT;
    else state <= state_nxt;
end
always_comb begin
    case(state)
        INPUT: begin
            if(func_nxt == 7 && in_valid && !instruction_fail_nxt && op_0 ) state_nxt = GCD;
            else if(in_valid) state_nxt = CALCULATE;
            else state_nxt = INPUT;
        end
        CALCULATE: state_nxt = OUTPUT;
        GCD: begin
            if(GCD_done) state_nxt = OUTPUT;
            else state_nxt = GCD;
        end
        OUTPUT: state_nxt = INPUT;
        default: state_nxt = INPUT;
    endcase
end
///////////////////////////////////////////////////////// Mem
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(int i = 0;i < 6;i++) begin
            Mem[i] <= 0;
        end
    end
    else begin
        for(int i = 0;i < 6;i++) begin
            Mem[i] <= Mem_nxt[i];
        end
    end
end
/////////////////////////////////////////////////////////////input
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        in_valid_reg <= 0;
        imm <= 0;
        shamt <= 0;
        output_address_reg <= 0;
        rs_reg <= 0;
        rt_reg <= 0;
        ans_reg <= 0;
        rs_address <= 6;
        rt_address <= 6;
        rd_address <= 6;
        write_address <= 6;
        op_0_delay <= 0;
        func <= 0;
    end
    else begin
        in_valid_reg <= in_valid;
        imm <= imm_nxt;
        shamt <= shamt_nxt;
        output_address_reg <= output_address_nxt;
        rs_reg <= rs_nxt;
        rt_reg <= rt_nxt;
        ans_reg <= ans_nxt;
        rs_address <= rs_address_nxt;
        rt_address <= rt_address_nxt;
        rd_address <= rd_address_nxt;
        write_address <= write_address_nxt;
        op_0_delay <= op_0;
        func <= func_nxt;
    end
end
always_comb begin
    if(in_valid) begin
        //instruction_nxt = instruction;
        imm_nxt = instruction[15:0];
        shamt_nxt = instruction[11:7];
        output_address_nxt = output_reg;

    end
    else  begin
        //instruction_nxt = instruction_reg;
        imm_nxt = imm;
        shamt_nxt = shamt;
        output_address_nxt = output_address_reg;
    end
end
always_comb begin
    if(in_valid) begin
        case(instruction[25:21])
        5'b10001: begin rs_address_nxt = 0;rs_nxt = Mem[0]; end
        5'b10010: begin rs_address_nxt = 1;rs_nxt = Mem[1]; end
        5'b01000: begin rs_address_nxt = 2;rs_nxt = Mem[2]; end
        5'b10111: begin rs_address_nxt = 3;rs_nxt = Mem[3]; end
        5'b11111: begin rs_address_nxt = 4;rs_nxt = Mem[4]; end
        5'b10000: begin rs_address_nxt = 5;rs_nxt = Mem[5]; end
        default:  begin rs_address_nxt = 6;rs_nxt = 0; end
        endcase
        case(instruction[20:16])
        5'b10001: begin rt_address_nxt = 0; rt_nxt = Mem[0];end
        5'b10010: begin rt_address_nxt = 1; rt_nxt = Mem[1];end
        5'b01000: begin rt_address_nxt = 2; rt_nxt = Mem[2];end
        5'b10111: begin rt_address_nxt = 3; rt_nxt = Mem[3];end
        5'b11111: begin rt_address_nxt = 4; rt_nxt = Mem[4];end
        5'b10000: begin rt_address_nxt = 5; rt_nxt = Mem[5];end
        default:  begin rt_address_nxt = 6; rt_nxt = 0;end
        endcase
        case(instruction[15:11])
        5'b10001: begin rd_address_nxt = 0;end
        5'b10010: begin rd_address_nxt = 1;end
        5'b01000: begin rd_address_nxt = 2;end
        5'b10111: begin rd_address_nxt = 3;end
        5'b11111: begin rd_address_nxt = 4;end
        5'b10000: begin rd_address_nxt = 5;end
        default:  begin rd_address_nxt = 6;end//
        endcase
        case(instruction[6:0])
        7'b0100000:begin func_nxt = 1;end
        7'b0100100:begin func_nxt = 2;end
        7'b0100101:begin func_nxt = 3;end
        7'b0100111:begin func_nxt = 4;end
        7'b0000000:begin func_nxt = 5;end
        7'b0000010:begin func_nxt = 6;end
        7'b1111000:begin func_nxt = 7;end
        default:   begin func_nxt = 0;end
        endcase
    end
    else begin
        rs_nxt = 0;rt_nxt = 0;
        rs_address_nxt = 6;rt_address_nxt = 6;rd_address_nxt = 6;func_nxt = 0;
    end
end
always_comb begin
    if(op_0) write_address_nxt = rd_address_nxt;
    else write_address_nxt = rt_address_nxt;
end
//////////////////////////////////////////////////// calculate
always_comb begin
    if(state == CALCULATE && op_0_delay && !instruction_fail_delay) begin
        case(func)
            1: ans_nxt = rs_reg + rt_reg;
            2: ans_nxt = rs_reg & rt_reg; 
            3: ans_nxt = rs_reg | rt_reg; 
            4: ans_nxt = ~(rs_reg | rt_reg); 
            5: ans_nxt = rt_reg << shamt;
            default: ans_nxt = rt_reg >> shamt;
        endcase
    end
    else if(state == CALCULATE && !instruction_fail_delay) begin
        ans_nxt = rs_reg + imm_nxt;
    end
    else begin
        ans_nxt = 0;
    end
end
///////////////////////////////////////////////////////GCD
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        GCD_A <= 0;
        GCD_B <= 0;
        GCD_ans_address <= 0;
        //GCD_ans<= 0;
        //GCD_done <= 0;
    end
    else begin
        GCD_A <= GCD_A_nxt;
        GCD_B <= GCD_B_nxt;
        GCD_ans_address <= GCD_ans_address_nxt;
        //GCD_ans <= GCD_ans_nxt;
        //GCD_done <= GCD_done_nxt;
    end
end
always_comb begin
    if(state == GCD && !instruction_fail_delay && in_valid_reg) begin
        //GCD_done_nxt = 0;
        GCD_done = 0;
        if(rs_reg >= rt_reg) begin GCD_A_nxt = rs_reg; GCD_B_nxt = rt_reg; end
        else begin GCD_A_nxt = rt_reg; GCD_B_nxt = rs_reg; end
        GCD_ans_address_nxt = rd_address;
        //GCD_ans_nxt = 0;          
    end        
    //else if(!GCD_B && !GCD_done) begin //////////////
    else if(!GCD_B) begin //////////////
        //GCD_done_nxt = 1;
        GCD_done = 0;
        GCD_A_nxt = 0;
        GCD_B_nxt = 0;
        GCD_ans_address_nxt = 0;
        //GCD_ans_nxt = GCD_A;
    end
    else begin
        //GCD_done_nxt = 0;
        GCD_A_nxt = GCD_B;
        GCD_B_nxt = GCD_A % GCD_B;
        GCD_ans_address_nxt = GCD_ans_address;
        //GCD_ans_nxt = 0;
        if(!GCD_B_nxt) GCD_done = 1;
        else GCD_done = 0;
    end
end
///////////////////////////////////////////////////////// store
always_comb begin
    if(state == CALCULATE && !instruction_fail_delay && write_address == 0) Mem_nxt[0] = ans_nxt;
    //else if(!instruction_fail_delay && GCD_done && state == GCD && GCD_ans_address == 0) Mem_nxt[0] = GCD_B;
    else if(GCD_done && state == GCD && GCD_ans_address == 0) Mem_nxt[0] = GCD_B;
    else Mem_nxt[0] = Mem[0];
    if(state == CALCULATE && !instruction_fail_delay && write_address == 1) Mem_nxt[1] = ans_nxt;
    //else if(!instruction_fail_delay && GCD_done && state == GCD && GCD_ans_address == 1) Mem_nxt[1] = GCD_B;
    else if(GCD_done && state == GCD && GCD_ans_address == 1) Mem_nxt[1] = GCD_B;
    else Mem_nxt[1] = Mem[1];
    if(state == CALCULATE && !instruction_fail_delay && write_address == 2) Mem_nxt[2] = ans_nxt;
    //else if(!instruction_fail_delay && GCD_done && state == GCD && GCD_ans_address == 2) Mem_nxt[2] = GCD_B;
    else if(GCD_done && state == GCD && GCD_ans_address == 2) Mem_nxt[2] = GCD_B;
    else Mem_nxt[2] = Mem[2];
    if(state == CALCULATE && !instruction_fail_delay && write_address == 3) Mem_nxt[3] = ans_nxt;
    //else if(!instruction_fail_delay && GCD_done && state == GCD && GCD_ans_address == 3) Mem_nxt[3] = GCD_B;
    else if(GCD_done && state == GCD && GCD_ans_address == 3) Mem_nxt[3] = GCD_B;
    else Mem_nxt[3] = Mem[3];
    if(state == CALCULATE && !instruction_fail_delay && write_address == 4) Mem_nxt[4] = ans_nxt;
    //else if(!instruction_fail_delay && GCD_done && state == GCD && GCD_ans_address == 4) Mem_nxt[4] = GCD_B;
    else if(GCD_done && state == GCD && GCD_ans_address == 4) Mem_nxt[4] = GCD_B;
    else Mem_nxt[4] = Mem[4];
    if(state == CALCULATE && !instruction_fail_delay && write_address == 5) Mem_nxt[5] = ans_nxt;
    //else if(!instruction_fail_delay && GCD_done && state == GCD && GCD_ans_address == 5) Mem_nxt[5] = GCD_B;
    else if(GCD_done && state == GCD && GCD_ans_address == 5) Mem_nxt[5] = GCD_B;
    else Mem_nxt[5] = Mem[5];

end
/////////////////////////////////////////////////////// output
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 0;
        out_1 <= 0;
        out_2 <= 0;
        out_3 <= 0;
        out_4 <= 0;
        instruction_fail <= 0;
        instruction_fail_delay <= 0;
    end
    else begin
        out_valid <= out_valid_nxt;
        out_1 <= out_1_nxt;
        out_2 <= out_2_nxt;
        out_3 <= out_3_nxt;
        out_4 <= out_4_nxt;
        instruction_fail <= instruction_fail_delay;
        instruction_fail_delay <= instruction_fail_nxt;
    end
end
always_comb begin
    if(state_nxt == OUTPUT && !instruction_fail_delay) begin
        case(output_address_reg[4:0])
        5'b10001: out_1_nxt = Mem_nxt[0];
        5'b10010: out_1_nxt = Mem_nxt[1];
        5'b01000: out_1_nxt = Mem_nxt[2];
        5'b10111: out_1_nxt = Mem_nxt[3];
        5'b11111: out_1_nxt = Mem_nxt[4];
        5'b10000: out_1_nxt = Mem_nxt[5];
        default:  out_1_nxt = 0;
        endcase
        case(output_address_reg[9:5])
        5'b10001: out_2_nxt = Mem_nxt[0];
        5'b10010: out_2_nxt = Mem_nxt[1];
        5'b01000: out_2_nxt = Mem_nxt[2];
        5'b10111: out_2_nxt = Mem_nxt[3];
        5'b11111: out_2_nxt = Mem_nxt[4];
        5'b10000: out_2_nxt = Mem_nxt[5];
        default:  out_2_nxt = 0;
        endcase
        case(output_address_reg[14:10])
        5'b10001: out_3_nxt = Mem_nxt[0];
        5'b10010: out_3_nxt = Mem_nxt[1];
        5'b01000: out_3_nxt = Mem_nxt[2];
        5'b10111: out_3_nxt = Mem_nxt[3];
        5'b11111: out_3_nxt = Mem_nxt[4];
        5'b10000: out_3_nxt = Mem_nxt[5];
        default:  out_3_nxt = 0;
        endcase
        case(output_address_reg[19:15])
        5'b10001: out_4_nxt = Mem_nxt[0];
        5'b10010: out_4_nxt = Mem_nxt[1];
        5'b01000: out_4_nxt = Mem_nxt[2];
        5'b10111: out_4_nxt = Mem_nxt[3];
        5'b11111: out_4_nxt = Mem_nxt[4];
        5'b10000: out_4_nxt = Mem_nxt[5];
        default:  out_4_nxt = 0;
        endcase
    end
    else begin
        out_1_nxt = 0;
        out_2_nxt = 0;
        out_3_nxt = 0;
        out_4_nxt = 0;
    end
    if(state_nxt == OUTPUT) out_valid_nxt = 1;
    else out_valid_nxt = 0;
end
endmodule


