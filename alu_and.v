module alu_and(
  input wire  [15:0] operand1,
  input wire  [15:0] operand2,
  output wire  [15:0] dout);
  
  assign dout = operand1 & operand2;
  
endmodule 