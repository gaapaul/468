module alu_tb();

  integer i;
  reg     clk_10;
  wire    clk;
  //operand1
  wire [15:0] op1;
  //operand2
  wire [15:0] op2;
  //opcode
  wire [3:0] opcode;
  //immediate offset bits
  wire [6:0] immediate_offset;  
  //result
  wire [15:0] dout;
  reg c_ref;
  reg c_ref_d;
  reg v_ref;
  reg v_ref_d;
  wire z_ref;
  reg reset;
  wire         start;
  //flags
  wire         zero;
  wire         negative;
  wire         overflow;
  reg update_reg;
  wire         carry;
  reg [31:0] ref_res;
  reg [31:0] ref_res1;
  reg [31:0] ref_res1_d;
  integer s_ref_res1;
  integer s_ref_res1_d;
  wire [15:0] ref_res_half;
  reg negative_ref;
  reg zero_ref;
  reg carry_ref;
  reg overflow_ref;
  reg [15:0] op1_reg;
  reg [15:0] op2_reg;
  reg [15:0] op1_reg_d;
  reg [15:0] op2_reg_d;
  reg [3:0] opcode_d;
  reg [3:0] opcode_reg;
  reg [6:0] immediate_reg;
  reg [6:0] io_d;
  wire rst_n;
  assign clk = clk_10;
  assign rst_n = ~reset;
always@(*) begin
    v_ref = 0;
    c_ref = 0;
    case(opcode_reg)
      4'b0000: begin
        ref_res1 = $signed(op1_reg)+$signed(op2_reg);
        s_ref_res1 = op1_reg+op2_reg;
        v_ref = (ref_res1[31] != ref_res_half[15]) ? 1'b1 : 1'b0;
        c_ref = (s_ref_res1 >= 32'd65536) ? 1'b1 : 1'b0;
      end
      4'b0001: begin
        ref_res1 = $signed(op1_reg)-$signed(op2_reg);
        s_ref_res1 = op1_reg-op2_reg;
        v_ref = (ref_res1[31] != ref_res_half[15]) ? 1'b1 : 1'b0;
        c_ref = (s_ref_res1 >= 32'd65536) ? 1'b0 : 1'b1;
      end
      4'b0010: begin
        ref_res1 = $signed(op1_reg[15:0]) * $signed(op2_reg[15:0]);
        s_ref_res1 = $signed(op1_reg[15:0]) * $signed(op2_reg[15:0]);
        //v_ref = (($signed(ref_res1) > $signed(16'd32767)) ||($signed(ref_res1) < $signed(-16'd32768))) ? 1'b1 : 1'b0;
      end
      4'b0011:
        //idk if ORR can overflow?
        ref_res1 = op1_reg | op2_reg;
      4'b0100:
        //idk if AND can overflow?
        ref_res1 = op1_reg & op2_reg;
      4'b0101: 
        //idk if XOR can overflow?
        ref_res1 = op1_reg ^ op2_reg;
      4'b0110: 
        //no ovf
        ref_res1 = immediate_reg[6:0]; //use n as a number is layer above
      4'b0111: 
        ref_res1 = op1_reg;
      4'b1000: 
        ref_res1 = op1_reg >> immediate_reg[3:0]; //n must be between 0 to 16
      4'b1001: 
        ref_res1 = op1_reg << immediate_reg[3:0]; //n must be between 0 to 16
      4'b1010: 
        ref_res1[15:0] = (op1_reg << (5'd16 - immediate_reg[3:0]))| (op1_reg >> immediate_reg[3:0]); //rotate 0 to 16
      4'b1011: begin
        ref_res1 = $signed(op1_reg)-$signed(op2_reg);
        s_ref_res1 = op1_reg-op2_reg;
        v_ref = (ref_res1[31] != ref_res_half[15]) ? 1'b1 : 1'b0;
        c_ref = (s_ref_res1 >= 32'd65536) ? 1'b0 : 1'b1;
        s_ref_res1 = 1'b0;
      end
      4'b1100: 
        ref_res1 = immediate_reg[6:0]; //ADR
      4'b1101: begin
        ref_res1 = 1'b0;
        s_ref_res1 = 1'b0;
      end
      4'b1110: begin
        ref_res1 = 1'b0;
        s_ref_res1 = 1'b0;
      end
      4'b1111: begin
        ref_res1 = 1'b0;
        s_ref_res1 = 1'b0;
        end
    endcase
    if(opcode == 4'd0 || opcode == 4'd1 || opcode == 4'd2 ||
       opcode == 4'd11) begin
      update_reg = 1'b1;
    end else begin
      update_reg = 1'b0;
    end
end
always@(posedge clk or negedge rst_n) begin
  if(rst_n == 1'b0) begin 
    ref_res <= 0;
    negative_ref <= 0;
    zero_ref <= 0;
    carry_ref <= 0;
    overflow_ref <= 0;
    opcode_d<=0;
    op1_reg_d<=0;
    op2_reg_d<=0;
    io_d<=0;
    s_ref_res1_d<=0;
    ref_res1_d<=0;
    c_ref_d<=0;
    v_ref_d<=0;
  end else begin    
    opcode_d<=opcode_reg;
    op1_reg_d<=op1_reg;
    op2_reg_d<=op2_reg;
    io_d<=immediate_reg;
    s_ref_res1_d<=s_ref_res1;
    ref_res1_d<=ref_res1;
    c_ref_d<=c_ref;
    v_ref_d<=v_ref;
    //ref_res1_d;
    if(update_reg) begin
      negative_ref <= ref_res_half[15];
      zero_ref <= z_ref;
      if(opcode == 4'b0010) begin //mul then don't set new carry just update overflow
        carry_ref <= carry_ref;
        overflow_ref <= overflow_ref; 
      end else begin
        carry_ref <= c_ref;
        overflow_ref <= v_ref; 
      end
    end
    if(opcode == 11) begin
      ref_res <= 0;
    end else 
      ref_res <= ref_res_half;
    end
  end

  assign z_ref = (ref_res_half == 0) ? 1'b1 : 1'b0;
  assign ref_res_half = ref_res1[15:0];
  initial begin
    clk_10 <= 0;
    reset <= 1;
    #10
    //set wr_en to 1 and start for loop to load values
    reset <= 0;
    
    for(i=0;i<16;i=i+1)begin
      opcode_reg <=i;
      op1_reg <= i+2;
      op2_reg <= i+1;
      immediate_reg <= $random;
      #20;
      $display("\n");
      $display("Instruction Number:%d", i);
      $display("opcode:%d,Op1:%d,Op2:%d,Ioffset:%d,Result:%d",opcode_d,op1_reg_d,op2_reg_d,io_d,dout);
      $display("Signed: Op1:%d,Op2:%d,Ioffset:%d,Result:%d",$signed(op1_reg_d),$signed(op2_reg_d),$signed(io_d),$signed(dout));
      $display("TB: %d", ref_res);
      $display("Sgined TB: %d", $signed(ref_res));
      if(($signed(ref_res) != $signed(dout)) && (v_ref == 0)) 
        $display("Error Calc 0. Ref Res: %d, dout: %d , at time: %d", $signed(ref_res), $signed(dout[15:0]),$time);
      if((s_ref_res1 != dout) && (c_ref == 1) && (opcode == 1))
        $display("Error Calc 1. Ref Res: %d, dout: %d", $signed(ref_res), $signed(dout[15:0]));
      if(overflow_ref != overflow)
        $display("ERROR: overflow = %d, ovf = %d",overflow, overflow_ref);
      if(carry_ref != carry)
        $display("ERROR: carry = %d, carry_ref = %d, at time: %d",carry, carry_ref,$time);
      if(negative_ref != negative)
        $display("ERROR: negative = %d, negative_ref = %d , at time: %d",negative, negative_ref,$time);
      if(zero_ref != zero)
        $display("ERROR: zero = %d, zero_ref = %d , at time: %d" ,zero, zero_ref,$time);
    end
    for(i=0;i<(1000000);i=i+1) begin
      if($random & 25 == 0)
        op1_reg <= op2_reg;
      else if($random % 25 == 0) begin 
        op1_reg <= 0;
        op2_reg <= $random;
      end else if(($random % 25) == 0) begin
        op1_reg <= op2_reg; //make them equal sometimes
      end else if(($random % 10) == 0) begin
        op1_reg <= $random % 50;
        op2_reg <= $random % 50;
      end else begin
        op1_reg <= $random;
        op2_reg <= $random;
      end
      opcode_reg <= $random;
      if(($random % 25) == 0) begin
        immediate_reg <= $random;
      end else begin
        immediate_reg <= $random % 16;
      end
      reset <= (($random % 100) == 0) ? 1'b1 : 1'b0; //rare to have reset
      if(rst_n == 1'b1) begin
          // $display("\n");
          // $display("Instruction Number:%d", i);
          // $display("opcode:%d,Op1:%d,Op2:%d,Ioffset:%d,Result:%d",opcode_d,op1_reg_d,op2_reg_d,io_d,dout);
          // $display("Signed: Op1:%d,Op2:%d,Ioffset:%d,Result:%d",$signed(op1_reg_d),$signed(op2_reg_d),$signed(io_d),$signed(dout));
          // $display("V:%d,C:%d,N:%d,Z:%d", overflow,carry,negative,zero);
          // $display("TB: %d", ref_res);
          // $display("Sgined TB: %d", $signed(ref_res[15:0]));
          
          if(($signed(ref_res[15:0]) != $signed(dout)) && (v_ref_d == 0)) //singed calculation should be correct if currently no overflow 
            $display("Error Calc 0. Ref Res: %d, dout: %d , at time: %d", $signed(ref_res[15:0]), $signed(dout[15:0]),$time);
          
          if((s_ref_res1_d != dout) && (c_ref_d == 0) && (opcode_d == 0))  //if carry not set unsigned addition should be correct
            $display("Error Calc 4. Ref Res: %d, dout: %d, at time: %d", s_ref_res1_d, dout[15:0],$time);

          if((s_ref_res1_d != dout) && (c_ref_d == 1) && (opcode_d == 1)) //if borrow not set and subtraction was done then result should be correct 
            $display("Error Calc 1. Ref Res: %d, dout: %d, at time: %d", s_ref_res1_d, dout[15:0],$time);

          if(($signed(ref_res1_d) == $signed(dout)) && (v_ref_d == 1) && (c_ref_d == 0) && (opcode_d == 1)) //if overflow set and borrow not set then signed subtraction should be incorrect
            $display("Error Calc 2. Ref Res: %d, dout: %d, at time: %d",  $signed(ref_res1_d), $signed(dout[15:0]),$time);

          if((s_ref_res1_d == dout) && (v_ref_d == 1) && (c_ref_d == 0) && (opcode_d == 1)) //if overflow and borrow signed and unsigned subtraction should be incorrect
            $display("Error Calc 3. Ref Res: %d, dout: %d, at time: %d",  s_ref_res1_d, dout[15:0],$time);


          //check that signed is wrong with both set
          if(($signed(ref_res1_d) == $signed(dout)) && (v_ref_d == 1) && (c_ref_d == 1) && (opcode_d == 0)) //if carry and overflow then add should be wrong 
            $display("Error Calc 5. Ref Res: %d, dout: %d, at time: %d",  ref_res1_d, dout[15:0],$time);

          //check that unsigned is wrong with both set
          if($signed(op1_reg_d)>=$signed(op2_reg_d) && ((opcode_d == 1) || (opcode_d == 11))) //check GE condition is true
            if(negative != overflow)
              $display("GE error. Ref Res: %d, dout: %d, at time: %d",  $signed(op1_reg_d), $signed(op2_reg_d),$time);

          if($signed(op1_reg_d)<$signed(op2_reg_d) && ((opcode_d == 1) || (opcode_d == 11))) //check LT condition is true
            if(negative == overflow)
              $display("LT error. Ref Res: %d, dout: %d, at time: %d",  $signed(op1_reg_d), $signed(op2_reg_d),$time);

          if(overflow_ref != overflow)
            $display("ERROR: overflow = %d, ovf = %d, time %d",overflow, overflow_ref,$time); //check overflow always matches

          if(carry_ref != carry)
            $display("ERROR: carry = %d, carry_ref = %d, at time: %d",carry, carry_ref,$time); //check carry always matches

          if(negative_ref != negative) //check negative always matches
            $display("ERROR: negative = %d, negative_ref = %d , at time: %d",negative, negative_ref,$time);

          if(zero_ref != zero) //check zero always matches
            $display("ERROR: zero = %d, zero_ref = %d , at time: %d" ,zero, zero_ref,$time);

      end else begin
        if(dout != 0) begin  //check dout is zero while reset is low
          $display("ERROR at Reset: dout = %d, at time: %d" ,dout,$time);
        end
      end
      #20;
    end
  end

  always begin
    #10
    clk_10 = ~clk_10;
  end

  assign op1 = op1_reg;
  assign op2 = op2_reg;
  assign immediate_offset = immediate_reg;
  assign opcode = opcode_reg;
  
  simple_proc_alu alu(
      .clk    (clk),
      .rst_n  (rst_n),
      .opcode (opcode),
      .immediate_offset(immediate_offset),
      .operand_1(op1),
      .operand_2(op2),
      .result(dout),
      .overflow(overflow),
      .carry(carry),
      .negative(negative),
      .zero(zero)
    );

endmodule
