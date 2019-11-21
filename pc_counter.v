module (parameter MAX_COUNT = 4) pc_counter(
	input clk, 
	input rst, 
	input state,
	output pc_counter_re_en,
	output [7:0] pc);
	
reg pc_counter_addr;

always@(posedge clk or negedge rst_n) begin : pc_counter_control 
      if(rst_n == 1'b0) begin
        pc_counter_addr <= 8'b0;
      end else begin : normal_logic
        if(pc_counter_addr < MAX_COUNT) begin
			if(state == load_reg_fsm) begin
			  pc_counter_addr <= pc_counter_addr + 1'b1;
			end
		end else begin
			pc_counter_addr <= pc_counter_addr;
		end
  end // block: pc_counter_control

assign pc_counter_re_en = (state == fetch_fsm) ? 1'b1 : 1'b0;
assign pc = pc_counter_addr;