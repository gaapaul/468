module fsm #(parameter IDLE_STATE = 2'd0, 
             parameter FETCH_STATE = 2'd1, 
             parameter LOAD_REG_STATE = 2'd2, 
             parameter ALU_STATE = 2'd3) (

    input clk,
    input rst_n,
    input condition_code_check,
    input start,
    output reg [1:0] current_state);

    reg [1:0] next_state;

    // Register/Current State Logic
    always@(posedge clk or negedge rst_n)
    begin
      if (rst_n == 1'b0) 
        current_state <= IDLE_STATE;
      else 
        current_state <= next_state;
    end

    // Next State Logic
    always@(*)
    begin
      case(current_state)
        // Initial idle state for the FSM
        IDLE_STATE: begin
          if (start == 1'b1)
            next_state = FETCH_STATE;
          else
            next_state = IDLE_STATE;
        end
        // State to fetch instruction from program RAM
        FETCH_STATE: begin
          next_state = LOAD_REG_STATE;
        end
        // State to load registers and check condition code success
        LOAD_REG_STATE: begin
          if (condition_code_check == 1'b1) 
            next_state = ALU_STATE;
          else
            next_state = FETCH_STATE;	
        end
        // ALU calculation performed
        ALU_STATE: begin
          next_state = FETCH_STATE;
        end
        // Default to idle state
        default: next_state = IDLE_STATE;
      endcase
    end
endmodule

