module regfile_tb();
  integer i;
  wire [2:0]	operand1;
  //operand2
  reg        clk_10;
  reg        reset;
  wire [2:0] operand2;
  wire [2:0] dest_reg;
  reg [2:0] op1_reg;
  reg [2:0] op2_reg;
  reg [2:0] dest_reg_reg;
  reg [2:0] dest_reg_reg_d;
  reg wr_en_reg;
  wire wr_en;
  reg [15:0] din_reg;
  wire [15:0] wr0_data_in;
  wire [15:0] rd0_data_out;
  wire [15:0] rd1_data_out;
  wire rst_n;
  assign  clk = clk_10;
  assign rst_n = ~reset;

  initial begin
    clk_10 <= 0;
    reset <= 1;
    wr_en_reg <= 0;
    dest_reg_reg<=0;
    dest_reg_reg_d<=0;
    op1_reg<=0;
    op2_reg<=0;
    din_reg<=0;
    #10
    //set wr_en to 1 and start for loop to load values
    reset <= 0;
    for(i=0;i<17;i=i+1)begin
      wr_en_reg <= !wr_en_reg;
      dest_reg_reg_d <= dest_reg_reg;
      dest_reg_reg <= (i % 9);
      din_reg <= $random;
      #20;
      $display("wr_en:%d, dest_reg: %d, din:%d", wr_en, dest_reg_reg, din_reg);
    end
    for(i=0;i<32;i=i+1) begin
      $display("Source0_addr: %d, Source0_value: %d", op1_reg, rd0_data_out);
      $display("Source1_addr: %d, Source1_value: %d", op2_reg, rd1_data_out);
      op1_reg <= $random % 8;
      op2_reg <= $random % 8;
      #20;
    end
  end // initial begin

  always begin
    #10
    clk_10 = ~clk_10;
  end

  assign wr0_data_in = din_reg;
  assign wr_en = wr_en_reg;
  assign operand1 = op1_reg;
  assign operand2 = op2_reg;
  assign dest_reg = dest_reg_reg;
 reg_file_8x16 reg_file_8x16_1 (
    .clk (clk),
    .rst_n (rst_n),
    .wr_en (wr_en),
    .rd0_addr(operand1),
    .rd1_addr(operand2),
    .wr0_addr(dest_reg),
    .wr0_data(wr0_data_in),
    .rd0_data(rd0_data_out),
    .rd1_data(rd1_data_out)
  );

endmodule
