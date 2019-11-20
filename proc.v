    //This will take input data and process it
//
//
`default_nettype none
module simple_proc_data_proc(
 input wire         clk,
 input wire         rst_n,
 input wire         start,
 input wire [15:0]  data_in,
 input wire         data_vld,
 output wire [15:0] result, //output the updated reg
 output wire        zero,
 output wire         negative,
 output wire         overflow,
 output wire        carry,
 output wire         store_loaded_val,
 output wire [9:0]   pc, //this is addr to program ram
 output wire         ram_read_en); //this is program read en
  //State machine control
  localparam idle_fsm = 2'b0,
   fetch_fsm = 2'd1,
   load_reg_fsm = 2'd2,
   alu_fsm = 2'd3;
   //writeback_fsm = 4'd4;
  reg [1:0]         next_state;
  reg [1:0]         current_state;
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
  //pc counter control
  //alu control
  wire condition_code_success;
  wire [15:0] alu_result_out;

 always@(posedge clk or negedge rst_n) begin
   if(rst_n == 1'b0) begin
     current_state <= idle_fsm;
   end else begin
     current_state <= next_state;
   end
 end

always@(*) begin
  case(current_state)
  idle_fsm : begin //Idle state start here then move to fetch when start
  //Will move to here if a reset is done
    if(start == 1'b1) begin
      next_state = fetch_fsm;
    end else begin
      next_state = idle_fsm;
    end
  end
  fetch_fsm : begin
    //This state loads from the program RAM outside of the CPU
    next_state = load_reg_fsm;
  end
  load_reg_fsm : begin
    //load regs and check if condition code succeeds to do calc also decode
    if (condition_code_success == 1'b1) begin
        next_state = alu_fsm;
      end else begin
        next_state = fetch_fsm;
      end
    //end
  end
  alu_fsm : begin
    //Calculation is done
    next_state = fetch_fsm;
  end
  endcase
end

  program_counter #(.MAX_COUNT (1024),
                    .INCREMENT_FSM (load_reg_fsm),
                    .RE_EN_FSM (fetch_fsm))
  pc_127(
                    .clk (clk),
                    .rst_n (rst_n),
                    .state (current_state),
                    .pc_counter_re_en(ram_read_en),
                    .pc_out (pc));

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
                .ram_wr_en(write_ram_en));

  ram_rw_16x128 ram_rw(
    .clk (clk),
    .rst_n (rst_n),
    .read_en (read_ram_en),
    .write_en (write_ram_en),
    .addr     (rd0_data_out[6:0]),
    .dout     (ram_dout),
    .din      (rd1_data_out)
   );

  decode_inputs input_decoder(
    .clk (clk),
    .rst_n (rst_n),
    .data_in(data_in),
    .zero(zero),
    .negative(negative),
    .overflow(overflow),
    .condition_code(condition_code),
    .opcode(opcode),
    .dest_reg(dest_reg),
    .operand1(operand1),
    .operand2(operand2),
    .load_bits(load_bits),
    .cond_code_success(condition_code_success));

  assign wr_en = (current_state == fetch_fsm) ? write_back : 1'b0; //Write back only high if opcode assigns a value to dest_reg
  //assign rd_en = (current_state == load_reg_fsm) ? 1'b1 : 1'b0;
  assign wr0_data_in = (opcode == 4'b1101) ? ram_dout : alu_result_out[15:0]; //If load then put ram in reg file else put alu_result in reg file
  // file read in second pipeline stage and written in fifth
  reg_file_8x16 reg_file_8x16_1 (
      .clk (clk),
      .rst_n (rst_n),
      .wr_en (wr_en),
      //.rd_en (rd_en),
      .rd0_addr(operand1),
      .rd1_addr(operand2),
      .wr0_addr(dest_reg),
      .wr0_data(wr0_data_in),
      .rd0_data(rd0_data_out),
      .rd1_data(rd1_data_out));

//combinational decoder here
  simple_proc_alu alu(
      .clk    (clk),
      .rst_n  (rst_n),
      .opcode (opcode),
      .condition_success (condition_code_success),
      .immediate_offset(load_bits),
      .operand_1(rd0_data_out),
      .operand_2(rd1_data_out),
      //.result_vld(alu_result_vld),
      .result(alu_result_out),
      .overflow(overflow),
      .carry(carry),
      .negative(negative),
      .zero(zero)
    );
    //CPU
    assign result = wr0_data_in;
endmodule
