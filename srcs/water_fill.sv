`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.03.2026 12:17:52
// Design Name:  
// Module Name: water_fill
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module water_fill #(
    parameter int clk_freq = 50_000_000, 
    parameter int delay_sec = 5          
)(
  input logic rst_n, clk,
  input logic flow_sense, mid_sense, low_sense, 
  max_sense,
  output logic valve, motor
    );
    typedef enum logic[2:0]{
      BOOT,IDLE,STAND_BY,PRE_FILL,FILL,ERROR 
      }work_stats;
    work_stats state, next_state;
    logic timer_done;
    
    hw_timer #(                     //Inst. Hw timer!
        .tick(clk_freq * delay_sec)
    )delay_timer_inst (
        .clk(clk),
        .rst_n(rst_n),
        .en(state == PRE_FILL), 
        .done(timer_done)           
    );
    
    always_comb begin        // Comb. always block
      next_state = state;
      
      if ((max_sense && !mid_sense) || (mid_sense && !low_sense)) begin
          next_state = ERROR;       //Failsafe case
      end else begin
          unique case(state)
            BOOT: begin 
              if(max_sense) next_state = IDLE;
              else if(flow_sense) next_state = PRE_FILL;
              else next_state = STAND_BY;
            end
            IDLE: begin
              if(!mid_sense && flow_sense) next_state = PRE_FILL;
              else if (!mid_sense && !flow_sense) next_state = STAND_BY;
            end
            STAND_BY: begin
              if(flow_sense) next_state = PRE_FILL;
            end
            PRE_FILL: begin
              if (!flow_sense) next_state = STAND_BY; 
              else if (timer_done) next_state = FILL; 
            end
            FILL: begin 
              if(!flow_sense) next_state = STAND_BY;
              else if(max_sense) next_state = IDLE;
            end
            ERROR:begin
                next_state = ERROR;
            end
            default: next_state = BOOT;
          endcase
      end
    end
    
    always_ff @(posedge clk or negedge rst_n) begin  //Seq. always block!
      if(!rst_n)
        state <= BOOT;
      else
        state <= next_state;
    end
    
    assign valve = (state == FILL)||(state==PRE_FILL);  //Assigning O/P.
    assign motor = (state == FILL);
endmodule
