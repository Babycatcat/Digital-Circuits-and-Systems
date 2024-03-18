module BCD(
  // Input signals
	in_bin,
  // Output signals
	out_hundred,
	out_ten,
	out_unit
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
//Input Ports
input [8:0] in_bin;

//output Ports
output logic [2:0]out_hundred;
output logic [3:0]out_ten;
output logic [3:0]out_unit;


//---------------------------------------------------------------------
//   LOGIC DECLARATION
reg [3:0] hundred,ten,unit;
reg [6:0] temp;
//---------------------------------------------------------------------


//---------------------------------------------------------------------
//   Your DESIGN           
always @(*) begin
	hundred = in_bin / 100;
	temp = in_bin % 100;
	ten = temp / 10;
	unit = temp % 10;
end

assign out_hundred = hundred;
assign out_ten = ten;
assign out_unit = unit;

	             
//---------------------------------------------------------------------


endmodule
