module alu_ror_tb;
	integer i;
	reg [15:0] op1;
	reg [3:0] ror_n;
	wire [15:0] Result;

	initial begin
		for (i=0; i<11; i = i+1) begin
			#10;
			op1 = ($random % 65536);
			ror_n = ($random % 16);
		end
	end

	initial begin
		$monitor($time, "Reg1: %b, n: %d, ResultReg= %b", op1, ror_n, Result);
	end

	alu_ror rotate(
		.operand1(op1),
		.immediate_offset(ror_n),
		.dout(Result));
	
endmodule