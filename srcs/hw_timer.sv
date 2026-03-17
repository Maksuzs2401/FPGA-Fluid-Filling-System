`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.03.2026 21:56:02
// Design Name: 
// Module Name: hw_timer
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


module hw_timer #( parameter int tick = 250_000_000)
  (input logic clk, rst_n, en, 
  output logic done
    );  
    
    logic [$clog2(tick)-1:0] count;
    
    always_ff @(posedge clk or negedge rst_n)begin
      if(!rst_n)begin
        count <= 0;
        done <= 0;
      end else if(en)begin
        if (count < (tick - 1)) begin
                count <= count + 1;
                done  <= 0;
        end else begin
          done <= 1;
        end   
      end else begin
            count <= 0;
            done  <= 0;
        end
    end
    
endmodule
