`timescale 1ns / 1ps

module water_fill #(
    parameter clk_freq = 50000000, 
    parameter delay_sec = 5          
)(
    input  wire rst_n, clk,
    input  wire flow_sense, mid_sense, low_sense, max_sense,
    output wire valve, motor
);
    
    // Standard Verilog State Definitions (Replacing the enum)
    parameter BOOT     = 3'b000;
    parameter IDLE     = 3'b001;
    parameter STAND_BY = 3'b010;
    parameter PRE_FILL = 3'b011;
    parameter FILL     = 3'b100;
    parameter ERROR    = 3'b101;

    reg [2:0] state, next_state;
    wire timer_done;
    
    // Timer Instantiation
    hw_timer #(
        .tick(clk_freq * delay_sec)
    ) delay_timer_inst (
        .clk(clk),
        .rst_n(rst_n),
        .en(state == PRE_FILL), 
        .done(timer_done)           
    );
    
    // Combinational Logic
    always @(*) begin
        next_state = state; // Default
        
        if ((max_sense && !mid_sense) || (mid_sense && !low_sense)) begin
            next_state = ERROR;
        end 
        else begin
            case(state)
                BOOT: begin
                    if(max_sense)            next_state = IDLE;
                    else if(flow_sense)      next_state = PRE_FILL;
                    else                     next_state = STAND_BY;
                end
                IDLE: begin
                    if(!mid_sense && flow_sense)       next_state = PRE_FILL;
                    else if (!mid_sense && !flow_sense) next_state = STAND_BY;
                end
                STAND_BY: begin
                    if(flow_sense) next_state = PRE_FILL;
                end
                PRE_FILL: begin
                    if (!flow_sense)     next_state = STAND_BY; 
                    else if (timer_done) next_state = FILL; 
                end
                FILL: begin 
                    if(!flow_sense)      next_state = STAND_BY;
                    else if(max_sense)   next_state = IDLE;
                end
                ERROR: begin
                    next_state = ERROR;
                end
                default: next_state = BOOT;
            endcase
        end
    end
    
    // Sequential Memory
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            state <= BOOT;
        else
            state <= next_state;
    end
    
    // Output Logic
    assign valve = (state == PRE_FILL) || (state == FILL);
    assign motor = (state == FILL);
    
endmodule