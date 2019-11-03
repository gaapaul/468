module flag_sel(
  input wire [3:0] opcode,
  input wire [15:0] result,
  //input wire [1:0] condition_code,
  input wire ovf_add,
  input wire c_add,
  input wire ovf_sub,
  input wire c_sub,
  //input wire ovf_mul,
  output wire update_cv,
  output wire update_flag_reg,
  //output wire condition_code_success,
  output wire ovf,
  output wire neg,
  output wire carry,
  output wire zero);
  
  reg ovf_reg;
  reg c_reg;
  assign update_flag_reg = (opcode == 4'd0 || opcode == 4'd1 || opcode == 4'd2 || opcode == 4'd11) ? 1'b1 : 1'b0;
  assign update_cv = (opcode == 4'd0 || opcode == 4'd1 || opcode == 4'd11) ? 1'b1 : 1'b0;
  always @(*) begin
      if(opcode == 4'd0) begin
        ovf_reg = ovf_add;
        c_reg = c_add;
      end else if(opcode == 4'd1 || opcode == 4'd11) begin
        ovf_reg = ovf_sub;
        c_reg = c_sub;
      end else begin //mul doesn't update c and v
        ovf_reg = 1'b0;
        c_reg = 1'b0;
      end 
  end  
  /*  
  always@(*) begin
    if((condition_code == 2'b00) || //no condition
    (condition_code == 2'b01 && zero == 1'b1) || //equal
    (condition_code == 2'b10 && (negative == overflow)) || //greater or equal
    (condition_code == 2'b11 && (negative != overflow))) begin //less than
    //do calc
      condition_code_success = 1'b1;
    end else begin
      //dont do 
      condition_code_success = 1'b0;
    end
  end
  */
  assign ovf = ovf_reg;
  assign carry = c_reg;
  assign neg = result[15];
  assign zero = (result == 16'b0) ? 1'b1 : 1'b0;
  
  endmodule 
  
  
