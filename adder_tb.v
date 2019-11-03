module adder_tb();

  integer i;
  reg [15:0] a_in_reg;
  wire [15:0] a_in;
  reg [15:0] b_in_reg;
  wire [15:0] b_in;
  wire [15:0] dout;
  wire ovf;
  wire c;
  reg c_ref;
  reg v_ref;

  integer s_ref_res;
  reg [31:0] ref_res;
  initial begin
    for(i=0; i<1000000;i=i+1) begin
      if($random & 100 == 0)
        a_in_reg = b_in_reg;
      else if($random % 100 == 0) begin 
        a_in_reg = 0;
        b_in_reg = $random;
      end else begin
        a_in_reg = $random;
        b_in_reg = $random;
      end
      if(i == 1) begin//C no V
        a_in_reg = 1;
        b_in_reg = -1;
      end
      if(i == 2) begin  //V no C
        a_in_reg = 16'd32767;
        b_in_reg = 16'd32767;
      end
      if(i == 3) begin 
        a_in_reg = 16'h8000;
        b_in_reg = 16'hE000;
      end
      ref_res = $signed(a_in_reg)+$signed(b_in_reg);
      s_ref_res = a_in_reg+b_in_reg;
      #10
      if(v_ref != ovf) $display("Error V. Ref V: %d, V: %d", v_ref, ovf); //V is wrong
      if(c_ref != c) $display("Error C. Ref C: %d, C: %d", c_ref, c);     //C is wrong
      //check signed result, should be correct if overflow is not set
      if(($signed(ref_res) != $signed(dout)) && (v_ref == 0)) $display("Error Calc 0. Ref Res: %d, dout: %d", $signed(ref_res), $signed(dout[15:0]));
      //check unsigned result, should be correct as long as c is not set
      if((s_ref_res != dout) && (c_ref == 0)) $display("Error Calc 1. Ref Res: %d, dout: %d", $signed(ref_res), $signed(dout[15:0]));
      //check that signed is wrong with both set
      if(($signed(ref_res) == $signed(dout)) && (v_ref == 1) && (c_ref == 1)) $display("Error Calc 2. Ref Res: %d, dout: %d",  $signed(ref_res), $signed(dout[15:0]));
      //check that unsigned is wrong with both set
      if((s_ref_res == dout) && (v_ref == 1) && (c_ref == 1)) $display("Error Calc 3. Ref Res: %d, dout: %d",  $signed(ref_res), $signed(dout[15:0]));
      //$display("%d,%d,%d,%d", $signed(a_in),$signed(b_in),$signed(dout[15:0]), ovf);
    end
    //$finish;
  end
  assign v_ref = (ref_res[31] != dout[15]) ? 1'b1 : 1'b0;
  assign c_ref = (s_ref_res >= 32'd65536) ? 1'b1 : 1'b0;
  assign a_in = a_in_reg;
  assign b_in = b_in_reg;
  
  alu_adder adder( 
    .operand1 (a_in),
    .operand2 (b_in),
    .dout(dout),
    .ovf(ovf),
    .carry(c));


endmodule

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
  