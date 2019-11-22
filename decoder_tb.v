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