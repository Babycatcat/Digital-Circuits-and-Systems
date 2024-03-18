/// version 2
/// clock cycle 5.8
/// total latency 397625
/// area 519184
module Conv(
	// Input signals
	clk,
	rst_n,
	filter_valid,
	image_valid,
	filter_size,
	image_size,
	pad_mode,
	act_mode,
	in_data,
	// Output signals
	out_valid,
	out_data
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, image_valid, filter_valid, filter_size, pad_mode, act_mode;
input [3:0] image_size;
input signed [7:0] in_data;
output logic out_valid;
output logic signed [15:0] out_data;
logic filter_valid_reg,filter_valid_nxt;
logic image_valid_reg,image_valid_nxt;
logic [2:0]filter_size_reg,filter_size_nxt;
logic [3:0] image_size_reg,image_size_nxt;
logic pad_mode_reg,pad_mode_nxt,act_mode_reg,act_mode_nxt;
logic signed [7:0] filter_data_reg[0:4][0:4],filter_data_nxt[0:4][0:4];
logic signed [7:0] image_data_reg[0:11][0:11],image_data_nxt[0:11][0:11];
logic signed [7:0] image_25_comb[0:4][0:4];//5*5
logic signed [7:0] image_9_comb[0:2][0:2];//3*3
logic signed [15:0] multiply_reg[0:4][0:4],multiply_nxt[0:4][0:4];
logic signed [19:0] sum_reg,sum_nxt;
logic signed [15:0] out_data_nxt;
logic out_valid_nxt;
logic [2:0] filter_i,filter_i_nxt;
logic [2:0] filter_j,filter_j_nxt;
logic [4:0] count_i,count_i_nxt;
logic [4:0] count_j,count_j_nxt;
logic [4:0] count_i_convolution,count_i_convolution_nxt;
logic [4:0] count_j_convolution,count_j_convolution_nxt;
logic [5:0] count_out,count_out_nxt;
logic [2:0] state,state_nxt,state_delay,state_delay_delay;
parameter IDLE = 0;
parameter FILTER = 1;
parameter IMAGE = 2;
parameter CONVOLUTION = 3;
////////////////////////////////////////////////////////state
always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin 
		state <= IDLE;
		state_delay <= IDLE;
		state_delay_delay <= IDLE;
	end
	else begin 
		state <= state_nxt;
		state_delay <= state;
		state_delay_delay <= state_delay;
	end
end
always_comb begin
	case(state)
		IDLE: begin //0
			if(filter_valid) state_nxt = FILTER;
			else if(image_valid) state_nxt = IMAGE;
			else state_nxt = IDLE;end
		FILTER: begin //1
			if(image_valid) state_nxt = IMAGE;
			else state_nxt = FILTER;end 
		IMAGE: begin //2
			if(!image_valid && image_valid_reg) state_nxt = CONVOLUTION;
			else state_nxt = IMAGE; end
		CONVOLUTION: begin //3
			if(count_out > image_size_reg * image_size_reg - 2) state_nxt = IDLE;
			else state_nxt = CONVOLUTION; end
		default: state_nxt = IDLE;
	endcase
end
/////////////////////////////////////////////////////////////////////////////////////////////////////counter
always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		filter_i <= 0;
		filter_j <= 0;
		count_i <= 2;
		count_j <= 2;
		count_i_convolution <= 2;
		count_j_convolution <= 2;
		count_out <= 0;
	end
	else begin 
		filter_i <= filter_i_nxt;
		filter_j <= filter_j_nxt;
		count_i <= count_i_nxt;
		count_j <= count_j_nxt;
		count_i_convolution <= count_i_convolution_nxt;
		count_j_convolution <= count_j_convolution_nxt;
		count_out <= count_out_nxt;
	end
end
always_comb begin ////// count filter i , j
	if(filter_valid && filter_j < filter_size_reg - 1) filter_j_nxt = filter_j + 1;
	else if(filter_valid && filter_j == filter_size_reg - 1) filter_j_nxt = 0;
	else filter_j_nxt = filter_j;
	if(filter_valid && filter_i != filter_size_reg - 1 && filter_j == filter_size_reg - 1) filter_i_nxt = filter_i + 1;
	else if(filter_valid && filter_i == filter_size_reg - 1 && filter_j == filter_size_reg - 1)  filter_i_nxt = 0;
	else filter_i_nxt = filter_i;
end
always_comb begin /////// count image i , j
	if(image_valid && count_j < image_size_reg + 1) count_j_nxt = count_j + 1;
	else if(image_valid && count_j == image_size_reg + 1) count_j_nxt = 2;
	else count_j_nxt = count_j;
	if(image_valid && count_i != image_size_reg + 1 && count_j == image_size_reg + 1) count_i_nxt = count_i + 1;
	else if(image_valid && count_i == image_size_reg + 1 && count_j == image_size_reg + 1)  count_i_nxt = 2;
	else count_i_nxt = count_i;
end
always_comb begin //////// convolution image i , j
	if(state_nxt == CONVOLUTION && count_j_convolution < image_size_reg + 1) count_j_convolution_nxt = count_j_convolution + 1;
	else if(state == CONVOLUTION && count_j_convolution == image_size_reg + 1 || state == IDLE) count_j_convolution_nxt = 2;
	else count_j_convolution_nxt = count_j_convolution;
	if(state == CONVOLUTION && count_i_convolution != image_size_reg + 1 && count_j_convolution == image_size_reg + 1) count_i_convolution_nxt = count_i_convolution + 1;
	else if(state == CONVOLUTION && count_i_convolution == image_size_reg + 1 && count_j_convolution == image_size_reg + 1 || state == IDLE)  count_i_convolution_nxt = 2;
	else count_i_convolution_nxt = count_i_convolution;
end
always_comb begin //////// count output
	if(count_out < image_size_reg * image_size_reg - 1 && state_delay_delay == CONVOLUTION && state == CONVOLUTION) count_out_nxt = count_out + 1;
	else count_out_nxt = 0;
end
///////////////////////////////////////////////////////////////////input
always_ff @(posedge clk or negedge rst_n) begin////input valid
	if(!rst_n) begin
		filter_valid_reg <= 0;
		image_valid_reg <= 0;
	end
	else begin
		filter_valid_reg <= filter_valid_nxt;
		image_valid_reg <= image_valid_nxt;
	end
end
always_comb begin
	filter_valid_nxt = filter_valid;
	image_valid_nxt = image_valid;
end
always_ff @(posedge clk or negedge rst_n) begin////input filter configuration
	if(!rst_n) begin
		filter_size_reg <= 0;
		image_size_reg <= 0;
		pad_mode_reg <= 0;
		act_mode_reg <= 0;
		for(int i = 0;i < 5;i++) begin
			for(int j = 0;j < 5;j++) begin
				filter_data_reg[i][j] <= 0;
			end
		end
	end
	else begin
		filter_size_reg <= filter_size_nxt;
		image_size_reg <= image_size_nxt;
		pad_mode_reg <= pad_mode_nxt;
		act_mode_reg <= act_mode_nxt;
		for(int i = 0;i < 5;i++) begin
			for(int j = 0;j < 5;j++) begin
				filter_data_reg[i][j] <= filter_data_nxt[i][j];
			end
		end
	end
end
always_comb begin
	if(filter_valid_nxt && !filter_valid_reg) begin
		if(!filter_size) filter_size_nxt = 3;
		else filter_size_nxt = 5;
		image_size_nxt = image_size;
		pad_mode_nxt = pad_mode;
		act_mode_nxt = act_mode;
	end
	else begin
		filter_size_nxt = filter_size_reg;
		image_size_nxt = image_size_reg;
		pad_mode_nxt = pad_mode_reg;
		act_mode_nxt = act_mode_reg;
	end
end
always_comb begin////////////////////////////////// input filter data
	for(int i = 0;i < 5;i++) begin
		for(int j = 0;j < 5;j++) begin
			if(filter_valid && i == filter_i && j == filter_j) filter_data_nxt[i][j]= in_data;
			else if (filter_valid && !filter_valid_reg) filter_data_nxt[i][j] = 0;
			else filter_data_nxt[i][j] = filter_data_reg[i][j];
			
		end
	end
end
//////////////////////////////////////////////////////// input image data
always_ff @(posedge clk or negedge rst_n) begin 
	if(!rst_n) begin
		for(int i = 0;i < 12;i++) begin
			for(int j = 0;j < 12;j++) begin
				image_data_reg[i][j] <= 0;
			end
		end
	end
	else begin
		for(int i = 0;i < 12;i++) begin
			for(int j = 0;j < 12;j++) begin
				image_data_reg[i][j] <= image_data_nxt[i][j];
			end
		end
	end
end
always_comb begin
	if(!pad_mode_reg && state_nxt != IDLE) begin ////////////////////////////////////////////////////////////////////// zero padding
		for(int i = 0;i < 12;i++) begin
			for(int j = 0;j < 12;j++) begin
				if(image_valid && i == count_i  && j == count_j) image_data_nxt[i][j] = in_data;
				else if(state == IDLE) image_data_nxt[i][j] = 0;
				else image_data_nxt[i][j] = image_data_reg[i][j];
			end
		end
	end
	else if(pad_mode_reg && state_nxt != IDLE) begin ////////////////////////////////////////////////////////////////////////////// replication padding
		for(int i = 0;i < 12;i++) begin
			for(int j = 0;j < 12;j++) begin
				if(image_valid && count_i == 2 && count_j == 2 && i <= 2 && j <= 2) image_data_nxt[i][j] = in_data;
				else if(image_valid && count_i == 2 && count_j == j && count_j < image_size_reg + 1 && i <= 2) image_data_nxt[i][j] = in_data; 
				else if( image_valid && count_i == 2 && count_j == image_size_reg + 1 && i <= count_i && j >= count_j) image_data_nxt[i][j] = in_data;
				else if(image_valid && count_i >= 3 && count_j == 2 && i == count_i && j <= 2) image_data_nxt[i][j] = in_data;
				else if(image_valid && count_i == image_size_reg + 1 && count_j == 2 && i >= count_i && j <= 2) image_data_nxt[i][j] = in_data;
				else if(image_valid && count_i == image_size_reg + 1 && count_j < image_size_reg + 1 && i >= count_i && j == count_j) image_data_nxt[i][j]= in_data;
				else if(image_valid && count_i == image_size_reg + 1 && count_j == image_size_reg + 1 && i >= count_i && j >= count_j) image_data_nxt[i][j] = in_data;
				else if(image_valid && count_i >= 2 && count_j == image_size_reg + 1 && i == count_i && j >= count_j) image_data_nxt[i][j] = in_data;
				else if(image_valid && count_i > 2 && count_i < image_size_reg + 1 && count_j > 2 && count_j < image_size_reg + 1 && i == count_i && j == count_j) image_data_nxt[i][j] = in_data;
				else image_data_nxt[i][j] = image_data_reg[i][j];
			end
		end
	end
	else begin
		for(int i = 0;i < 12;i++) begin
			for(int j = 0;j < 12;j++) begin
				image_data_nxt[i][j] = 0;
			end
		end
	end
end
///////////////////////////////////////////////////////////////////image prepare 3*3 convolution
assign image_9_comb[0][0] = image_data_reg[count_i_convolution-1][count_j_convolution-1];
assign image_9_comb[0][1] = image_data_reg[count_i_convolution-1][count_j_convolution];
assign image_9_comb[0][2] = image_data_reg[count_i_convolution-1][count_j_convolution+1];
assign image_9_comb[1][0] = image_data_reg[count_i_convolution][count_j_convolution-1];
assign image_9_comb[1][1] = image_data_reg[count_i_convolution][count_j_convolution];
assign image_9_comb[1][2] = image_data_reg[count_i_convolution][count_j_convolution+1];
assign image_9_comb[2][0] = image_data_reg[count_i_convolution+1][count_j_convolution-1];
assign image_9_comb[2][1] = image_data_reg[count_i_convolution+1][count_j_convolution];
assign image_9_comb[2][2] = image_data_reg[count_i_convolution+1][count_j_convolution+1];
///////////////////////////////////////////////////////////////////image prepare 5*5 convolution
assign image_25_comb[0][0] = image_data_reg[count_i_convolution-2][count_j_convolution-2];
assign image_25_comb[0][1] = image_data_reg[count_i_convolution-2][count_j_convolution-1];
assign image_25_comb[0][2] = image_data_reg[count_i_convolution-2][count_j_convolution];
assign image_25_comb[0][3] = image_data_reg[count_i_convolution-2][count_j_convolution+1];
assign image_25_comb[0][4] = image_data_reg[count_i_convolution-2][count_j_convolution+2];
assign image_25_comb[1][0] = image_data_reg[count_i_convolution-1][count_j_convolution-2];
assign image_25_comb[1][1] = image_data_reg[count_i_convolution-1][count_j_convolution-1];
assign image_25_comb[1][2] = image_data_reg[count_i_convolution-1][count_j_convolution];
assign image_25_comb[1][3] = image_data_reg[count_i_convolution-1][count_j_convolution+1];
assign image_25_comb[1][4] = image_data_reg[count_i_convolution-1][count_j_convolution+2];
assign image_25_comb[2][0] = image_data_reg[count_i_convolution][count_j_convolution-2];
assign image_25_comb[2][1] = image_data_reg[count_i_convolution][count_j_convolution-1];
assign image_25_comb[2][2] = image_data_reg[count_i_convolution][count_j_convolution];
assign image_25_comb[2][3] = image_data_reg[count_i_convolution][count_j_convolution+1];
assign image_25_comb[2][4] = image_data_reg[count_i_convolution][count_j_convolution+2];
assign image_25_comb[3][0] = image_data_reg[count_i_convolution+1][count_j_convolution-2];
assign image_25_comb[3][1] = image_data_reg[count_i_convolution+1][count_j_convolution-1];
assign image_25_comb[3][2] = image_data_reg[count_i_convolution+1][count_j_convolution];
assign image_25_comb[3][3] = image_data_reg[count_i_convolution+1][count_j_convolution+1];
assign image_25_comb[3][4] = image_data_reg[count_i_convolution+1][count_j_convolution+2];
assign image_25_comb[4][0] = image_data_reg[count_i_convolution+2][count_j_convolution-2];
assign image_25_comb[4][1] = image_data_reg[count_i_convolution+2][count_j_convolution-1];
assign image_25_comb[4][2] = image_data_reg[count_i_convolution+2][count_j_convolution];
assign image_25_comb[4][3] = image_data_reg[count_i_convolution+2][count_j_convolution+1];
assign image_25_comb[4][4] = image_data_reg[count_i_convolution+2][count_j_convolution+2];
///////////////////////////////////////////////////////////////////////////////////////// convolution 
always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(int i = 0;i < 5;i++) begin
			for(int j = 0;j < 5;j++) begin 
				multiply_reg[i][j] <= 0;
			end
		end
		sum_reg <= 0;
	end
	else begin
		for(int i = 0;i < 5;i++) begin
			for(int j = 0;j < 5;j++) begin 
				multiply_reg[i][j] <= multiply_nxt[i][j];
			end
		end
		sum_reg <= sum_nxt;
	end
end
always_comb begin
	if(filter_size_reg == 3 && state_nxt == CONVOLUTION) begin // 3 * 3 multiply
	
		for(int i = 0;i < 5;i++) begin
			for(int j = 0;j < 5;j++) begin
				if(i < 3 && j < 3) multiply_nxt[i][j] = image_9_comb[i][j] * filter_data_reg[i][j];
				else multiply_nxt[i][j] = 0;
			end
		end
	end
	else if(filter_size_reg == 5 && state_nxt == CONVOLUTION) begin //5 * 5 multiply
	
		for(int i = 0;i < 5;i++) begin
			for(int j = 0;j < 5;j++) begin
				multiply_nxt[i][j] = image_25_comb[i][j] * filter_data_reg[i][j];
			end
		end	
	end
	else begin
		for(int i = 0;i < 5;i++) begin
			for(int j = 0;j < 5;j++) begin
				multiply_nxt[i][j] = 0;
			end
		end
	end
end
always_comb begin /////////////////////////////////////////////////////////////////////////////////////////////////////// sum up and activation function
	sum_nxt = multiply_reg[0][0] + multiply_reg[0][1] + multiply_reg[0][2] + multiply_reg[0][3] + multiply_reg[0][4] + 
		      multiply_reg[1][0] + multiply_reg[1][1] + multiply_reg[1][2] + multiply_reg[1][3] + multiply_reg[1][4] + 
			  multiply_reg[2][0] + multiply_reg[2][1] + multiply_reg[2][2] + multiply_reg[2][3] + multiply_reg[2][4] + 
			  multiply_reg[3][0] + multiply_reg[3][1] + multiply_reg[3][2] + multiply_reg[3][3] + multiply_reg[3][4] + 
			  multiply_reg[4][0] + multiply_reg[4][1] + multiply_reg[4][2] + multiply_reg[4][3] + multiply_reg[4][4] ;
	if(!act_mode_reg && out_valid_nxt) begin // ReLU
		if(sum_reg < 0) out_data_nxt = 0;
		else if (sum_reg > 32767) out_data_nxt = 32767;
		else out_data_nxt = sum_reg;
	end 
	else if(act_mode_reg && out_valid_nxt) begin // Leaky ReLU
		if(sum_reg < 0) out_data_nxt = sum_reg / 10;
		else if (sum_reg > 32767) out_data_nxt = 32767;
		else out_data_nxt = sum_reg;
	end
	else out_data_nxt = 0;
end
///////////////////////////////////output
always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		out_valid <= 0;
		out_data <= 0;
	end
	else begin
		out_valid <= out_valid_nxt;
		out_data <= out_data_nxt;
	end
end
always_comb begin//////////////////////////////// out valid
	if(state_delay == CONVOLUTION && state_nxt == CONVOLUTION) out_valid_nxt = 1;
	else out_valid_nxt = 0;
end

endmodule
