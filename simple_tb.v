module simple_tb();

  integer     i;
  //clk stuff
  reg         clk_10;
  wire        clk;
  reg         reset;
  //RAM
  reg         start_reg;
  reg  [4:0]  addr_reg;
  wire [4:0]  addr_in;
  wire        re_en;
  wire        wr_en;
  wire        ram_read_en0; //this is program read en
  wire        ram_read_en1;
  wire        ram_write_en1;
  wire 			  ram_write_en0;
  reg         read_en_reg;
  reg         write_en_reg;
  reg  [15:0] data_in_reg;
  wire [15:0] ram_dout;
  wire [15:0] ram_din0;
  wire [15:0] ram_out1;
  wire [15:0] ram_din1;
  wire [15:0] data_in0;
  wire [15:0] data_out1;
  wire [6:0]  pc; //this is addr to program ram
  wire [6:0] ram_addr1;
  wire [15:0] result; //output the updated reg
  wire        start;
  wire        zero;
  wire        negative;
  wire        overflow;
  wire        carry;
  wire        rst_n;
  //Clk assign 
  assign clk = clk_10;
  assign rst_n = ~reset;

  initial begin
    //$dumpfile("hw2_q7.vcd");
    //$dumpvars(3, hw2_q7_tb);
    //initial values
    clk_10 <= 0;
    data_in_reg <= 0;
    reset <= 1;
    addr_reg <= 0;
    read_en_reg <= 0;
    write_en_reg <= 0;
    #10;
    reset <= 0;
    #20;
    $readmemb("data_test2.txt", program_ram.ram_data);
    #20;
    //set wr_en to 1 and start for loop to load values
    start_reg <= 1;
    data_in_reg <= 0;
    write_en_reg <= 1;
    for(i = 0; i < 64000000; i=i+1) begin
      if (pc == 10'd10) begin
        #20
        $writememh("ram_file.txt", program_ram.ram_data);
        //$writememh("reg_file.txt", proc.reg_file_8x16_1.reg_file);
        $display("[%d,%d,%d,%d,%d,%d,%d,%d]", proc.reg_file_8x16_1.r0, proc.reg_file_8x16_1.r1,proc.reg_file_8x16_1.r2,proc.reg_file_8x16_1.r3,proc.reg_file_8x16_1.r4,proc.reg_file_8x16_1.r5,proc.reg_file_8x16_1.r6, proc.reg_file_8x16_1.r7);
        $finish;
      end
      #20;
    end
  end

  always begin
    #20
    $display("Time:%d | Din: %b ",$time,ram_din0);
    $display("Time:%d | c:%d, v:%d, z:%d, n:%d:",$time,proc.carry, proc.overflow,proc.zero,proc.negative);
  end
  initial begin
    $monitor("Time:%d | R0 to R7 [%d,%d,%d,%d,%d,%d,%d,%d]",$time, proc.reg_file_8x16_1.r0, proc.reg_file_8x16_1.r1,proc.reg_file_8x16_1.r2,proc.reg_file_8x16_1.r3,proc.reg_file_8x16_1.r4,proc.reg_file_8x16_1.r5,proc.reg_file_8x16_1.r6, proc.reg_file_8x16_1.r7);
  end

  always begin
    #10
    clk_10 = ~clk_10;
  end

  // ram_rw_16x1024 program_ram(
  ram_rw_2p_16x128 program_ram(
    .clk (clk),
    .read_en0(ram_read_en0),
    .read_en1(ram_read_en1),
    .write_en0(1'b0),
    .write_en1(ram_write_en1),
    .addr0(pc),
    .addr1(ram_addr1[6:0]),
    .din0(16'b0),
    .din1(ram_din1),
    .dout0(ram_din0),
    .dout1(data_out1)

);

  assign addr_in = addr_reg;
  assign re_en = read_en_reg;
  assign wr_en = write_en_reg;
  assign data_in = ram_dout;
  assign start = start_reg;
  
  proc proc(
    .clk (clk),
    .rst_n (rst_n),
    .start (start),
    .data_in(ram_din0), //program data in
    .data_ram_dout(data_out1), //data data out
    .result(result),
    .zero(zero),
    .negative(negative),
    .overflow(overflow),
    .carry(carry),
    .pc(pc), //prog addr
    .prog_ram_read_en(ram_read_en0), //prog re en
    .data_ram_read_en(ram_read_en1), //data re en
    .write_ram_en(ram_write_en1), //data write enable
    .data_ram_din(ram_din1), //data din
    .data_ram_addr(ram_addr1) //data addr
  );
endmodule
