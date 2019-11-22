//This will take input data and process it
module proc(
  input wire         clk,
  input wire         rst_n,
  input wire         start,
  input wire  [15:0] data_in,
  output wire [15:0] result, //output the updated reg
  output wire        zero,
  output wire        negative,
  output wire        overflow,
  output wire        carry,
  output wire [6:0]  pc, //this is addr to program ram
  output wire        ram_read_en); //this is program read en
  //State machine control
  localparam idle_fsm = 2'b0,
    fetch_fsm = 2'd1,
    load_reg_fsm = 2'd2,
    alu_fsm = 2'd3;
  wire [1:0] current_state;
  //decode logic
  wire [1:0] condition_code;
  wire [3:0] opcode;
  wire [2:0] dest_reg;
  wire [6:0] load_bits;
  wire [2:0] operand1;
  wire [2:0] operand2;
  //ram control
  wire write_back;
  wire read_ram_en;
  wire write_ram_en;
  wire [15:0] ram_dout;
  //Reg file control
  wire wr_en;
  wire [15:0] rd0_data_out;
  wire [15:0] rd1_data_out;
  wire [15:0] wr0_data_in;
  //alu control
  wire condition_code_success;
  wire [15:0] alu_result_out;

  fsm #(.IDLE_STATE(idle_fsm),
    .FETCH_STATE(fetch_fsm),
    .LOAD_REG_STATE(load_reg_fsm),
    .ALU_STATE(alu_fsm))
  fsm_state(
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .condition_code_check(condition_code_success),
    .curr_state(current_state)
  );

  program_counter #(.MAX_COUNT (127),
    .INCREMENT_FSM (load_reg_fsm),
    .RE_EN_FSM (fetch_fsm))
  pc_127(
    .clk (clk),
    .rst_n (rst_n),
    .state (current_state),
    .pc_counter_re_en(ram_read_en),
    .pc_out (pc)
  );

  ram_control #(.CALC_VALID_STATE(alu_fsm),
    .REG_VALID_STATE(load_reg_fsm))
  ram_control_1(
    .clk(clk),
    .rst_n(rst_n),
    .opcode(opcode),
    .state(current_state),
    .condition_code_check(condition_code_success),
    .write_back_to_reg(write_back),
    .ram_re_en(read_ram_en),
    .ram_wr_en(write_ram_en)
  );

  ram_rw_16x128 ram_rw(
    .clk (clk),
    .rst_n (rst_n),
    .read_en (read_ram_en),
    .write_en (write_ram_en),
    .addr     (rd0_data_out[6:0]),
    .dout     (ram_dout),
    .din      (rd1_data_out)
  );

  decoding input_decoder(
    .instruction(data_in),
    .zero(zero),
    .neg(negative),
    .ovf(overflow),
    .cond(condition_code),
    .opcode(opcode),
    .dest_reg(dest_reg),
    .source_reg1(operand1),
    .source_reg2(operand2),
    .load_shift(load_bits),
    .condition_code_success(condition_code_success)
  );

  //Write back only high if opcode assigns a value to dest_reg
  assign wr_en = (current_state == fetch_fsm) ? write_back : 1'b0; 
  //If load then put ram in reg file else put alu_result in reg file
  assign wr0_data_in = (opcode == 4'b1101) ? ram_dout : alu_result_out[15:0]; 
  //assign rd_en = (current_state == load_reg_fsm) ? 1'b1 : 1'b0;
  reg_file_8x16 reg_file_8x16_1 (
    .clk (clk),
    .rst_n (rst_n),
    .wr_en (wr_en),
    .rd0_addr(operand1),
    .rd1_addr(operand2),
    .wr0_addr(dest_reg),
    .wr0_data(wr0_data_in),
    .rd0_data(rd0_data_out),
    .rd1_data(rd1_data_out)
  );

  simple_proc_alu alu(
    .clk    (clk),
    .rst_n  (rst_n),
    .opcode (opcode),
    .condition_success (condition_code_success),
    .immediate_offset(load_bits),
    .operand_1(rd0_data_out),
    .operand_2(rd1_data_out),
    .result(alu_result_out),
    .overflow(overflow),
    .carry(carry),
    .negative(negative),
    .zero(zero)
  );
  //CPU
  assign result = wr0_data_in;
endmodule
