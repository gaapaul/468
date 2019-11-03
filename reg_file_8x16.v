//16x16 reg file two addr_out inputs for two data outs and one addr_in input and one data_in
`default_nettype none
module reg_file_8x16 (
 input wire         clk,
 input wire         rst_n,
 input wire         wr_en,
// input wire         rd_en,
 input wire [2:0]   rd0_addr,
 input wire [2:0]   rd1_addr,
 input wire [2:0]   wr0_addr,
 input wire [15:0]  wr0_data,
 output wire [15:0] rd0_data,
 output wire [15:0] rd1_data);

  reg [15:0]      reg_file[7:0];
  reg [15:0]      rd0_dout;
  reg [15:0]      rd1_dout;
  integer          i;

  always @(posedge clk) begin
    if(wr_en == 1'b1) begin
      reg_file[wr0_addr] <= wr0_data;
    end
  end // always @ (posedge clk or negedge rst_n)
  always@(*) begin
      rd0_dout = reg_file[rd0_addr];
      rd1_dout = reg_file[rd1_addr];
  end      
  assign rd0_data = rd0_dout;
  assign rd1_data = rd1_dout;
endmodule