`timescale 1ns / 1ps

module tb_top_water_controller;

    // Initialize to 0 immediately to prevent the 'X' state death
    reg clk = 0;
    reg rst_n = 0;
    reg raw_flow_sense = 0;
    reg raw_mid_sense = 0;
    reg raw_low_sense = 0;
    reg raw_max_sense = 0;
    
    wire clk_en, valve, motor;

    top_controller #(
        .CLK_FREQ(4),        // 1 sec = 4 clock cycles
        .DELAY_SEC(5)        // 5 secs = 20 clock cycles total delay
    ) dut (
        .clk(clk), .rst_n(rst_n), .clk_en(clk_en),
        .raw_flow_sense(raw_flow_sense), .raw_mid_sense(raw_mid_sense),
        .raw_low_sense(raw_low_sense), .raw_max_sense(raw_max_sense),
        .valve(valve), .motor(motor)
    );

    // DUMP EVERYTHING
    initial begin
        $dumpfile("tb_top_system.vcd");
        $dumpvars;
    end

    // THE CLOCK
    always #10 clk = ~clk; 

    // THE STIMULUS
    initial begin
        #50; 
        rst_n = 1; // Wake up the chip
        #50;
        
        // 1. City water flows (clean signal)
        raw_flow_sense = 1;
        
        // 2. Wait for the 20-tick timer to finish (400ns)
        #500;
        
        // 3. Tank gets full
        raw_max_sense = 1;
        
        #200;
        $finish;
    end

endmodule