`timescale 1ns / 1ps

module hw_timer #(
    parameter tick = 100000000
)(
    input  wire clk, 
    input  wire rst_n, 
    input  wire en, 
    output reg  done
);
    
    // In standard Verilog, we have to calculate the bit-width manually 
    // or use a big enough register. 32 bits is safe for up to 85 seconds at 50MHz!
    reg [31:0] count;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
            done  <= 0;
        end else if (en) begin
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