module alu_adder(
  input wire [15:0] operand1,
  input wire [15:0] operand2,
  output wire [15:0] dout,
  output wire ovf,
  output wire carry);
  wire [16:0]      op1;
  wire [16:0]      op2;
  wire ovf_1;
  // wire ovf_2;
  //sign extension
  wire [17:0] result;
  assign op1 = {operand1[15],operand1};
  assign op2 = {operand2[15],operand2};
  
  assign result = op1 + op2;
  assign dout = result[15:0];

  //overflow and carry detection
  assign carry = result[17];
  assign ovf_1 = (result[16:15] == 2'b01) ? 1'b1 : 1'b0;
  assign unf = (result[16:15] == 2'b10) ? 1'b1 : 1'b0;
  assign ovf = ovf_1 || unf;
  // assign ovf_2 = ((op1[15] == 1'b0 && op2[15] == 1'b0 && result[15] == 1'b1) ||
           // (op1[15] == 1'b1 && op2[15] == 1'b1 && result[15] == 1'b0))  ? 1'b1 : 1'b0;
  
  //V set example  
  //0x7fff + 0x7fff = 0xfffe //V=1, C=0 aka unsigned correct but signed is wrong
  //32767 + 32767 = -2 //above in signed  WRONG
  //32767 + 32767 = 65534 //above in unsigned CORRECT
  
  //C set example 
  //0xFFFF + 0x1   = 0 //V = 0, C = 1 aka signed correct but unsigned wrong
  //-1 + 1   = 0 //above in signed CORRECT
  //65535 + 1   = 0 //above in unsigned WRONG
  
  //V and C example
  //0x8000 +  0xE000 = 0x16000
  //32768 +  57344 =  90112 truncates to 24576  //unsigned evaluation wrong carry set as result bigger than 65535
  //-32768 + -8192 = -40960 truncates to  24576 //signed evaluation wrong ovf set
endmodule 