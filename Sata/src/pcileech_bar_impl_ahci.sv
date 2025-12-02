//
// PCILeech FPGA.
//
// AHCI Mimic Module.
// Mimics basic AHCI registers to prevent detection.
//
// (c) Ulf Frisk, 2024
//

`timescale 1ns / 1ps
`include "pcileech_header.svh"

module pcileech_bar_impl_ahci(
    input                   rst,
    input                   clk,
    input [31:0]            wr_addr,
    input [3:0]             wr_be,
    input [31:0]            wr_data,
    input                   wr_valid,
    input [87:0]            rd_req_ctx,
    input [31:0]            rd_req_addr,
    input                   rd_req_valid,
    output [87:0]           rd_rsp_ctx,
    output reg [31:0]       rd_rsp_data,
    output reg              rd_rsp_valid
);

    // Registers
    // 0x00 CAP - Host Capabilities
    // 0x04 GHC - Global Host Control
    // 0x08 IS  - Interrupt Status
    // 0x0C PI  - Ports Implemented
    // 0x10 VS  - Version
    // 0x14 CCC_CTL - Command Completion Coalescing Control
    // 0x18 CCC_PORTS - Command Completion Coalescing Ports
    // 0x1C EM_LOC - Enclosure Management Location
    // 0x20 EM_CTL - Enclosure Management Control
    // 0x24 CAP2 - Host Capabilities Extended
    // 0x28 BOHC - BIOS/OS Handoff Control and Status

    reg [31:0] r_ghc;
    reg [31:0] r_is;
    
    // Port 0 Registers
    reg [31:0] r_p0_clb;
    reg [31:0] r_p0_clbu;
    reg [31:0] r_p0_fb;
    reg [31:0] r_p0_fbu;
    reg [31:0] r_p0_cmd;

    // Port 1 Registers
    reg [31:0] r_p1_clb;
    reg [31:0] r_p1_clbu;
    reg [31:0] r_p1_fb;
    reg [31:0] r_p1_fbu;
    reg [31:0] r_p1_cmd;
    
    // Initialize registers
    always @ ( posedge clk )
        if ( rst ) begin
            r_ghc <= 32'h00000000; // AE=0, HR=0 on hard reset
            r_is  <= 32'h00000000;
            
            r_p0_clb <= 0; r_p0_clbu <= 0; r_p0_fb <= 0; r_p0_fbu <= 0; r_p0_cmd <= 0;
            r_p1_clb <= 0; r_p1_clbu <= 0; r_p1_fb <= 0; r_p1_fbu <= 0; r_p1_cmd <= 0;
        end
        else begin
             // Self-clearing HBA Reset (HR) bit 0
             if ( r_ghc[0] ) 
                 r_ghc[0] <= 1'b0;
             
             if ( wr_valid ) begin
                // Handle writes
                if ( wr_addr[11:0] == 12'h004 ) begin // GHC
                    if ( wr_be[0] ) r_ghc[7:0]   <= wr_data[7:0];
                    if ( wr_be[1] ) r_ghc[15:8]  <= wr_data[15:8];
                    if ( wr_be[2] ) r_ghc[23:16] <= wr_data[23:16];
                    if ( wr_be[3] ) r_ghc[31:24] <= wr_data[31:24];
                    // Note: If HR(bit 0) is written as 1, it will be cleared in next cycle by the logic above
                end
                else if ( wr_addr[11:0] == 12'h008 ) begin // IS (R/W1C)
                    if ( wr_be[0] ) r_is[7:0]   <= r_is[7:0]   & ~wr_data[7:0];
                    if ( wr_be[1] ) r_is[15:8]  <= r_is[15:8]  & ~wr_data[15:8];
                    if ( wr_be[2] ) r_is[23:16] <= r_is[23:16] & ~wr_data[23:16];
                    if ( wr_be[3] ) r_is[31:24] <= r_is[31:24] & ~wr_data[31:24];
                end
                
                // Port 0 Writes
                else if ( wr_addr[11:0] == 12'h100 ) begin // P0CLB
                    if ( wr_be[0] ) r_p0_clb[7:0]   <= wr_data[7:0];
                    if ( wr_be[1] ) r_p0_clb[15:8]  <= wr_data[15:8];
                    if ( wr_be[2] ) r_p0_clb[23:16] <= wr_data[23:16];
                    if ( wr_be[3] ) r_p0_clb[31:24] <= wr_data[31:24];
                end
                else if ( wr_addr[11:0] == 12'h104 ) begin // P0CLBU
                    if ( wr_be[0] ) r_p0_clbu[7:0]   <= wr_data[7:0];
                    if ( wr_be[1] ) r_p0_clbu[15:8]  <= wr_data[15:8];
                    if ( wr_be[2] ) r_p0_clbu[23:16] <= wr_data[23:16];
                    if ( wr_be[3] ) r_p0_clbu[31:24] <= wr_data[31:24];
                end
                else if ( wr_addr[11:0] == 12'h108 ) begin // P0FB
                    if ( wr_be[0] ) r_p0_fb[7:0]   <= wr_data[7:0];
                    if ( wr_be[1] ) r_p0_fb[15:8]  <= wr_data[15:8];
                    if ( wr_be[2] ) r_p0_fb[23:16] <= wr_data[23:16];
                    if ( wr_be[3] ) r_p0_fb[31:24] <= wr_data[31:24];
                end
                else if ( wr_addr[11:0] == 12'h10C ) begin // P0FBU
                    if ( wr_be[0] ) r_p0_fbu[7:0]   <= wr_data[7:0];
                    if ( wr_be[1] ) r_p0_fbu[15:8]  <= wr_data[15:8];
                    if ( wr_be[2] ) r_p0_fbu[23:16] <= wr_data[23:16];
                    if ( wr_be[3] ) r_p0_fbu[31:24] <= wr_data[31:24];
                end
                else if ( wr_addr[11:0] == 12'h118 ) begin // P0CMD
                    if ( wr_be[0] ) r_p0_cmd[7:0]   <= wr_data[7:0];
                    if ( wr_be[1] ) r_p0_cmd[15:8]  <= wr_data[15:8];
                    if ( wr_be[2] ) r_p0_cmd[23:16] <= wr_data[23:16];
                    if ( wr_be[3] ) r_p0_cmd[31:24] <= wr_data[31:24];
                end

                // Port 1 Writes
                else if ( wr_addr[11:0] == 12'h180 ) begin // P1CLB
                    if ( wr_be[0] ) r_p1_clb[7:0]   <= wr_data[7:0];
                    if ( wr_be[1] ) r_p1_clb[15:8]  <= wr_data[15:8];
                    if ( wr_be[2] ) r_p1_clb[23:16] <= wr_data[23:16];
                    if ( wr_be[3] ) r_p1_clb[31:24] <= wr_data[31:24];
                end
                else if ( wr_addr[11:0] == 12'h184 ) begin // P1CLBU
                    if ( wr_be[0] ) r_p1_clbu[7:0]   <= wr_data[7:0];
                    if ( wr_be[1] ) r_p1_clbu[15:8]  <= wr_data[15:8];
                    if ( wr_be[2] ) r_p1_clbu[23:16] <= wr_data[23:16];
                    if ( wr_be[3] ) r_p1_clbu[31:24] <= wr_data[31:24];
                end
                else if ( wr_addr[11:0] == 12'h188 ) begin // P1FB
                    if ( wr_be[0] ) r_p1_fb[7:0]   <= wr_data[7:0];
                    if ( wr_be[1] ) r_p1_fb[15:8]  <= wr_data[15:8];
                    if ( wr_be[2] ) r_p1_fb[23:16] <= wr_data[23:16];
                    if ( wr_be[3] ) r_p1_fb[31:24] <= wr_data[31:24];
                end
                else if ( wr_addr[11:0] == 12'h18C ) begin // P1FBU
                    if ( wr_be[0] ) r_p1_fbu[7:0]   <= wr_data[7:0];
                    if ( wr_be[1] ) r_p1_fbu[15:8]  <= wr_data[15:8];
                    if ( wr_be[2] ) r_p1_fbu[23:16] <= wr_data[23:16];
                    if ( wr_be[3] ) r_p1_fbu[31:24] <= wr_data[31:24];
                end
                else if ( wr_addr[11:0] == 12'h198 ) begin // P1CMD
                    if ( wr_be[0] ) r_p1_cmd[7:0]   <= wr_data[7:0];
                    if ( wr_be[1] ) r_p1_cmd[15:8]  <= wr_data[15:8];
                    if ( wr_be[2] ) r_p1_cmd[23:16] <= wr_data[23:16];
                    if ( wr_be[3] ) r_p1_cmd[31:24] <= wr_data[31:24];
                end
            end
        end

    // Pipeline context
    reg [87:0]  ctx_d;
    always @ ( posedge clk )
        ctx_d <= rd_req_ctx;
    
    assign rd_rsp_ctx = ctx_d;

    // Handle reads
    always @ ( posedge clk ) begin
        rd_rsp_valid <= rd_req_valid;
        if ( rd_req_valid ) begin
            case ( rd_req_addr[11:0] )
                12'h000: rd_rsp_data <= 32'hC734FF01; // CAP: S64A+SNCQ+SSNTF+SMPS+SSS+SALP+SAL+SCLO+ISS=3(6Gbps)+NCS=31+NP=1(2ports)
                12'h004: rd_rsp_data <= r_ghc;        // GHC
                12'h008: rd_rsp_data <= r_is;         // IS
                12'h00C: rd_rsp_data <= 32'h00000003; // PI: Port 0 and 1 implemented (2 ports)
                12'h010: rd_rsp_data <= 32'h00010301; // VS: AHCI 1.3.1
                12'h024: rd_rsp_data <= 32'h00000000; // CAP2
                12'h028: rd_rsp_data <= 32'h00000000; // BOHC
                
                // Port 0 (Offset 0x100)
                12'h100: rd_rsp_data <= r_p0_clb;     // P0CLB
                12'h104: rd_rsp_data <= r_p0_clbu;    // P0CLBU
                12'h108: rd_rsp_data <= r_p0_fb;      // P0FB
                12'h10C: rd_rsp_data <= r_p0_fbu;     // P0FBU
                12'h118: rd_rsp_data <= r_p0_cmd;     // P0CMD
                12'h120: rd_rsp_data <= 32'h00000000; // P0TFD
                12'h128: rd_rsp_data <= 32'h00000000; // P0SSTS (Det=0, Spd=0, IPM=0) - No device attached
                                                      
                // Port 1 (Offset 0x180)
                12'h180: rd_rsp_data <= r_p1_clb;     // P1CLB
                12'h184: rd_rsp_data <= r_p1_clbu;    // P1CLBU
                12'h188: rd_rsp_data <= r_p1_fb;      // P1FB
                12'h18C: rd_rsp_data <= r_p1_fbu;     // P1FBU
                12'h198: rd_rsp_data <= r_p1_cmd;     // P1CMD
                12'h1A0: rd_rsp_data <= 32'h00000000; // P1TFD
                12'h1A8: rd_rsp_data <= 32'h00000000; // P1SSTS
                
                default: rd_rsp_data <= 32'h00000000;
            endcase
        end
    end

endmodule
