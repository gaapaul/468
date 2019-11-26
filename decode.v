//This module Decodes the incoming instruction
module decoding(
  input [15:0] instruction,
  input  zero,
  input  neg,
  input  ovf,
  output condition_code_success,
  output [1:0] cond,
  output [3:0] opcode,
  output [2:0] dest_reg,
  output [2:0] source_reg1,
  output [2:0] source_reg2,
  output [6:0] load_shift);
reg    cc_success;
assign cond = instruction[15:14];
assign opcode = instruction [13:10];
assign dest_reg = instruction [9:7];
assign source_reg1 = instruction [6:4];
//if it is a store we need dest reg from reg file to store 
assign source_reg2 = instruction[3:1];
assign load_shift = instruction[6:0];

always @(*) begin
  case (instruction[15:14]) //condition code
    2'b00: cc_success = 1'b1;
    2'b01: if (zero == 1'b1) cc_success = 1'b1; else cc_success = 1'b0;
    2'b10: if (neg == ovf) cc_success = 1'b1; else cc_success = 1'b0;
    2'b11: if (neg != ovf) cc_success = 1'b1; else cc_success = 1'b0;
  endcase
end
assign condition_code_success = cc_success;
endmodule
