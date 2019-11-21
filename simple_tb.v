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
  wire        ram_read_en; //this is program read en
  reg         read_en_reg;
  reg         write_en_reg;
  reg  [15:0] data_in_reg;
  wire [15:0] ram_dout;
  wire [15:0] data_in;
  wire [6:0]  pc; //this is addr to program ram
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
    $readmemh("data.txt", program_ram.ram_data);

    clk_10 <= 0;
    data_in_reg <= 0;
    reset <= 1;
    addr_reg <= 0;
    read_en_reg <= 0;
    write_en_reg <= 0;
    #10
    //set wr_en to 1 and start for loop to load values
    start_reg <= 1;
    reset <= 0;
    data_in_reg <= 0;
    write_en_reg <= 1;
    for(i = 0; i < 64000000; i=i+1) begin
      $display(" %b ",data_in);
      $display("c:%d",carry);
      $display("v:%d",overflow);
      $display("z:%d",zero);
      $display("n:%d",negative);
      $display("[%d,%d,%d,%d,%d,%d,%d,%d]", proc.reg_file_8x16_1.r0, proc.reg_file_8x16_1.r1,proc.reg_file_8x16_1.r2,proc.reg_file_8x16_1.r3,proc.reg_file_8x16_1.r4,proc.reg_file_8x16_1.r5,proc.reg_file_8x16_1.r6, proc.reg_file_8x16_1.r7);
      if (ram_dout == 16'h3c00) begin
        #60;
        $writememh("ram_file.txt", proc.ram_rw.ram_data);
        //$writememh("reg_file.txt", proc.reg_file_8x16_1.reg_file);
        $display("[%d,%d,%d,%d,%d,%d,%d,%d]", proc.reg_file_8x16_1.r0, proc.reg_file_8x16_1.r1,proc.reg_file_8x16_1.r2,proc.reg_file_8x16_1.r3,proc.reg_file_8x16_1.r4,proc.reg_file_8x16_1.r5,proc.reg_file_8x16_1.r6, proc.reg_file_8x16_1.r7);
        $finish;
      end
      #20;
    end
  end

  always begin
    #10
    clk_10 = ~clk_10;
  end

  // ram_rw_16x1024 program_ram(
  ram_rw_16x128 program_ram(
    .clk (clk),
    .rst_n (rst_n),
    .read_en(ram_read_en),
    .write_en(1'b0),
    .addr(pc),
    .dout(ram_dout),
    .din(16'b0)
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
    .data_in(data_in),
    .result(result),
    .zero(zero),
    .negative(negative),
    .overflow(overflow),
    .carry(carry),
    .pc(pc),
    .ram_read_en(ram_read_en)
  );
endmodule
