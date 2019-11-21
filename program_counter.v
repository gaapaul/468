module program_counter #(parameter MAX_COUNT = 4, parameter INCREMENT_FSM = 2, parameter RE_EN_FSM = 1) (
  input        clk,
  input        rst_n,
  input  [1:0] state,
  output wire  pc_counter_re_en,
  output wire [6:0] pc_out);

  reg [6:0]  pc_counter_addr;

  always@(posedge clk or negedge rst_n) begin : pc_counter_control
    if(rst_n == 1'b0) begin
      pc_counter_addr <= 7'b0;
    end else begin : normal_logic
      if(pc_counter_addr < MAX_COUNT) begin
        if(state == INCREMENT_FSM) begin
          pc_counter_addr <= pc_counter_addr + 1'b1;
        end
      end else begin
        pc_counter_addr <= pc_counter_addr;
      end
    end
  end // block: pc_counter_control
  assign pc_counter_re_en = (state == RE_EN_FSM) ? 1'b1 : 1'b0;
  assign pc_out = pc_counter_addr;
endmodule
