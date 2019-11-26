module memory_tb();
  integer i;
  reg clk, rst;
  reg read_en, write_en;
  reg [6:0] address;
  reg [15:0] din;
  reg [15:0] dout_reg;
  wire [15:0] dout; 

  initial begin
    clk <= 1;
    rst <= 0;
    address <= 0;
    read_en <= 0;
    write_en <= 0;
    #15;
    rst <= 1;
    #10;
    $display($time, " RAM");
    $readmemb("instructions.txt", program_ram.ram_data);
    #10;
    read_en <= 1;
    for(i=0; i<10; i = i+1) begin
      address <= i;
      dout_reg <= program_ram.ram_data[address];
      #10;
    end
  end

  always #5 clk <= ~clk;

  always begin
    #20
    //$monitor($time, " Reset = %d, Read_En = %d, Write_En = %d, Address = %d, Instruction = %b", rst, read_en, write_en, address, dout);
    $display($time, " Reset = %d, Read_En = %d, Write_En = %d, Address = %d, Instruction = %b", rst, read_en, write_en, address, dout);
  end

  ram_rw_16x128 program_ram(
    .clk(clk),
    .rst_n(rst),
    .read_en(read_en),
    .write_en(write_en),
    .addr(address),
    .din(din),
    .dout(dout));

endmodule
