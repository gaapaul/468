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
assign source_reg2 = (opcode == 4'b1110) ? instruction[9:7] : instruction[3:1];
assign load_shift = instruction[6:0];

always @(*) begin
  case (instruction[15:14]) //condition code
    2'b00: cc_success = 1'b1;
    2'b01: if (zero == 1'b1) cc_success = 1'b1; else cc_success = 1'b0;
    2'b10: if (neg == ovf) cc_success = 1'b1; else cc_success = 1'b0;
    2'b11: if (neg != ovf) cc_success = 1'b1; else cc_success = 1'b0;
  endcase
end
assign cc_success = condition_code_success;
endmodule
/*
#                  110
# din = 1101110101101011, v: 0, z:1, n:0
# Condition Code = 11
# condition_code_check = z
# opcode: 0111
# dest_reg: 010
# operand1: 110
# operand2: 101
# load_bits: 1101011
#                  120
# din = 1110100100011101, v: 0, z:1, n:1
# Condition Code = 11
# condition_code_check = z
# opcode: 1010
# dest_reg: 010
# operand1: 001
# operand2: 110
# load_bits: 0011101
#                  130
# din = 0000101011001010, v: 0, z:0, n:0
# Condition Code = 00
# condition_code_check = z
# opcode: 0010
# dest_reg: 101
# operand1: 100
# operand2: 101
# load_bits: 1001010
#                  140
# din = 1011001101000001, v: 1, z:0, n:0
# Condition Code = 10
# condition_code_check = z
# opcode: 1100
# dest_reg: 110
# operand1: 100
# operand2: 000
# load_bits: 1000001
#                  150
# din = 0000110111101011, v: 0, z:0, n:0
# Condition Code = 00
# condition_code_check = z
# opcode: 0011
# dest_reg: 011
# operand1: 110
# operand2: 101
# load_bits: 1101011
#                  160
# din = 0000001010111100, v: 1, z:0, n:1
# Condition Code = 00
# condition_code_check = z
# opcode: 0000
# dest_reg: 101
# operand1: 011
# operand2: 110
# load_bits: 0111100
#                  170
# din = 0100000110000101, v: 0, z:1, n:1
# Condition Code = 01
# condition_code_check = z
# opcode: 0000
# dest_reg: 011
# operand1: 000
# operand2: 010
# load_bits: 0000101
#                  180
# din = 0011001001111110, v: 1, z:1, n:1
# Condition Code = 00
# condition_code_check = z
# opcode: 1100
# dest_reg: 100
# operand1: 111
# operand2: 111
# load_bits: 1111110
#                  190
# din = 0000011101100010, v: 1, z:0, n:1
# Condition Code = 00
# condition_code_check = z
# opcode: 0001
# dest_reg: 110
# operand1: 110
# operand2: 001
# load_bits: 1100010
#                  200
# din = 1010100111111000, v: 0, z:1, n:1
# Condition Code = 10
# condition_code_check = z
# opcode: 1010
# dest_reg: 011
# operand1: 111
# operand2: 100
# load_bits: 1111000*/