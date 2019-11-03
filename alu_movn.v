module alu_movn(
  input wire  [6:0] immediate_offset,
  output wire  [15:0] dout);
  
  assign dout = immediate_offset;
  
endmodule 