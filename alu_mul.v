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
  //http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.dui0204j/Cihihggj.html
  // If S is specified, the MUL and MLA instructions:
      //- update the N and Z flags according to the result
      //- do not affect the C or V flag in ARMv5T and above
endmodule 