module alu_eor(
  input [15:0] operand1,
  input [15:0] operand2,
  output [15:0] dout);
  
  assign dout = operand1 ^ operand2;
  
endmodule 