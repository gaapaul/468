module memory_tb();
  integer i,j;
  reg clk;
  reg read_en, write_en;
  reg [6:0] address;
  reg [15:0] din;
  wire [15:0] dout; 

  initial begin
    clk <= 1;
    address <= 0;
    read_en <= 0;
    write_en <= 0;
    #10;
    $readmemb("instructions.txt", program_ram.ram_data);
    read_en <= 1;
    for(i=0; i<127; i = i+1) begin
      address <= i;
      #10;
    end
  end

  always #5 clk <= ~clk;

  always begin
    #10
    $display($time, ", Read_En = %d, Write_En = %d, Address = %d, Instruction = %b", read_en, write_en, address, dout);
  end

  ram_rw_16x128 program_ram(
    .clk(clk),
    .read_en(read_en),
    .write_en(write_en),
    .addr(address),
    .din(din),
    .dout(dout));

endmodule
/* Simulation Results
#                   10, Read_En = 0, Write_En = 0, Address =   0, Instruction = xxxxxxxxxxxxxxxx
#                   20, Read_En = 1, Write_En = 0, Address =   0, Instruction = 0001100010000100
#                   30, Read_En = 1, Write_En = 0, Address =   1, Instruction = 0001100100000110
#                   40, Read_En = 1, Write_En = 0, Address =   2, Instruction = 0000000110010100
#                   50, Read_En = 1, Write_En = 0, Address =   3, Instruction = 0010011000100010
#                   60, Read_En = 1, Write_En = 0, Address =   4, Instruction = 0000101010010100
#                   70, Read_En = 1, Write_En = 0, Address =   5, Instruction = 0010110001001010
#                   80, Read_En = 1, Write_En = 0, Address =   6, Instruction = 0101101101111111
*/
