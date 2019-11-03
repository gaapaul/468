module alu_lsr(
  input wire  [15:0] operand1,
  input wire  [3:0] immediate_offset,
  output wire  [15:0] dout);
  
  assign dout = operand1 >> immediate_offset;
  
endmodule 