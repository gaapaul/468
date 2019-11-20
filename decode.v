module decode_inputs(
  input  clk,
  input  rst_n,
  input  [15:0] data_in,
  input  zero,
  input  negative,
  input  overflow,
  output [1:0] condition_code,
  output [3:0] opcode,
  output [2:0] dest_reg,
  output [2:0] operand1,
  output [2:0] operand2,
  output [6:0] load_bits,
  output cond_code_success);
  reg    cc_success;
  //decode data
  assign condition_code = data_in[15:14];
  assign opcode = data_in[13:10];
  assign dest_reg = data_in[9:7];
  assign load_bits = data_in[6:0];
  assign operand1 = data_in[6:4];
  assign operand2 = (opcode == 4'b1110) ? data_in[9:7] : data_in[3:1];
  //FLAG logic
  //move to module
  always@(*) begin
    if((condition_code == 2'b00) || //no condition
       (condition_code == 2'b01 && zero == 1'b1) || //equal
       (condition_code == 2'b10 && (negative == overflow)) || //greater or equal
       (condition_code == 2'b11 && (negative != overflow))) begin //less than
      //do calc 
      cc_success= 1'b1;
    end else begin
      //dont do 
      cc_success = 1'b0;
    end
  end // always@ (*)
  assign cond_code_success = cc_success;
endmodule
