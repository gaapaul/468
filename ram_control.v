module ram_control #(parameter CALC_VALID_STATE = 0, parameter REG_VALID_STATE = 0) (
 input       clk,
 input       rst_n,
 input [3:0] opcode,
 input [1:0] state,
 input       condition_code_check,
 output      write_back_to_reg,
 output      ram_re_en,
 output      ram_wr_en);

  reg   write_back, ctrl_ram_read_en, ctrl_ram_write_en;
  reg 	alu_result_vld;
  always @(posedge clk or negedge rst_n) begin : ram_control
    if(rst_n == 1'b0) begin
      write_back <= 1'b0;
      ctrl_ram_read_en <= 1'b0;
      ctrl_ram_write_en <= 1'b0;
    end else begin
      //Reg file control
      if((opcode == 4'b1011) || (opcode == 4'b1110) || (opcode == 4'b1111)) begin
      //Don't Write to reg file if is CMP,STR,NOP
        write_back <= 1'b0;
      end else if((alu_result_vld == 1'b1 || opcode == 4'b1101) && ((state == CALC_VALID_STATE))) begin
      //ALU calculated value OR ram was read last state now the value can be stored in to reg_file
        write_back <= 1'b1;
      end else begin
      //Default not writing
        write_back <= 1'b0;
      end
      //Ram control
      if((opcode == 4'b1101) && (state == REG_VALID_STATE) && (condition_code_check == 1'b1)) begin
        //Last state was the state when we loaded regs and we can set read en to store it
        ctrl_ram_read_en <= 1'b1;
      end else begin
        ctrl_ram_read_en <= 1'b0;
      end
      if((opcode == 4'b1110) && (state == REG_VALID_STATE) && (condition_code_check == 1'b1)) begin
        //Last state was the state when we loaded regs and we can now set write en to write to it
        ctrl_ram_write_en <= 1'b1;
      end else begin
        ctrl_ram_write_en <= 1'b0;
      end
   end
  end // block: ram_control

  always @(posedge clk or negedge rst_n) begin : alu_control
    if(rst_n == 1'b0) begin
      alu_result_vld <= 1'b0;
    end else begin
      if (state == REG_VALID_STATE) begin
        //If we get to this state means we can start writing back to reg file
        alu_result_vld <= 1'b1;
      end
    end
  end // block: alu_control

  assign write_back_to_reg = write_back;
  assign ram_re_en = ctrl_ram_read_en;
  assign ram_wr_en = ctrl_ram_write_en;
endmodule
