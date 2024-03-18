module Counter(
	// Input signals
	clk,
	rst_n,
	// Output signals
	clk2
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input        clk, rst_n;
output logic clk2;
logic [1:0] count;
//---------------------------------------------------------------------
//   REG AND WIRE DECLARATION                         
//---------------------------------------------------------------------
always @ (posedge clk or negedge rst_n) begin 
    if(!rst_n) count <= 0;
    else if (count == 3) count <= 0;
    else count <= count + 1;
end

always @(posedge clk or negedge rst_n) begin 
    if(!rst_n) clk2 <= 0;
    else if (count < 2) clk2 <= 0;
    else clk2 <= 1;
end

endmodule
