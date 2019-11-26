module fsm_tb();
  integer i;
  reg clk, rst, start, cc_check;
  wire [1:0] result_state;

  initial begin
      $display($time, " Processor FSM");
      clk <= 1;
      rst <= 0;
      #3  rst <= 1;
    end

    always #5 clk <= ~clk;

    initial begin
      #5
      for (i = 0; i < 35; i=i+1) begin
        #10
        $display($time, " State = %d, Condition Code = %d, Start Code = %d, Reset = %d", result_state, cc_check, start, rst);
      end
    end

    initial begin
      start <= 0;
      cc_check <= 1;
      #50;
      start <= 1;
      cc_check <= 0;
      #100;
      cc_check <= 1;
      #100;
      rst <= 0;
    end

  fsm #(.IDLE_STATE(2'd0),
    .FETCH_STATE(2'd1),
    .LOAD_REG_STATE(2'd2),
    .ALU_STATE(2'd3))
  fsm_state(
    .clk(clk),
    .rst_n(rst),
    .start(start),
    .condition_code_check(cc_check),
    .current_state(result_state)
  );
endmodule

/* Simulation Results
#   0 Processor FSM
#  15 State = 0, Condition Code = 1, Start Code = 0, Reset = 1
#  25 State = 0, Condition Code = 1, Start Code = 0, Reset = 1
#  35 State = 0, Condition Code = 1, Start Code = 0, Reset = 1
#  45 State = 0, Condition Code = 1, Start Code = 0, Reset = 1
#  55 State = 0, Condition Code = 0, Start Code = 1, Reset = 1
#  65 State = 1, Condition Code = 0, Start Code = 1, Reset = 1
#  75 State = 2, Condition Code = 0, Start Code = 1, Reset = 1
#  85 State = 1, Condition Code = 0, Start Code = 1, Reset = 1
#  95 State = 2, Condition Code = 0, Start Code = 1, Reset = 1
# 105 State = 1, Condition Code = 0, Start Code = 1, Reset = 1
# 115 State = 2, Condition Code = 0, Start Code = 1, Reset = 1
# 125 State = 1, Condition Code = 0, Start Code = 1, Reset = 1
# 135 State = 2, Condition Code = 0, Start Code = 1, Reset = 1
# 145 State = 1, Condition Code = 0, Start Code = 1, Reset = 1
# 155 State = 2, Condition Code = 1, Start Code = 1, Reset = 1
# 165 State = 3, Condition Code = 1, Start Code = 1, Reset = 1
# 175 State = 1, Condition Code = 1, Start Code = 1, Reset = 1
# 185 State = 2, Condition Code = 1, Start Code = 1, Reset = 1
# 195 State = 3, Condition Code = 1, Start Code = 1, Reset = 1
# 205 State = 1, Condition Code = 1, Start Code = 1, Reset = 1
# 215 State = 2, Condition Code = 1, Start Code = 1, Reset = 1
# 225 State = 3, Condition Code = 1, Start Code = 1, Reset = 1
# 235 State = 1, Condition Code = 1, Start Code = 1, Reset = 1
# 245 State = 2, Condition Code = 1, Start Code = 1, Reset = 1
# 255 State = 0, Condition Code = 1, Start Code = 1, Reset = 0
# 265 State = 0, Condition Code = 1, Start Code = 1, Reset = 0
# 275 State = 0, Condition Code = 1, Start Code = 1, Reset = 0
*/