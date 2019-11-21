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