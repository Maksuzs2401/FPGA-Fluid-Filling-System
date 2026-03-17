`timescale 1ns / 1ps

module water_fill_top (
    // 1. The Physical Inputs (From the outside world)
    input  wire clk,
    input  wire rst_n,
    input  wire raw_flow_sense,
    input  wire raw_low_sense,
    input  wire raw_mid_sense,
    input  wire raw_max_sense,
    
    // 2. The Physical Outputs (To the relays/optocouplers)
    output wire motor,
    output wire valve
);

    // 3. Internal Wires (The "invisible" traces inside the FPGA)
    wire clean_flow;
    wire clean_low;
    wire clean_mid;
    wire clean_max;

    // =========================================================
    // INSTANTIATE THE DEBOUNCERS (Cleaning the physical inputs)
    // =========================================================
    debouncer db_flow (
        .clk(clk),
        .rst_n(rst_n),
        .async_in(raw_flow_sense),
        .clean_out(clean_flow)
    );

    debouncer db_low (
        .clk(clk),
        .rst_n(rst_n),
        .async_in(raw_low_sense),
        .clean_out(clean_low)
    );

    debouncer db_mid (
        .clk(clk),
        .rst_n(rst_n),
        .async_in(raw_mid_sense),
        .clean_out(clean_mid)
    );

    debouncer db_max (
        .clk(clk),
        .rst_n(rst_n),
        .async_in(raw_max_sense),
        .clean_out(clean_max)
    );

    // =========================================================
    // INSTANTIATE THE BRAIN (The State Machine)
    // =========================================================
    water_fill fsm_inst (
        .clk(clk),
        .rst_n(rst_n),
        // Feed the CLEANED signals into the FSM
        .flow_sense(clean_flow),
        .low_sense(clean_low),
        .mid_sense(clean_mid),
        .max_sense(clean_max),
        // Route the FSM outputs straight to the physical FPGA pins
        .motor(motor),
        .valve(valve)
    );

endmodule