module mul_tb();

  integer i;
  reg [15:0] a_in_reg;
  wire [15:0] a_in;
  reg [15:0] b_in_reg;
  wire [15:0] b_in;
  wire signed [15:0] dout;
  wire ovf;
  wire v_ref;
  wire v_ref_1;

  reg signed [31:0] ref_res;
  initial begin
    for(i=0; i<1000000;i=i+1) begin
      if($random & 100 == 0)
        a_in_reg = b_in_reg;
      else if($random % 100 == 0) begin 
        a_in_reg = 0;
        b_in_reg = $random;
      end else if($random % 50 == 0) begin
        a_in_reg = $random % 2048;
        b_in_reg = $random % 40;
      end else begin
        a_in_reg = $random % 256;
        b_in_reg = $random % 256;
      end
      ref_res = $signed(a_in_reg)*$signed(b_in_reg);
      #10
      //if(v_ref != ovf) $display("Error V. Ref V: %d, V: %d", v_ref, ovf); //V is wrong
      //check result, should be correct if overflow is not set
      if(((ref_res) != (dout)) && (v_ref == 0)) $display("Error Calc 0. Ref Res: %d, dout: %d", $signed(ref_res), $signed(dout[15:0]));
      //check that result is wrong 
      if(((ref_res) == dout) && (v_ref == 1)) $display("Error Calc 2. Ref Res: %d, dout: %d",  $signed(ref_res), $signed(dout[15:0]));
      //$display("%d,%d,%d,%d", $signed(a_in),$signed(b_in),$signed(dout[15:0]), ovf);
    end
    //$finish;
  end
  //assign v_ref = ((ref_res > $signed(16'd32767)) ||(ref_res < $signed(-16'd32768))) ? 1'b1 : 1'b0;
  assign a_in = a_in_reg; 
  assign b_in = b_in_reg;
  
  alu_mul mult( 
    .operand1 (a_in),
    .operand2 (b_in),
    .dout(dout));
    //.ovf(ovf));


endmodule
