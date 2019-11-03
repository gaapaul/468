// Overflow(V) and Carry(C) flags are not needed for bitwise-OR
// Zero(Z)and Negative (N) might need for bitwise-OR
module alu_orr(
  input [15:0] operand1,
  input [15:0] operand2,
  output [15:0] dout);

  assign dout = operand1 | operand2;
  
endmodule 