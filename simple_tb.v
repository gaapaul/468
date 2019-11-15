module simple_tb();

  integer i;
  reg     clk_10;
  wire    clk;
  wire [4:0] addr_in;
  reg [4:0]  addr_reg;
  wire [7:0] dout;
  wire [7:0] din;
  wire       re_en;
  wire wr_en;
 
 
 wire         start;
 reg [15:0]  data_in_reg;
 wire [15:0]  data_in;
 wire [15:0]  ram_dout;
 wire         data_vld;
 wire [15:0] result; //output the updated reg
 wire        zero;
 wire         negative;
 wire         overflow;
 wire        carry;
 wire         store_loaded_val;
 wire [7:0]   pc; //this is addr to program ram
 wire         ram_read_en; //this is program read en
 reg start_reg;
  reg  reset;
  wire rst_n;
  reg read_en_reg;
  reg write_en_reg;
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
      if (ram_dout == 16'h3c00) begin
        #20;
        $writememh("reg_file.txt", proc.reg_file_8x16_1.reg_file);
        $writememh("ram_file.txt", proc.ram_rw.ram_data);
        $finish;
      end
      #20;
    end
  end

  always begin
    #10
    clk_10 = ~clk_10;
  end

  ram_rw_16x1024 program_ram(
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
  
  simple_proc_data_proc proc(
    .clk (clk),
    .rst_n (rst_n),
    .start (start),
    .data_in(data_in),
    .data_vld(1'b1),
    .result(result),
    .zero(zero),
    .negative(negative),
    .overflow(overflow),
    .carry(carry),
    .store_loaded_val(store_loaded_val),
    .pc(pc),
    .ram_read_en(ram_read_en));


endmodule
