module mux_3x8(
  input [2:0] sel,
  input [15:0] in0,
  input [15:0] in1,
  input [15:0] in2,
  input [15:0] in3,
  input [15:0] in4,
  input [15:0] in5,
  input [15:0] in6,
  input [15:0] in7,
  output [15:0] out);
  
  reg [15:0] reg_out;
  always @(*) begin
    case(sel)
        4'b000: 
          reg_out = in0;
        4'b001: 
          reg_out = in1;
        4'b010:
          reg_out = in2;
        4'b011:
          reg_out = in3;
        4'b100:
          reg_out = in4;
        4'b101: 
          reg_out = in5;
        4'b110: 
          reg_out = in6;
        4'b111: 
          reg_out = in7;
        default: //never happens
          reg_out = 16'dx;
      endcase
  end      
  assign out = reg_out;
endmodule  
