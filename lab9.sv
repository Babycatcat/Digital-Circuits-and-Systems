module P_MUL(
    // input signals
	in_1,
	in_2,
	in_3,
	in_4,
	in_valid,
	rst_n,
	clk,
	
    // output signals
    out_valid,
	out
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [46:0] in_1, in_2;
input [46:0] in_3, in_4;
input in_valid, rst_n, clk;
output logic out_valid;
output logic [95:0] out;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [46:0] in_1_reg, in_2_reg;
logic [46:0] in_3_reg,in_4_reg;
logic in_valid_reg;
logic [47:0] adder_out_cmb1,adder_out_cmb2, A_reg, B_reg;
logic [23:0] m_0_0, m_0_12, m_0_24, m_0_36, m_12_0, m_12_12, m_12_24, m_12_36;
logic [23:0] m_24_0, m_24_12, m_24_24, m_24_36, m_36_0, m_36_12, m_36_24, m_36_36;

logic [23:0] m_0_0_reg, m_0_12_reg, m_0_24_reg, m_0_36_reg, m_12_0_reg, m_12_12_reg, m_12_24_reg, m_12_36_reg;
logic [23:0] m_24_0_reg, m_24_12_reg, m_24_24_reg, m_24_36_reg, m_36_0_reg, m_36_12_reg, m_36_24_reg, m_36_36_reg;

logic [95:0] s_0, s_1, s_2, s_3, s_4, s_5, s_6, s_7, s_8, s_9, s_10, s_11, s_12, s_13, s_14, s_15;
logic [95:0] add_0, add_0_reg, add_1, add_1_reg, add_2, add_2_reg, add_3, add_3_reg;
logic [95:0] final_add_cmb;
logic in_valid_pass1, in_valid_pass2, in_valid_pass3;
//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        in_valid_reg <= 0;
        in_1_reg <= 0;
        in_2_reg <= 0;
        in_3_reg <= 0;
		in_4_reg <= 0;
    end else begin
        in_valid_reg <= in_valid;
        in_1_reg <= in_1;
        in_2_reg <= in_2;
        in_3_reg <= in_3;
		in_4_reg <= in_4;
    end
end 

assign adder_out_cmb1 = in_1_reg + in_2_reg;
assign adder_out_cmb2 = in_3_reg + in_4_reg;

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        A_reg <= 0;
        B_reg <= 0;
		in_valid_pass1 <= 0;
    end else begin
        A_reg <= adder_out_cmb1;
        B_reg <= adder_out_cmb2;
		in_valid_pass1 <= in_valid_reg;
    end
end

always_comb begin
    m_0_0 = A_reg[11:0] * B_reg[11:0];
    m_0_12 = A_reg[11:0] * B_reg[23:12];
    m_0_24 = A_reg[11:0] * B_reg[35:24];
    m_0_36 = A_reg[11:0] * B_reg[47:36];

    m_12_0 = A_reg[23:12] * B_reg[11:0];
    m_12_12 = A_reg[23:12] * B_reg[23:12];
    m_12_24 = A_reg[23:12] * B_reg[35:24];
    m_12_36 = A_reg[23:12] * B_reg[47:36];

    m_24_0 = A_reg[35:24] * B_reg[11:0];
    m_24_12 = A_reg[35:24] * B_reg[23:12];
    m_24_24 = A_reg[35:24] * B_reg[35:24];
    m_24_36 = A_reg[35:24] * B_reg[47:36];

    m_36_0 = A_reg[47:36] * B_reg[11:0];
    m_36_12 = A_reg[47:36] * B_reg[23:12];
    m_36_24 = A_reg[47:36] * B_reg[35:24];
    m_36_36 = A_reg[47:36] * B_reg[47:36];
end

always @(posedge clk) begin
    m_0_0_reg <= m_0_0;
    m_0_12_reg <= m_0_12;
    m_0_24_reg <= m_0_24;
    m_0_36_reg <= m_0_36;

    m_12_0_reg <= m_12_0;
    m_12_12_reg <= m_12_12;
    m_12_24_reg <= m_12_24;
    m_12_36_reg <= m_12_36;

    m_24_0_reg <= m_24_0;
    m_24_12_reg <= m_24_12;
    m_24_24_reg <= m_24_24;
    m_24_36_reg <= m_24_36;

    m_36_0_reg <= m_36_0;
    m_36_12_reg <= m_36_12;
    m_36_24_reg <= m_36_24;
    m_36_36_reg <= m_36_36;
	
	in_valid_pass2 <= in_valid_pass1;
end    

always_comb begin
    s_0 = m_0_0_reg;
    s_1 = m_0_12_reg << 12;
    s_2 = m_0_24_reg << 24;
    s_3 = m_0_36_reg << 36;

    s_4 = m_12_0_reg << 12;
    s_5 = m_12_12_reg << 24;
    s_6 = m_12_24_reg << 36;
    s_7 = m_12_36_reg << 48;

    s_8 = m_24_0_reg << 24;
    s_9 = m_24_12_reg << 36;
    s_10 = m_24_24_reg << 48;
    s_11 = m_24_36_reg << 60;

    s_12 = m_36_0_reg << 36;
    s_13 = m_36_12_reg << 48;
    s_14 = m_36_24_reg << 60;
    s_15 = m_36_36_reg << 72;
end

always_comb begin
    final_add_cmb = s_0 + s_1 + s_2 + s_3 + s_4 + s_5 + s_6 + s_7 + s_8 + s_9 + s_10 + s_11 + s_12 + s_13 + s_14 + s_15;
end

always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		out_valid <= 0;
		out <= 0;
	end else begin
		out_valid <= in_valid_pass2;
		out <= final_add_cmb;
	end
end

endmodule