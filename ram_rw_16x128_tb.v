module memory_tb();
  integer i,j;
  reg clk, rst;
  reg read_en, write_en;
  reg [6:0] address;
  reg [15:0] din;
  wire [15:0] dout; 

  initial begin
    clk <= 1;
    rst <= 0;
    address <= 0;
    read_en <= 0;
    write_en <= 0;
    #10;
    $readmemb("instructions.txt", program_ram.ram_data);
    rst <= 1;
    read_en <= 1;
    for(i=0; i<127; i = i+1) begin
      address <= i;
      #10;
    end
  end

  always #5 clk <= ~clk;

  always begin
    #10
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
