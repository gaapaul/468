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
 output wire [7:0]   pc, //this is addr to program ram
 output wire         ram_read_en); //this is program read en
  //State machine control 
  localparam idle_fsm = 4'b0,
   fetch_fsm = 4'd1,
   load_reg_fsm = 4'd2,
   alu_fsm = 4'd3,
   writeback_fsm = 4'd4;
  reg [3:0]         next_state;
  reg [3:0]         current_state;
  //decode logic 
  wire [1:0] condition_code;
  wire [3:0] opcode;
  wire [2:0] dest_reg; 
  wire [6:0] load_bits;
  wire [2:0] operand1;
  wire [2:0] operand2;
  //ram control 
  reg load_or_write;
  reg write_back;
  reg  ctrl_ram_read_en;
  reg  ctrl_ram_write_en;
  wire read_ram_en; 
  wire write_ram_en;
  wire [15:0] ram_dout;
  //Reg file control 
  wire wr_en;
  wire rd_en;
  wire [15:0] rd0_data_out;
  wire [15:0] rd1_data_out;
  wire [15:0] wr0_data_in;
  //pc counter control 
  reg pc_counter_re_en;
  reg [7:0] pc_counter_addr;
  //alu control 
  reg [15:0] alu_result_out_reg;
  reg  condition_code_success;
  reg alu_result_vld;
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
  fetch_fsm : begin //fetch data and when data is valid move to decode
    //This state loads from the program RAM outside of the CPU
    //It gives us a new 16 bit instruction
    //Comb Logic decodes this 16 bit to start reg access
    //registers are kinda written back to in this step as they are not needed till load reg
    if(ram_read_en == 1'b1) begin
      next_state = load_reg_fsm;
    end else begin
      next_state = fetch_fsm;
    end
  end // case: fetch_fsm
  load_reg_fsm : begin //load regs from regfile and gets them to pass to alu
    //This state loads two regs from the regfile
    //It will either move to alu state if opcode is math
    //Or it will prep a WB if operation is load or store
    //Mux happens combinationally by the end of this state
    //IF the condition code fails next state is fetch, and nothing shall be written to reg file or RAM
    if(load_or_write == 1'b1) begin
      if (condition_code_success == 1'b1) begin
        next_state = writeback_fsm;
      end else begin
        next_state = fetch_fsm;
      end
    end else begin
      if (condition_code_success == 1'b1) begin
        next_state = alu_fsm;
      end else begin
        next_state = fetch_fsm;
      end
    end
  end
  alu_fsm : begin
    //Calculation is done
    if(alu_result_vld == 1'b1) begin
      next_state = fetch_fsm;
    end else begin
      next_state = alu_fsm;
    end
  end
  writeback_fsm : begin
    //ctrl_ram_read_en or ctrl_ram_write_en is used in this stage to read or write to memory
    //address should be ready and values should be from decode logic
    next_state = fetch_fsm;
  end
  endcase
end

  assign ram_read_en = (current_state == fetch_fsm) ? 1'b1 : 1'b0;
  always @(posedge clk or negedge rst_n) begin : pc_counter_control
      if(rst_n == 1'b0) begin
        pc_counter_addr <= 8'b0;
        pc_counter_re_en <= 1'b0;
      end else begin : normal_logic
        if(current_state == load_reg_fsm) begin
          pc_counter_addr <= pc_counter_addr + 1'b1;
        end
      end
  end // block: pc_counter_control
    
  always @(posedge clk or negedge rst_n) begin : ram_control
    if(rst_n == 1'b0) begin
      load_or_write <= 1'b0;
      write_back <= 1'b0;
      ctrl_ram_read_en <= 1'b0;
      ctrl_ram_write_en <= 1'b0;
    end else begin
      //Reg file control 
      if((opcode == 4'b1011) || (opcode == 4'b1110) || (opcode == 4'b1111)) begin
      //Don't Write to reg file if is CMP,STR,NOP
        write_back <= 1'b0;
      end else if((alu_result_vld == 1'b1 || opcode == 4'b1101) && (condition_code_success == 1'b1)) begin 
      //Only write to reg file if condition code pass and not cmp and not first time getting a calculation 
        write_back <= 1'b1;
      end else begin
      //Default not writing 
        write_back <= 1'b0;  
      end
      //Ram control 
      if((opcode == 4'b1101) && (current_state == load_reg_fsm)) begin
        //If it is a Load we read from RAM
        ctrl_ram_read_en <= 1'b1;
      end else begin
        ctrl_ram_read_en <= 1'b0;
      end
      if((opcode == 4'b1110) && (current_state == load_reg_fsm)) begin
        //If it is a Store we write to RAM 
        ctrl_ram_write_en <= 1'b1;
      end else begin
        ctrl_ram_write_en <= 1'b0;
      end
      //State machine control 
      if((opcode == 4'b1101) || (opcode == 4'b1110)) begin
        load_or_write <= 1'b1;
      end else begin
        load_or_write <= 1'b0;
      end

    end
  end // block: ram_control
 
  always @(posedge clk or negedge rst_n) begin : alu_control
    if(rst_n == 1'b0) begin
      alu_result_vld <= 1'b0;
    end else begin
      if(current_state == alu_fsm) begin
        //If we get to this state means we can start writing back to reg file
        alu_result_vld <= 1'b1;
      end
    end
  end // block: alu_control

  //decode data here
  //MOVE TO MODULE 
  assign condition_code = data_in[15:14];
  assign opcode = data_in[13:10];
  assign dest_reg = data_in[9:7];
  assign load_bits = data_in[6:0];
  assign operand1 = data_in[6:4];
  assign operand2 = (opcode == 4'b1110) ? data_in[9:7] : data_in[3:1];
  //FLAG logic 
  always@(*) begin
    if((condition_code == 2'b00) || //no condition
    (condition_code == 2'b01 && zero == 1'b1) || //equal
    (condition_code == 2'b10 && (negative == overflow)) || //greater or equal
    (condition_code == 2'b11 && (negative != overflow))) begin //less than
    //do calc       condition_code_success= 1'b1;
    end else begin
      //dont do 
      condition_code_success = 1'b0;
    end
  end
  
  //assign rd0_data_out = rd0_data_out;
  assign read_ram_en = ctrl_ram_read_en;
  assign write_ram_en = ctrl_ram_write_en;
  ram_rw_16x128 ram_rw(
    .clk (clk),
    .rst_n (rst_n),
    .read_en (read_ram_en),
    .write_en (write_ram_en),
    .addr     (rd0_data_out[6:0]),
    .dout     (ram_dout),
    .din      (rd1_data_out)
   );

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
    
    //CPU outputs
    assign pc = pc_counter_addr;
    assign result = wr0_data_in;
endmodule