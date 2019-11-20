//This is the ram for the CPU
`default_nettype none
module ram_rw_16x1024(
  input wire          clk,
  input wire          rst_n,
  input wire          read_en,
  input wire          write_en, 
  input wire  [9:0]   addr,
  input wire  [15:0]  din,
  output wire [15:0]  dout);

  integer     i;
  reg [15:0]  ram_data [1023:0];
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
