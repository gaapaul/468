module alu_lsl(
  input [15:0] operand1,
  input [3:0] immediate_offset,
  output [15:0] dout);
  
  assign dout = operand1 << immediate_offset;
  
endmodule 