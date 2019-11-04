module alu_mul(
  input wire signed [15:0] operand1,
  input wire signed [15:0] operand2,
  output wire signed [15:0] dout);
  //output wire ovf);

  wire [15:0] result;
  wire ovf_1;
  wire ovf_2;
  assign result = operand1 * operand2;
  assign dout = result[15:0];
  
  //can't overflow by multiplying 0
  // assign ovf = ((dout[15]^(operand1[15]^operand2[15])) && (operand1 != 0) && (operand2 != 0) || //check that we got the right sign
               // ((result[31:16] != 0) && (result[31:15] != 17'h1FFFF))) ? 1'b1 : 1'b0; //check to see if result is big
  //http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.dui0204j/Cihihggj.html
  // If S is specified, the MUL and MLA instructions:
      //- update the N and Z flags according to the result
      //- do not affect the C or V flag in ARMv5T and above
endmodule 