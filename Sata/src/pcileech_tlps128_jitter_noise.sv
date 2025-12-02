
`timescale 1ns / 1ps
`include "pcileech_header.svh"

module pcileech_tlps128_jitter_noise(
    input                   rst,
    input                   clk_pcie,
    IfAXIS128.sink          tlps_in,
    IfAXIS128.source        tlps_out
);

    // PRNG / LFSR for jitter generation
    reg [15:0] lfsr;
    always @(posedge clk_pcie) begin
        if (rst)
            lfsr <= 16'hACE1;
        else
            lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
    end

    // Jitter logic:
    // Occasionally delay tready to upstream, causing backpressure (simulating processing delay).
    // Occasionally delay tvalid to downstream (simulating output delay).
    
    // Delay probability (tunable)
    wire jitter_active = (lfsr[3:0] == 4'b0000); // ~6.25% chance to inject jitter per cycle

    // State machine for delaying transmission
    // If jitter occurs, we hold data for 1-3 cycles
    reg [1:0] delay_counter;
    reg       delaying;

    always @(posedge clk_pcie) begin
        if (rst) begin
            delay_counter <= 0;
            delaying      <= 0;
        end else begin
            if (delaying) begin
                if (delay_counter > 0)
                    delay_counter <= delay_counter - 1;
                else
                    delaying <= 0;
            end else if (jitter_active && tlps_in.tvalid && !tlps_in.tlast) begin
                // Only jitter on mid-packet or start, not necessarily end, to avoid stuck packets
                // Or just random stalls.
                delaying      <= 1;
                delay_counter <= lfsr[5:4]; // Random 0-3 cycles delay
            end
        end
    end

    // Pass-through with gating
    // If delaying, we assert backpressure to input (tready=0) and validity to output (tvalid=0)
    
    assign tlps_out.tdata    = tlps_in.tdata;
    assign tlps_out.tkeepdw  = tlps_in.tkeepdw;
    assign tlps_out.tlast    = tlps_in.tlast;
    assign tlps_out.tuser    = tlps_in.tuser;
    assign tlps_out.has_data = tlps_in.has_data;

    assign tlps_out.tvalid   = tlps_in.tvalid && !delaying;
    assign tlps_in.tready    = tlps_out.tready && !delaying;

endmodule
