module decoder_tb();
  integer i;
  reg     clk, rst, start, cc_check;
  wire    zero,negative,overflow;
  reg     z_reg,v_reg,n_reg;
  reg  [15:0]  data_in_reg;
  reg  [15:0]  data_in;
  wire [1:0]   condition_code;
  wire         condition_code_success;
  wire [3:0] opcode;
  wire [2:0] dest_reg;
  wire  [2:0] operand1;
  wire  [2:0] operand2;
  wire   [6:0] load_bits;

  initial begin
    #5
      for (i = 0; i < 35; i=i+1) begin
        data_in_reg <= $random;
        z_reg <= $random;
        n_reg <= $random;
        v_reg <= $random;
        #5;
        $display($time);
        $display("din = %b, v: %b, z:%b, n:%b", data_in_reg, v_reg,z_reg, n_reg);
        $display("Condition Code = %b", condition_code);
        $display("condition_code_check = %b", condition_code_success);
        $display("opcode: %b", opcode);
        $display("dest_reg: %b", dest_reg);
        $display("operand1: %b", operand1);
        $display("operand2: %b", operand2);
        $display("load_bits: %b", load_bits);
        #5;
      end
  end
  assign data_in = data_in_reg;
  assign zero = z_reg;
  assign negative = n_reg;
  assign overflow = v_reg;

  decoding input_decoder(
    .instruction(data_in),
    .zero(zero),
    .neg(negative),
    .ovf(overflow),
    .cond(condition_code),
    .opcode(opcode),
    .dest_reg(dest_reg),
    .source_reg1(operand1),
    .source_reg2(operand2),
    .load_shift(load_bits),
    .condition_code_success(condition_code_success)
  );
endmodule

/* Simulation Results
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
# load_bits: 1111000
*/