module alu_ror(
  input [15:0] operand1,
  input [3:0] immediate_offset,
  output reg [15:0] dout);
  genvar i;

  always@(*)
  begin
    case(immediate_offset)
      4'd0: dout = operand1;
      4'd1: dout = {operand1[0], operand1[15:1]};
      4'd2: dout = {operand1[1:0], operand1[15:2]};
      4'd3: dout = {operand1[2:0], operand1[15:3]};
      4'd4: dout = {operand1[3:0], operand1[15:4]};
      4'd5: dout = {operand1[4:0], operand1[15:5]};
      4'd6: dout = {operand1[5:0], operand1[15:6]};
      4'd7: dout = {operand1[6:0], operand1[15:7]};
      4'd8: dout = {operand1[7:0], operand1[15:8]};
      4'd9: dout = {operand1[8:0], operand1[15:9]};
      4'd10: dout = {operand1[9:0], operand1[15:10]};
      4'd11: dout = {operand1[10:0], operand1[15:11]};
      4'd12: dout = {operand1[11:0], operand1[15:12]};
      4'd13: dout = {operand1[12:0], operand1[15:13]};
      4'd14: dout = {operand1[13:0], operand1[15:14]};
      4'd15: dout = {operand1[14:0], operand1[15]};
      default: dout = 16'bx;
    endcase    
  end
endmodule 
