`timescale 1ns / 1ps

module debouncer #(
    // At 50 MHz, 1 clock tick = 20ns. 
    // To wait 20ms, we need 1,000,000 ticks.
    parameter DEBOUNCE_LIMIT = 1000000 
)(
    input  wire clk,
    input  wire rst_n,
    input  wire async_in,   // The raw, dirty signal from the outside world
    output reg  clean_out   // The safe, delayed, synchronized signal for your FSM
);

    // =========================================================
    // STAGE 1: 2-Flip-Flop Synchronizer
    // =========================================================
    reg sync_0;
    reg sync_1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_0 <= 1'b0;
            sync_1 <= 1'b0;
        end else begin
            sync_0 <= async_in;
            sync_1 <= sync_0;    // sync_1 is now safe from metastability
        end
    end

    // =========================================================
    // STAGE 2: The Debounce Counter
    // =========================================================
    // 20 bits can count up to 1,048,575, perfect for our 1,000,000 limit
    reg [19:0] counter;      

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter   <= 20'd0;
            clean_out <= 1'b0;
        end else begin
            // If the synchronized input is DIFFERENT from our current clean output...
            if (sync_1 !== clean_out) begin
                if (counter < DEBOUNCE_LIMIT) begin
                    counter <= counter + 1'b1; // Start counting!
                end else begin
                    // It has been stable for 20ms. Update the output.
                    clean_out <= sync_1;
                    counter   <= 20'd0;
                end
            end else begin
                // The input matches the output, or it bounced back. Reset the timer.
                counter <= 20'd0; 
            end
        end
    end

endmodule