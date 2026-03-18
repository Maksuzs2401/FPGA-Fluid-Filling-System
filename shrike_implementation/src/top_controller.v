`timescale 1ns / 1ps

(* top *) module top_water_controller #(
    parameter CLK_FREQ  = 50000000, 
    parameter DELAY_SEC = 5
)(
    (* iopad_external_pin , clkbuf_inhibit *) input  wire clk,
    (* iopad_external_pin *) input  wire rst_n,
    (* iopad_external_pin *) output wire clk_en,
    
    // SENSORS
    (* iopad_external_pin *) input  wire raw_flow_sense,
    
    (* iopad_external_pin *) input  wire raw_mid_sense,
    
    (* iopad_external_pin *) input  wire raw_low_sense,
    
    (* iopad_external_pin *) input  wire raw_max_sense,
    
    
    // ACTUATORS (Changed to wire because main_brain drives them)
    (* iopad_external_pin *) output wire valve,
    (* iopad_external_pin *) output wire valve_en,
    (* iopad_external_pin *) output wire motor,
    (* iopad_external_pin *) output wire motor_en // Added this
);

    // --- 1. Pin Enable Logic ---
    assign clk_en = 1'b1;
    assign valve_en = 1'b1;
    assign motor_en = 1'b1; // Turn on the motor pin driver

    // IMPORTANT: These MUST be 1 to allow the signal INTO the FPGA

    // 1. Create synchronization registers
    reg sync_flow, sync_mid, sync_low, sync_max;

    // 2. Sample the raw pins on the clock edge
    always @(posedge clk) begin
        sync_flow <= raw_flow_sense;
        sync_mid  <= raw_mid_sense;
        sync_low  <= raw_low_sense;
        sync_max  <= raw_max_sense;
    end

    // 3. Feed the SYNCED signals to the FSM instead of the raw ones
    water_fill #(
        .clk_freq(CLK_FREQ), 
        .delay_sec(DELAY_SEC)
    ) main_brain (
        .clk(clk),
        .rst_n(rst_n),
        .flow_sense(sync_flow), // Clean internal signal
        .mid_sense(sync_mid),   // Clean internal signal
        .low_sense(sync_low),
        .max_sense(sync_max),
        .valve(valve),
        .motor(motor)
    );
    
endmodule
    