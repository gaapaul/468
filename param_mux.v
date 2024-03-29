module mux(
  input [3:0] sel,
  input [15:0] in0,
  input [15:0] in1,
  input [15:0] in2,
  input [15:0] in3,
  input [15:0] in4,
  input [15:0] in5,
  input [15:0] in6,
  input [15:0] in7,
  input [15:0] in8,
  input [15:0] in9,
  input [15:0] in10,
  input [15:0] in11,
  input [15:0] in12,
  input [15:0] in13,
  input [15:0] in14,
  input [15:0] in15,
  output [15:0] out);
  
  reg [15:0] reg_out;
  always @(*) begin
    case(sel)
        4'b0000: 
          reg_out = in0;
        4'b0001: 
          reg_out = in1;
        4'b0010:
          reg_out = in2;
        4'b0011:
          reg_out = in3;
        4'b0100:
          reg_out = in4;
        4'b0101: 
          reg_out = in5;
        4'b0110: 
          reg_out = in6;
        4'b0111: 
          reg_out = in7;
        4'b1000: 
          reg_out = in8;
        4'b1001: 
          reg_out = in9;
        4'b1010: 
          reg_out = in10;
        4'b1011: 
          reg_out = in11;
        4'b1100: 
          reg_out = in12;
        4'b1101: 
          reg_out = in13;
        4'b1110: 
          reg_out = in14;
        4'b1111: 
          reg_out = in15;
        default 
          reg_out = 16'd0;
      endcase
  end      
  assign out = reg_out;
endmodule  
