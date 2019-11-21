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
