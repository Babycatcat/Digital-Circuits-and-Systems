/// 01 02 03 pass demo2 catcat
module DCT(
	// Input signals
	clk,
	rst_n,
	in_valid,
	in_data,
	// Output signals
	out_valid,
	out_data
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input        clk, rst_n, in_valid;
input signed [7:0]in_data;
output logic out_valid;
output logic signed[9:0]out_data;

//---------------------------------------------------------------------
//   REG AND WIRE DECLARATION                         
//---------------------------------------------------------------------
parameter IDLE = 0;
parameter INPUT = 1;
parameter MUL1 = 2;
parameter OUTPUT = 3;
logic signed [7:0]D[0:3][0:3];

logic [2:0]STATE,NS;
logic [3:0]count;
logic signed [7:0]inbuffer[0:3][0:3];
logic [3:0]output_cnt;
logic signed [9:0] out_data_nxt;
logic out_valid_nxt;
logic signed [7:0] DT[0:3][0:3];
logic signed [15:0] temp_buffer[0:3][0:3];
logic signed [15:0] temp_buffer_nxt[0:3][0:3];

//---------------------------------------------------------------------
//   YOUR DESIGN                         
//---------------------------------------------------------------------
assign D[0][0] = 8'b01000000;
assign D[0][1] = 8'b01000000;
assign D[0][2] = 8'b01000000;
assign D[0][3] = 8'b01000000;
assign D[1][0] = 8'b01010011;
assign D[1][1] = 8'b00100010;
assign D[1][2] = 8'b11011110;
assign D[1][3] = 8'b10101101;
assign D[2][0] = 8'b01000000;
assign D[2][1] = 8'b11000000;
assign D[2][2] = 8'b11000000;
assign D[2][3] = 8'b01000000;
assign D[3][0] = 8'b00100010;
assign D[3][1] = 8'b10101101;
assign D[3][2] = 8'b01010011;
assign D[3][3] = 8'b11011110;

assign DT[0][0] = D[0][0];
assign DT[0][1] = D[1][0];
assign DT[0][2] = D[2][0];
assign DT[0][3] = D[3][0];
assign DT[1][0] = D[0][1];
assign DT[1][1] = D[1][1];
assign DT[1][2] = D[2][1];
assign DT[1][3] = D[3][1];
assign DT[2][0] = D[0][2];
assign DT[2][1] = D[1][2];
assign DT[2][2] = D[2][2];
assign DT[2][3] = D[3][2];
assign DT[3][0] = D[0][3];
assign DT[3][1] = D[1][3];
assign DT[3][2] = D[2][3];
assign DT[3][3] = D[3][3];

always_ff@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		STATE<=0;
		out_valid<=0;
	end
	else begin
		STATE<=NS;
		out_valid<= out_valid_nxt;
	end
end

always_comb begin
	case(STATE)
		IDLE:begin
			if(in_valid)	NS = INPUT;
			else 			NS = STATE;
		end
		INPUT:begin
			if(~in_valid)	NS = MUL1;
			else 			NS = STATE;
		end
		MUL1:begin
			if(count == 15) NS = OUTPUT;
			else NS = STATE;
		end
		OUTPUT:begin
			if(output_cnt==15)NS = IDLE;
			else 			NS = STATE;
		end
		default:begin
			NS = STATE;
		end
	endcase
end
always_comb begin
	if(STATE == OUTPUT) out_valid_nxt = 1;
	else out_valid_nxt = 0;
end
always_ff@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		count<=0;
	end
	else begin
		if(in_valid || STATE == MUL1 && count < 15)begin
			count<=count+1;
		end
		else begin
			count<=0;
		end
	end
end

always_ff@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		for(int i=0;i<4;i=i+1)begin
			for(int j=0;j<4;j=j+1)begin
				inbuffer[i][j]<=0;
			end
		end
	end
	else begin
		if(in_valid)begin
			inbuffer[count[3:2]][count[1:0]]<=in_data;
		end
	end
end

always_ff@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		output_cnt<=0;
	end
	else begin
		if(STATE==OUTPUT)begin
			output_cnt<=output_cnt+1;
		end
		else begin
			output_cnt<=0;
		end
	end
end
/////////////////////////////////////// first stage calculate
always_ff @(posedge clk or negedge rst_n ) begin
	if(!rst_n) begin
		for(int i = 0;i < 4;i++) begin
			for(int j = 0;j < 4;j++) begin
				temp_buffer[i][j] <= 0;
			end
		end
	end
    else begin
	temp_buffer[0][0] <= temp_buffer_nxt[0][0];
    temp_buffer[0][1] <= temp_buffer_nxt[0][1];
    temp_buffer[0][2] <= temp_buffer_nxt[0][2];
    temp_buffer[0][3] <= temp_buffer_nxt[0][3];

    temp_buffer[1][0] <= temp_buffer_nxt[1][0];
    temp_buffer[1][1] <= temp_buffer_nxt[1][1];
    temp_buffer[1][2] <= temp_buffer_nxt[1][2];
    temp_buffer[1][3] <= temp_buffer_nxt[1][3];

    temp_buffer[2][0] <= temp_buffer_nxt[2][0];
    temp_buffer[2][1] <= temp_buffer_nxt[2][1];
    temp_buffer[2][2] <= temp_buffer_nxt[2][2];
    temp_buffer[2][3] <= temp_buffer_nxt[2][3];

    temp_buffer[3][0] <= temp_buffer_nxt[3][0];
    temp_buffer[3][1] <= temp_buffer_nxt[3][1];
    temp_buffer[3][2] <= temp_buffer_nxt[3][2];
    temp_buffer[3][3] <= temp_buffer_nxt[3][3];
	end
end
always_comb begin
    if(STATE == MUL1 && count == 0) 			begin temp_buffer_nxt[0][0] = (D[0][0] * inbuffer[0][0] + D[0][1] * inbuffer[1][0] + D[0][2]*inbuffer[2][0] + D[0][3] * inbuffer[3][0]) / 128; end
    else                          				begin temp_buffer_nxt[0][0] = temp_buffer[0][0]; end
    if(STATE == MUL1 && count == 1)             begin temp_buffer_nxt[0][1] = (D[0][0] * inbuffer[0][1] + D[0][1] * inbuffer[1][1] + D[0][2]*inbuffer[2][1] + D[0][3] * inbuffer[3][1]) / 128; end
    else                          				begin temp_buffer_nxt[0][1] = temp_buffer[0][1]; end
    if(STATE == MUL1 && count == 2)             begin temp_buffer_nxt[0][2] = (D[0][0] * inbuffer[0][2] + D[0][1] * inbuffer[1][2] + D[0][2]*inbuffer[2][2] + D[0][3] * inbuffer[3][2]) / 128; end
    else                          				begin temp_buffer_nxt[0][2] = temp_buffer[0][2]; end
    if(STATE == MUL1 && count == 3)             begin temp_buffer_nxt[0][3] = (D[0][0] * inbuffer[0][3] + D[0][1] * inbuffer[1][3] + D[0][2]*inbuffer[2][3] + D[0][3] * inbuffer[3][3]) / 128; end
    else                          				begin temp_buffer_nxt[0][3] = temp_buffer[0][3]; end
       
	if(STATE == MUL1 && count == 4)             begin temp_buffer_nxt[1][0] = (D[1][0] * inbuffer[0][0] + D[1][1] * inbuffer[1][0] + D[1][2]*inbuffer[2][0] + D[1][3] * inbuffer[3][0]) / 128; end
    else                          				begin temp_buffer_nxt[1][0] = temp_buffer[1][0]; end
    if(STATE == MUL1 && count == 5)             begin temp_buffer_nxt[1][1] = (D[1][0] * inbuffer[0][1] + D[1][1] * inbuffer[1][1] + D[1][2]*inbuffer[2][1] + D[1][3] * inbuffer[3][1]) / 128; end
    else                          				begin temp_buffer_nxt[1][1] = temp_buffer[1][1]; end
    if(STATE == MUL1 && count == 6)             begin temp_buffer_nxt[1][2] = (D[1][0] * inbuffer[0][2] + D[1][1] * inbuffer[1][2] + D[1][2]*inbuffer[2][2] + D[1][3] * inbuffer[3][2]) / 128; end
    else                          				begin temp_buffer_nxt[1][2] = temp_buffer[1][2]; end
    if(STATE == MUL1 && count == 7)             begin temp_buffer_nxt[1][3] = (D[1][0] * inbuffer[0][3] + D[1][1] * inbuffer[1][3] + D[1][2]*inbuffer[2][3] + D[1][3] * inbuffer[3][3]) / 128; end
    else                          				begin temp_buffer_nxt[1][3] = temp_buffer[1][3]; end
       
	if(STATE == MUL1 && count == 8)             begin temp_buffer_nxt[2][0] = (D[2][0] * inbuffer[0][0] + D[2][1] * inbuffer[1][0] + D[2][2]*inbuffer[2][0] + D[2][3] * inbuffer[3][0]) / 128; end
    else                          				begin temp_buffer_nxt[2][0] = temp_buffer[2][0]; end
    if(STATE == MUL1 && count == 9)             begin temp_buffer_nxt[2][1] = (D[2][0] * inbuffer[0][1] + D[2][1] * inbuffer[1][1] + D[2][2]*inbuffer[2][1] + D[2][3] * inbuffer[3][1]) / 128;end
    else                          				begin temp_buffer_nxt[2][1] = temp_buffer[2][1]; end
    if(STATE == MUL1 && count == 10)            begin temp_buffer_nxt[2][2] = (D[2][0] * inbuffer[0][2] + D[2][1] * inbuffer[1][2] + D[2][2]*inbuffer[2][2] + D[2][3] * inbuffer[3][2]) / 128; end
    else                          				begin temp_buffer_nxt[2][2] = temp_buffer[2][2]; end
    if(STATE == MUL1 && count == 11)            begin temp_buffer_nxt[2][3] = (D[2][0] * inbuffer[0][3] + D[2][1] * inbuffer[1][3] + D[2][2]*inbuffer[2][3] + D[2][3] * inbuffer[3][3]) / 128; end
    else                          				begin temp_buffer_nxt[2][3] = temp_buffer[2][3]; end
          
	if(STATE == MUL1 && count == 12)            begin temp_buffer_nxt[3][0] = (D[3][0] * inbuffer[0][0] + D[3][1] * inbuffer[1][0] + D[3][2]*inbuffer[2][0] + D[3][3] * inbuffer[3][0]) / 128; end
    else                          				begin temp_buffer_nxt[3][0] = temp_buffer[3][0]; end
    if(STATE == MUL1 && count == 13)            begin temp_buffer_nxt[3][1] = (D[3][0] * inbuffer[0][1] + D[3][1] * inbuffer[1][1] + D[3][2]*inbuffer[2][1] + D[3][3] * inbuffer[3][1]) / 128; end
    else                          				begin temp_buffer_nxt[3][1] = temp_buffer[3][1]; end
    if(STATE == MUL1 && count == 14)            begin temp_buffer_nxt[3][2] = (D[3][0] * inbuffer[0][2] + D[3][1] * inbuffer[1][2] + D[3][2]*inbuffer[2][2] + D[3][3] * inbuffer[3][2]) / 128; end
    else                          				begin temp_buffer_nxt[3][2] = temp_buffer[3][2]; end
    if(STATE == MUL1 && count == 15)            begin temp_buffer_nxt[3][3] = (D[3][0] * inbuffer[0][3] + D[3][1] * inbuffer[1][3] + D[3][2]*inbuffer[2][3] + D[3][3] * inbuffer[3][3]) / 128; end
    else                          				begin temp_buffer_nxt[3][3] = temp_buffer[3][3]; end
      
end
///////////////////////////// output
always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		out_data <= 0;
	end
	else begin
		out_data <= out_data_nxt;
	end
end
always_comb begin
	if(!out_valid_nxt) begin
		out_data_nxt = 0;
	end
	else begin
	case(output_cnt)
		0: out_data_nxt = (temp_buffer[0][0] * DT[0][0] + temp_buffer[0][1] * DT[1][0] + temp_buffer[0][2]*DT[2][0] + temp_buffer[0][3] * DT[3][0]) / 128;
	    1: out_data_nxt = (temp_buffer[0][0] * DT[0][1] + temp_buffer[0][1] * DT[1][1] + temp_buffer[0][2]*DT[2][1] + temp_buffer[0][3] * DT[3][1]) / 128;
		2: out_data_nxt = (temp_buffer[0][0] * DT[0][2] + temp_buffer[0][1] * DT[1][2] + temp_buffer[0][2]*DT[2][2] + temp_buffer[0][3] * DT[3][2]) / 128;
		3: out_data_nxt = (temp_buffer[0][0] * DT[0][3] + temp_buffer[0][1] * DT[1][3] + temp_buffer[0][2]*DT[2][3] + temp_buffer[0][3] * DT[3][3]) / 128;
		4: out_data_nxt = (temp_buffer[1][0] * DT[0][0] + temp_buffer[1][1] * DT[1][0] + temp_buffer[1][2]*DT[2][0] + temp_buffer[1][3] * DT[3][0]) / 128;
		5: out_data_nxt = (temp_buffer[1][0] * DT[0][1] + temp_buffer[1][1] * DT[1][1] + temp_buffer[1][2]*DT[2][1] + temp_buffer[1][3] * DT[3][1]) / 128;
		6: out_data_nxt = (temp_buffer[1][0] * DT[0][2] + temp_buffer[1][1] * DT[1][2] + temp_buffer[1][2]*DT[2][2] + temp_buffer[1][3] * DT[3][2]) / 128;
		7: out_data_nxt = (temp_buffer[1][0] * DT[0][3] + temp_buffer[1][1] * DT[1][3] + temp_buffer[1][2]*DT[2][3] + temp_buffer[1][3] * DT[3][3]) / 128;
		8: out_data_nxt = (temp_buffer[2][0] * DT[0][0] + temp_buffer[2][1] * DT[1][0] + temp_buffer[2][2]*DT[2][0] + temp_buffer[2][3] * DT[3][0]) / 128;
		9: out_data_nxt = (temp_buffer[2][0] * DT[0][1] + temp_buffer[2][1] * DT[1][1] + temp_buffer[2][2]*DT[2][1] + temp_buffer[2][3] * DT[3][1]) / 128;
		10:out_data_nxt = (temp_buffer[2][0] * DT[0][2] + temp_buffer[2][1] * DT[1][2] + temp_buffer[2][2]*DT[2][2] + temp_buffer[2][3] * DT[3][2]) / 128;
		11:out_data_nxt = (temp_buffer[2][0] * DT[0][3] + temp_buffer[2][1] * DT[1][3] + temp_buffer[2][2]*DT[2][3] + temp_buffer[2][3] * DT[3][3]) / 128;
		12:out_data_nxt = (temp_buffer[3][0] * DT[0][0] + temp_buffer[3][1] * DT[1][0] + temp_buffer[3][2]*DT[2][0] + temp_buffer[3][3] * DT[3][0]) / 128;
		13:out_data_nxt = (temp_buffer[3][0] * DT[0][1] + temp_buffer[3][1] * DT[1][1] + temp_buffer[3][2]*DT[2][1] + temp_buffer[3][3] * DT[3][1]) / 128;
		14:out_data_nxt = (temp_buffer[3][0] * DT[0][2] + temp_buffer[3][1] * DT[1][2] + temp_buffer[3][2]*DT[2][2] + temp_buffer[3][3] * DT[3][2]) / 128;
		15:out_data_nxt = (temp_buffer[3][0] * DT[0][3] + temp_buffer[3][1] * DT[1][3] + temp_buffer[3][2]*DT[2][3] + temp_buffer[3][3] * DT[3][3]) / 128;
		default:out_data_nxt = 0;
	endcase
	end
end
endmodule