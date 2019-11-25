//16x16 reg file two addr_out inputs for two data outs and one addr_in input and one data_in
module reg_file_8x16 (
 input          clk,
 input          rst_n,
 input          wr_en,
 input  [2:0]   rd0_addr,
 input  [2:0]   rd1_addr,
 input  [2:0]   wr0_addr,
 input  [15:0]  wr0_data,
 output  [15:0] rd0_data,
 output  [15:0] rd1_data);

  reg [15:0]      r0;
  reg [15:0]      r1;
  reg [15:0]      r2;
  reg [15:0]      r3;
  reg [15:0]      r4;
  reg [15:0]      r5;
  reg [15:0]      r6;
  reg [15:0]      r7;
  integer          i;

  always @(posedge clk) begin
    if(wr_en == 1'b1) begin //encoder
      case(wr0_addr)
        4'b000: 
          r0 <= wr0_data;
        4'b001: 
          r1 <= wr0_data;
        4'b010:
          r2 <= wr0_data;
        4'b011:
          r3 <= wr0_data;
        4'b100:
          r4 <= wr0_data;
        4'b101: 
          r5 <= wr0_data;
        4'b110: 
          r6 <= wr0_data;
        4'b111: 
          r7 <= wr0_data;
      endcase
    end
  end // always @ (posedge clk or negedge rst_n)
  mux_3x8 mux_source_reg_1(
    .sel (rd0_addr),
    .in0 (r0),
    .in1 (r1),
    .in2 (r2),
    .in3 (r3),
    .in4 (r4),
    .in5 (r5),
    .in6 (r6),
    .in7 (r7),
    .out (rd0_data)
  );  
  
  mux_3x8 mux_source_reg_2(
    .sel (rd1_addr),
    .in0 (r0),
    .in1 (r1),
    .in2 (r2),
    .in3 (r3),
    .in4 (r4),
    .in5 (r5),
    .in6 (r6),
    .in7 (r7),
    .out (rd1_data)
  );

endmodule

/* Simulation Results
# wr_en:1, dest_reg: 0, din:13604
# wr_en:0, dest_reg: 1, din:24193
# wr_en:1, dest_reg: 2, din:54793
# wr_en:0, dest_reg: 3, din:22115
# wr_en:1, dest_reg: 4, din:31501
# wr_en:0, dest_reg: 5, din:39309
# wr_en:1, dest_reg: 6, din:33893
# wr_en:0, dest_reg: 7, din:21010
# wr_en:1, dest_reg: 0, din:58113
# wr_en:0, dest_reg: 0, din:52493
# wr_en:1, dest_reg: 1, din:61814
# wr_en:0, dest_reg: 2, din:52541
# wr_en:1, dest_reg: 3, din:22509
# wr_en:0, dest_reg: 4, din:63372
# wr_en:1, dest_reg: 5, din:59897
# wr_en:0, dest_reg: 6, din: 9414
# wr_en:1, dest_reg: 7, din:33989
# Source0_addr: 0, Source0_value: 58113
# Source1_addr: 0, Source1_value: 58113
# Source0_addr: 2, Source0_value: 54793
# Source1_addr: 5, Source1_value: 59897
# Source0_addr: 7, Source0_value: 33989
# Source1_addr: 2, Source1_value: 54793
# Source0_addr: 7, Source0_value: 33989
# Source1_addr: 2, Source1_value: 54793
# Source0_addr: 6, Source0_value: 33893
# Source1_addr: 0, Source1_value: 58113
# Source0_addr: 5, Source0_value: 59897
# Source1_addr: 4, Source1_value: 31501
# Source0_addr: 5, Source0_value: 59897
# Source1_addr: 5, Source1_value: 59897
# Source0_addr: 5, Source0_value: 59897
# Source1_addr: 3, Source1_value: 22509
# Source0_addr: 2, Source0_value: 54793
# Source1_addr: 0, Source1_value: 58113
# Source0_addr: 0, Source0_value: 58113
# Source1_addr: 2, Source1_value: 54793
# Source0_addr: 5, Source0_value: 59897
# Source1_addr: 6, Source1_value: 33893
# Source0_addr: 3, Source0_value: 22509
# Source1_addr: 5, Source1_value: 59897
# Source0_addr: 3, Source0_value: 22509
# Source1_addr: 3, Source1_value: 22509
# Source0_addr: 5, Source0_value: 59897
# Source1_addr: 2, Source1_value: 54793
# Source0_addr: 6, Source0_value: 33893
# Source1_addr: 5, Source1_value: 59897
# Source0_addr: 7, Source0_value: 33989
# Source1_addr: 3, Source1_value: 22509
# Source0_addr: 2, Source0_value: 54793
# Source1_addr: 2, Source1_value: 54793
# Source0_addr: 4, Source0_value: 31501
# Source1_addr: 2, Source1_value: 54793
# Source0_addr: 2, Source0_value: 54793
# Source1_addr: 1, Source1_value: 61814
# Source0_addr: 0, Source0_value: 58113
# Source1_addr: 0, Source1_value: 58113
# Source0_addr: 1, Source0_value: 61814
# Source1_addr: 3, Source1_value: 22509
# Source0_addr: 6, Source0_value: 33893
# Source1_addr: 6, Source1_value: 33893
# Source0_addr: 6, Source0_value: 33893
# Source1_addr: 4, Source1_value: 31501
# Source0_addr: 2, Source0_value: 54793
# Source1_addr: 3, Source1_value: 22509
# Source0_addr: 1, Source0_value: 61814
# Source1_addr: 5, Source1_value: 59897
# Source0_addr: 7, Source0_value: 33989
# Source1_addr: 3, Source1_value: 22509
# Source0_addr: 2, Source0_value: 54793
# Source1_addr: 6, Source1_value: 33893
# Source0_addr: 5, Source0_value: 59897
# Source1_addr: 1, Source1_value: 61814
*/ 