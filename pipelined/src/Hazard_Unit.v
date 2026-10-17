`timescale 1ns / 1ps

module Hazard_Unit (
    input        rst,
    input  [4:0] rs1_e,
    input  [4:0] rs2_e,
    input  [4:0] rd_m,
    input        reg_write_m,
    input  [4:0] rd_w,
    input        reg_write_w,
    input  [4:0] rs1_d,
    input  [4:0] rs2_d,
    input  [4:0] rd_e,
    input        result_src_e0, // High if instruction in EX is Load (LW)
    input        pc_src_e,      // High if branch/jump is taken in EX
    output reg [1:0] forward_a_e,
    output reg [1:0] forward_b_e,
    output       stall_f,
    output       stall_d,
    output       flush_e,
    output       flush_d
);

    // --- 1. Data Forwarding Logic to ALU Operand A ---
    always @(*) begin
        if ((reg_write_m == 1'b1) && (rd_m != 5'd0) && (rd_m == rs1_e))
            forward_a_e = 2'b10; // Forward from Memory stage (EX/MEM)
        else if ((reg_write_w == 1'b1) && (rd_w != 5'd0) && (rd_w == rs1_e))
            forward_a_e = 2'b01; // Forward from Writeback stage (MEM/WB)
        else
            forward_a_e = 2'b00; // No forwarding (use ID/EX register)
    end

    // --- 2. Data Forwarding Logic to ALU Operand B ---
    always @(*) begin
        if ((reg_write_m == 1'b1) && (rd_m != 5'd0) && (rd_m == rs2_e))
            forward_b_e = 2'b10; // Forward from Memory stage (EX/MEM)
        else if ((reg_write_w == 1'b1) && (rd_w != 5'd0) && (rd_w == rs2_e))
            forward_b_e = 2'b01; // Forward from Writeback stage (MEM/WB)
        else
            forward_b_e = 2'b00; // No forwarding (use ID/EX register)
    end

    // --- 3. Load-Use Hazard Detection & Control Hazard Flushing ---
    wire lw_stall;
    assign lw_stall = result_src_e0 && ((rd_e == rs1_d) || (rd_e == rs2_d)) && (rd_e != 5'd0);

    // Stalls & Flushes
    assign stall_f = lw_stall;
    assign stall_d = lw_stall;
    assign flush_d = pc_src_e;
    assign flush_e = lw_stall | pc_src_e;

endmodule