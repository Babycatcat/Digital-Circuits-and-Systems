module Sort(
    // Input signals
	in_num0,
	in_num1,
	in_num2,
	in_num3,
	in_num4,
    // Output signals
	out_num
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input  [5:0] in_num0, in_num1, in_num2, in_num3, in_num4;
output logic [5:0] out_num;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [5:0] n0,n1,n2,n3,n4;



//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
always_comb begin
	n0 = in_num0;
	n1 = in_num1;
	n2 = in_num2;
	n3 = in_num3;
	n4 = in_num4; 
	if( n0 > n1) begin
		logic [5:0] t1;
		t1 = n0;
		n0 = n1;
		n1 = t1;
	end
	if( n2 > n3) begin
		logic [5:0] t2;
		t2 = n2;
		n2 = n3;
		n3 = t2;
	end
	if( n1 > n2) begin
		logic [5:0] t3;
		t3 = n1;
		n1 = n2;
		n2 = t3;
	end
	if( n3 > n4) begin
		logic [5:0] t4;
		t4 = n3;
		n3 = n4;
		n4 = t4;
	end
	if( n0 > n1) begin
		logic [5:0] t5;
		t5 = n0;
		n0 = n1;
		n1 = t5;
	end
	if( n2 > n3) begin
		logic [5:0] t6;
		t6 = n2;
		n2 = n3;
		n3 = t6;
	end
	if( n1 > n2) begin
		logic [5:0] t7;
		t7 = n1;
		n1 = n2;
		n2 = t7;
	end
	if( n3 > n4) begin
		logic [5:0] t8;
		t8 = n3;
		n3 = n4;
		n4 = t8;
	end
	if( n0 > n1) begin
		logic [5:0] t9;
		t9 = n0;
		n0 = n1;
		n1 = t9;
	end
	if( n2 > n3) begin
		logic [5:0] t10;
		t10 = n2;
		n2 = n3;
		n3 = t10;
	end
	out_num = n2;
end


endmodule