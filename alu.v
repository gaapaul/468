//This will do math and
`default_nettype none
module simple_proc_alu(
  input wire         clk,
  input wire         rst_n,
  input wire  [3 :0] opcode,
  input wire  [15:0] operand_1,
  input wire  [15:0] operand_2,
  input wire  [6 :0] immediate_offset,
  output wire [15:0] result,
  output wire        overflow,
  output wire        carry,
  output wire        negative,
  output wire        zero);

  reg [15:0]     result_out;
  wire [15:0]     dout;
  //adder wire 
  wire[15:0]     add_res;
  wire           add_v;
  wire           add_c;
  //sub wire
  wire[15:0]     sub_res;
  wire           sub_v;
  wire           sub_c;
  //mult wire
  wire[15:0]     mul_res;
  wire           mul_v;
  wire[15:0]     orr_res,and_res,eor_res,mov_res,movn_res,lsr_res,lsl_res,ror_res;
  reg            n_reg;
  reg            z_reg;
  reg            v_reg;
  reg            c_reg;
  wire            update_flag_reg;
  wire            update_cv;
  wire           ovf;
  wire            neg;
  wire            c;
  wire            z;
  //0000
  alu_adder adder( 
    .operand1 (operand_1),
    .operand2 (operand_2),
    .dout(add_res),
    .ovf(add_v),
    .carry(add_c));
  //0001
  alu_sub subtractor( 
    .operand1 (operand_1),
    .operand2 (operand_2),
    .dout(sub_res),
    .ovf(sub_v),
    .carry(sub_c));
  //
  alu_mul mult( 
    .operand1 (operand_1),
    .operand2 (operand_2),
    .dout(mul_res));
    
  alu_orr orr(
    .operand1 (operand_1),
    .operand2 (operand_2),
    .dout(orr_res));
    
  alu_and alu_and(
    .operand1 (operand_1),
    .operand2 (operand_2),
    .dout(and_res));
    
  alu_eor eor(
    .operand1 (operand_1),
    .operand2 (operand_2),
    .dout(eor_res));
    
  alu_movn movn(
    .immediate_offset(immediate_offset),
    .dout(movn_res));
    
  alu_mov mov(
    .operand1 (operand_1),
    .dout(mov_res));
    
  alu_lsr lsr(
    .operand1 (operand_1),
    .immediate_offset(immediate_offset[3:0]),
    .dout(lsr_res));
    
  alu_lsl lsl(
    .operand1 (operand_1),
    .immediate_offset(immediate_offset[3:0]),
    .dout(lsl_res));
    
  alu_ror ror(
    .operand1 (operand_1),
    .immediate_offset(immediate_offset[3:0]),
    .dout(ror_res));

  mux mux16(
    .sel (opcode),
    .in0 (add_res), //add, 0000
    .in1 (sub_res), //sub, 0001
    .in2 (mul_res), //mul, 0010
    .in3 (orr_res), //orr, 0011
    .in4 (and_res), //and, 0100
    .in5 (eor_res), //eor, 0101
    .in6 (movn_res), //mov, 0110
    .in7 (mov_res), //movn,0111
    .in8 (lsr_res), //lsr,
    .in9(lsl_res),  //lsl
    .in10(ror_res), //ror
    .in11(sub_res),   //cmp
    .in12(movn_res), //adr
    .in13(16'b0),   //ldr
    .in14(16'b0),   //str
    .in15(16'b0),   //nop
    .out (dout));
    
    //takes opcode, result and calculated flags
    //outpus correct flag and if it should update
    //outputs if result should update
  flag_sel flag_sel(
   .opcode(opcode),
   .result(dout),
   .ovf_add (add_v),
   .c_add (add_c),
   .ovf_sub (sub_v),
   .c_sub (sub_c),
   .update_flag_reg (update_flag_reg),
   .update_cv (update_cv),
   .ovf (ovf),
   .neg (neg),
   .carry (c), 
   .zero (z));
  /*
  always@(*) begin
    if((condition_code == 2'b00) || //no condition
    (condition_code == 2'b01 && zero == 1'b1) || //equal
    (condition_code == 2'b10 && (negative == overflow)) || //greater or equal
    (condition_code == 2'b11 && (negative != overflow))) begin //less than
    //do calc
      //condition_code_success = 1'b1;
    end else begin
      //dont do 
      //condition_code_success = 1'b0;
    end
  end
  */
  always @(posedge clk or negedge rst_n) begin //flop output
    if(rst_n == 1'b0) begin
      v_reg <= 1'b0;
      c_reg <= 1'b0;
      z_reg <= 1'b0;
      n_reg <= 1'b0;
      result_out <= 16'b0;
    end else begin
      //update nczv flags
      if(update_flag_reg == 1'b1) begin
        n_reg <= neg;
        z_reg <= z;
        if(update_cv == 1'b1) begin
          v_reg <= ovf;
          c_reg <= c;
        end
      end
      //flop output
      if((opcode == 4'd11)) begin //&& (condition_code_success == 1'b0)) begin
        result_out <= 1'b0;
      end else begin
        result_out <= dout;
      end  
    end
  end

  assign carry = c_reg;
  assign overflow = v_reg;
  assign zero = z_reg;
  assign negative= n_reg;
  assign result = result_out;
  //assign result_vld = alu_result_vld;

endmodule
