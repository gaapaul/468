//This is the ram for the CPU
module ram_rw_2p_16x128(
                     input         clk,
                     input         read_en0,
                     input         read_en1,
                     input         write_en0,
                     input         write_en1,
                     input [6:0]   addr0,
                     input [6:0]   addr1,
                     input [15:0]  din0,
                     input [15:0]  din1,
                     output [15:0] dout0,
                     output [15:0] dout1);
  reg [15:0]                       ram_data [127:0];
  reg [15:0]                       ram_dout0;
  reg [15:0]                       ram_dout1;
  always @(posedge clk) begin
    if (write_en0 == 1'b1 && read_en0 == 1'b0) begin
      ram_data[addr0] <= din0;
    //end else if(write_en0 == 1'b0 && read_en0 == 1'b1) begin
      //ram_dout0 <= ram_data[addr0];
    //end
    if (write_en1 == 1'b1 && read_en1 == 1'b0) begin
      ram_data[addr1] <= din1;
    end else if(write_en1 == 1'b0 && read_en1 == 1'b1) begin
      ram_dout1 <= ram_data[addr1];
    end
  end // always @ (posedge clk)
  assign dout0 = ram_dout0;
  assign dout1 = ram_dout1;
endmodule
