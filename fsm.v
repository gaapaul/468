module fsm #(parameter IDLE_STATE = 2'd0, 
             parameter FETCH_STATE = 2'd1, 
             parameter LOAD_REG_STATE = 2'd2, 
             parameter ALU_STATE = 2'd3) (

    input clk,
    input rst_n,
    input condition_code_check,
    input start,
    output [1:0] curr_state);

    reg [1:0] next_state, current_state;

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
    
    assign curr_state = current_state;
endmodule

/* Simulation Results
#   0 Processor FSM
#  15 State = 0, Condition Code = 1, Start Code = 0, Reset = 1
#  25 State = 0, Condition Code = 1, Start Code = 0, Reset = 1
#  35 State = 0, Condition Code = 1, Start Code = 0, Reset = 1
#  45 State = 0, Condition Code = 1, Start Code = 0, Reset = 1
#  55 State = 0, Condition Code = 0, Start Code = 1, Reset = 1
#  65 State = 1, Condition Code = 0, Start Code = 1, Reset = 1
#  75 State = 2, Condition Code = 0, Start Code = 1, Reset = 1
#  85 State = 1, Condition Code = 0, Start Code = 1, Reset = 1
#  95 State = 2, Condition Code = 0, Start Code = 1, Reset = 1
# 105 State = 1, Condition Code = 0, Start Code = 1, Reset = 1
# 115 State = 2, Condition Code = 0, Start Code = 1, Reset = 1
# 125 State = 1, Condition Code = 0, Start Code = 1, Reset = 1
# 135 State = 2, Condition Code = 0, Start Code = 1, Reset = 1
# 145 State = 1, Condition Code = 0, Start Code = 1, Reset = 1
# 155 State = 2, Condition Code = 1, Start Code = 1, Reset = 1
# 165 State = 3, Condition Code = 1, Start Code = 1, Reset = 1
# 175 State = 1, Condition Code = 1, Start Code = 1, Reset = 1
# 185 State = 2, Condition Code = 1, Start Code = 1, Reset = 1
# 195 State = 3, Condition Code = 1, Start Code = 1, Reset = 1
# 205 State = 1, Condition Code = 1, Start Code = 1, Reset = 1
# 215 State = 2, Condition Code = 1, Start Code = 1, Reset = 1
# 225 State = 3, Condition Code = 1, Start Code = 1, Reset = 1
# 235 State = 1, Condition Code = 1, Start Code = 1, Reset = 1
# 245 State = 2, Condition Code = 1, Start Code = 1, Reset = 1
# 255 State = 0, Condition Code = 1, Start Code = 1, Reset = 0
# 265 State = 0, Condition Code = 1, Start Code = 1, Reset = 0
# 275 State = 0, Condition Code = 1, Start Code = 1, Reset = 0
*/