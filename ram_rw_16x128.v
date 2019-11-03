//This is the ram for the CPU
`default_nettype none
module ram_rw_16x128(
  input wire          clk,
  input wire          rst_n,
  input wire          read_en,
  input wire          write_en, 
  input wire  [6:0]   addr,
  input wire  [15:0]  din,
  output wire [15:0]  dout);

  integer     i;
  reg [15:0]  ram_data [127:0];
  reg [15:0]  ram_dout;
  always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
      for(i = 0; i < 127; i=i+1) begin
        ram_data[i] <= 16'd0;
      end
    end else begin
      if (write_en == 1'b1 && read_en == 1'b0) begin
        ram_data[addr] <= din;
      end else if(write_en == 1'b0 && read_en == 1'b1) begin
        ram_dout <= ram_data[addr];
      end
    end // else: !if(rst_n)
  end // always @ (posedge clk or negedge rst_n)
  assign dout = ram_dout;
endmodule