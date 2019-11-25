//This is the ram for the CPU
module ram_rw_16x128(
  input          clk,
  input          rst_n,
  input          read_en,
  input          write_en, 
  input  [6:0]   addr,
  input  [15:0]  din,
  output [15:0]  dout);

  integer     i;
  reg [15:0]  ram_data [127:0];
  reg [15:0]  ram_dout;
  always @(posedge clk or negedge rst_n) begin
    if (write_en == 1'b1 && read_en == 1'b0) begin
      ram_data[addr] <= din;
    end else if(write_en == 1'b0 && read_en == 1'b1) begin
      ram_dout <= ram_data[addr];
    end
  end // always @ (posedge clk or negedge rst_n)
  assign dout = ram_dout;
endmodule


/* Simulation Results
# 10 Reset = 0, Read_En = 0, Write_En = 0, Address =   0, Instruction = xxxxxxxxxxxxxxxx
# 20 Reset = 1, Read_En = 1, Write_En = 0, Address =   0, Instruction = 0001100010000100
# 30 Reset = 1, Read_En = 1, Write_En = 0, Address =   1, Instruction = 0001100100000110
# 40 Reset = 1, Read_En = 1, Write_En = 0, Address =   2, Instruction = 0000000110010100
# 50 Reset = 1, Read_En = 1, Write_En = 0, Address =   3, Instruction = 0010011000100010
# 60 Reset = 1, Read_En = 1, Write_En = 0, Address =   4, Instruction = 0000101010010100
# 70 Reset = 1, Read_En = 1, Write_En = 0, Address =   5, Instruction = 0010110001001010
# 80 Reset = 1, Read_En = 1, Write_En = 0, Address =   6, Instruction = 0101101101111111
# 90 Reset = 1, Read_En = 1, Write_En = 0, Address =   7, Instruction = 0000000000000000
*/