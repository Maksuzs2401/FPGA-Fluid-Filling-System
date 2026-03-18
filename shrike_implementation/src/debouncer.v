`timescale 1ns / 1ps

module debouncer #(
    parameter THRESHOLD = 1000000 // 20ms at 50MHz (50,000,000 * 0.02)
)(
    input  wire clk,
    input  wire rst_n,
    input  wire noisy_in,
    output reg  clean_out
);

    reg [19:0] counter;
    reg sync_0, sync_1; // The Double-Flop Synchronizer

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_0    <= 0;
            sync_1    <= 0;
            counter   <= 0;
            clean_out <= 0;
        end else begin
            // 1. Synchronize the asynchronous real-world signal to our clock
            sync_0 <= noisy_in;
            sync_1 <= sync_0;

            // 2. The Debounce Logic
            if (sync_1 == clean_out) begin
                // Signal is stable, reset the counter
                counter <= 0; 
            end else begin
                // Signal is trying to change! Start counting.
                counter <= counter + 1;
                
                // If it holds the new value for the full 20ms threshold...
                if (counter >= THRESHOLD) begin
                    clean_out <= sync_1; // ...officially update the output!
                    counter   <= 0;
                end
            end
        end
    end
endmodule