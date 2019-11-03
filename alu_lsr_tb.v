module alu_lsr_tb;
	integer i;
	reg [15:0] op1;
	reg [3:0] lsr_n;
	wire [15:0] Result;

	initial begin
		for (i=0; i<11; i = i+1) begin
			#10;
			op1 = ($random % 65536);
			lsr_n = ($random % 16);
		end
	end

	initial begin
		$monitor($time, "Reg1: %b, n: %d, ResultReg= %b", op1, lsr_n, Result);
	end

	alu_lsr shift_right(
		.operand1(op1),
		.immediate_offset(lsr_n),
		.dout(Result));
	
endmodule