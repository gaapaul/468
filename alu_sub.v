module alu_sub(
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
  
  assign result = op1 - op2;
  assign dout = result[15:0];
  
  //overflow and carry detection
  assign carry = (!result[17]); //carry flag 0 if borrow
  assign ovf_1 = (result[16:15] == 2'b01) ? 1'b1 : 1'b0;
  assign unf = (result[16:15] == 2'b10) ? 1'b1 : 1'b0;
  assign ovf = ovf_1 || unf;
  // assign ovf_2 = ((op1[15] == 1'b0 && op2[15] == 1'b1 && result[15] == 1'b1) ||
           // (op1[15] == 1'b1 && op2[15] == 1'b0 && result[15] == 1'b0))  ? 1'b1 : 1'b0;
endmodule 
  //if C=0 then borrow
  //unsigned calc
  //17834 - 52381 =  -34547//C=0 aka borrow aka unsigned incorrect should be 
  //17834 - -13155 =  30989//signed is correct
  
  //V set example 
  //-16910 - 24970   = -41880//V = 1,  aka signed incorrect 
  //48626  - 24970   =  23656//unsigned calc correct C = 1 aka no borrow 
  
  //V and C set example  
  //12165 -  34936  =  42765 WRONG should be -22771
  //12165 - -22771 = -22771 WRONG should be -10606
  
  