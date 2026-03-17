`timescale 1ns / 1ps

module tb_water_fill();

    // --- 1. Testbench Signals ---
    logic clk, rst_n;
    logic flow_sense, mid_sense, low_sense, max_sense;
    logic valve, motor;

    // --- 2. Instantiate the DUT with Fast-Simulation Parameters ---
    water_fill #(
        .clk_freq(1),   // Trick the math: 1 tick per second
        .delay_sec(5)   // 5 "seconds" is now exactly 5 clock ticks!
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .flow_sense(flow_sense), .mid_sense(mid_sense), 
        .low_sense(low_sense), .max_sense(max_sense),
        .valve(valve), .motor(motor)
    );

    // --- 3. Generate 50MHz Clock (20ns period) ---
    initial begin
        clk = 0;
        forever #10 clk = ~clk; 
    end

    // --- 4. The Test Vectors (Trying to break it) ---
    initial begin
        $display("\n[VERIF] --- STARTING MASTER SIMULATION ---");

        // --- SCENARIO 1: Power-On Top-Off (BOOT State) ---
        // Setup: Power is off. Tank is at 80% (low=1, mid=1, max=0). Flow is available.
        rst_n = 0; 
        flow_sense = 1; low_sense = 1; mid_sense = 1; max_sense = 0; 
        
        #25; rst_n = 1; // Power turns on!
        $display("\n[VERIF] SCENARIO 1: Power-On Top-Off");
        $display("[VERIF] Tank at 80%%. Power restored. FSM should evaluate BOOT and jump to PRE_FILL.");
        #20; 
        $display("[VERIF] State is %s. Outputs: V=%b M=%b", dut.state.name(), valve, motor);
        
        // --- SCENARIO 2: The 5-Tick Motor Delay ---
        $display("\n[VERIF] SCENARIO 2: Motor Startup Delay");
        $display("[VERIF] Waiting 5 clock ticks (100ns) for pressure to build...");
        #100; // Wait exactly 5 clock cycles
        $display("[VERIF] Timer finished! State is %s. Outputs: V=%b M=%b", dut.state.name(), valve, motor);
        
        // Tank hits 100%
        #40; max_sense = 1;
        #20; $display("[VERIF] Tank is FULL. State is %s. Outputs: V=%b M=%b", dut.state.name(), valve, motor);

        // --- SCENARIO 3: Anti-Chatter Test ---
        $display("\n[VERIF] SCENARIO 3: Anti-Chatter Test");
        #40; max_sense = 0; // Someone uses a little water, drops below Max
        #40; 
        $display("[VERIF] Water dropped below Max (mid is still wet). FSM should ignore it.");
        $display("[VERIF] State is %s. Outputs: V=%b M=%b", dut.state.name(), valve, motor);

        // --- SCENARIO 4: The Drought Abort ---
        $display("\n[VERIF] SCENARIO 4: The Drought Abort (Timer Reset Check)");
        mid_sense = 0; // Water drops below mid!
        #20; $display("[VERIF] Tank below mid. Jumped to %s. V=%b M=%b", dut.state.name(), valve, motor);
        
        #40; // Wait 2 ticks into the PRE_FILL delay...
        flow_sense = 0; // SUDDENLY CITY WATER DIES!
        #20; $display("[VERIF] City water died mid-delay! Aborted to %s. V=%b M=%b", dut.state.name(), valve, motor);
        
        #40; flow_sense = 1; // City water comes back
        #20; $display("[VERIF] Water returned. Restarted %s delay from scratch. V=%b M=%b", dut.state.name(), valve, motor);
        // ... (inside Scenario 4) ...
        #40; flow_sense = 1; // City water comes back
        #20; $display("[VERIF] Water returned. Restarted PRE_FILL delay from scratch. V=%b M=%b", dut.state.name(), valve, motor);
        
        // 1. Wait the 5 clock ticks (100ns) for the delay to finish
        #100; 
        
        // 2. DO NOT FILL THE TANK YET! 
        // Let's just wait another 80ns so you can clearly see the motor running on the waveform.
        #80; 
        $display("[VERIF] Motor has been running for 80ns! V=%b M=%b", valve, motor);
        
        // 3. NOW the tank finally fills up
        max_sense = 1; mid_sense = 1; 
        #40; // Let the FSM register that it's full and shut the motor off

        // --- SCENARIO 5: Impossible Physics ---
        $display("\n[VERIF] SCENARIO 5: Impossible Physics");
        low_sense = 0; // Bottom sensor breaks while tank is full
        #40; $display("[VERIF] Sensor snapped! System locked in %s. V=%b M=%b", dut.state.name(), valve, motor);

        $display("\n[VERIF] --- SIMULATION COMPLETE --- \n");
        $finish;
    end

endmodule