`timescale 1ns / 1ps

module Pipeline_Top (
    input clk,
    input rst
);

    // Fetch stage wires
    wire [31:0] instr_d;
    wire [31:0] pc_d;
    wire [31:0] pc_plus4_d;

    // Decode stage wires
    wire [4:0]  rs1_d, rs2_d;
    wire        reg_write_e;
    wire        alu_src_e;
    wire        mem_write_e;
    wire [1:0]  result_src_e;
    wire        branch_e;
    wire [2:0]  branch_op_e;
    wire        jump_e;
    wire        jalr_e;
    wire        auipc_e;
    wire [3:0]  alu_control_e;
    wire [31:0] rd1_e, rd2_e, imm_ext_e;
    wire [4:0]  rs1_e, rs2_e, rd_e;
    wire [31:0] pc_e, pc_plus4_e;

    // Execute stage wires
    wire        pc_src_e;
    wire [31:0] pc_target_e;
    wire        reg_write_m;
    wire        mem_write_m;
    wire [1:0]  result_src_m;
    wire [4:0]  rd_m;
    wire [31:0] pc_plus4_m;
    wire [31:0] write_data_m;
    wire [31:0] alu_result_m;

    // Memory stage wires
    wire        reg_write_w;
    wire [1:0]  result_src_w;
    wire [4:0]  rd_w;
    wire [31:0] pc_plus4_w;
    wire [31:0] alu_result_w;
    wire [31:0] read_data_w;

    // Writeback stage wires
    wire [31:0] result_w;

    // Hazard unit control wires
    wire [1:0]  forward_a_e, forward_b_e;
    wire        stall_f, stall_d, flush_e, flush_d;

    // --- 1. Instruction Fetch Stage ---
    Fetch_Cycle fetch_stage (
        .clk(clk),
        .rst(rst),
        .stall_f(stall_f),
        .stall_d(stall_d),
        .flush_d(flush_d),
        .pc_src_e(pc_src_e),
        .pc_target_e(pc_target_e),
        .instr_d(instr_d),
        .pc_d(pc_d),
        .pc_plus4_d(pc_plus4_d)
    );

    // --- 2. Instruction Decode Stage ---
    Decode_Cycle decode_stage (
        .clk(clk),
        .rst(rst),
        .flush_e(flush_e),
        .instr_d(instr_d),
        .pc_d(pc_d),
        .pc_plus4_d(pc_plus4_d),
        .reg_write_w(reg_write_w),
        .rd_w(rd_w),
        .result_w(result_w),
        .rs1_d(rs1_d),
        .rs2_d(rs2_d),
        .reg_write_e(reg_write_e),
        .alu_src_e(alu_src_e),
        .mem_write_e(mem_write_e),
        .result_src_e(result_src_e),
        .branch_e(branch_e),
        .branch_op_e(branch_op_e),
        .jump_e(jump_e),
        .jalr_e(jalr_e),
        .auipc_e(auipc_e),
        .alu_control_e(alu_control_e),
        .rd1_e(rd1_e),
        .rd2_e(rd2_e),
        .imm_ext_e(imm_ext_e),
        .rs1_e(rs1_e),
        .rs2_e(rs2_e),
        .rd_e(rd_e),
        .pc_e(pc_e),
        .pc_plus4_e(pc_plus4_e)
    );

    // --- 3. Execute Stage ---
    Execute_Cycle execute_stage (
        .clk(clk),
        .rst(rst),
        .reg_write_e(reg_write_e),
        .alu_src_e(alu_src_e),
        .mem_write_e(mem_write_e),
        .result_src_e(result_src_e),
        .branch_e(branch_e),
        .branch_op_e(branch_op_e),
        .jump_e(jump_e),
        .jalr_e(jalr_e),
        .auipc_e(auipc_e),
        .alu_control_e(alu_control_e),
        .rd1_e(rd1_e),
        .rd2_e(rd2_e),
        .imm_ext_e(imm_ext_e),
        .rd_e(rd_e),
        .pc_e(pc_e),
        .pc_plus4_e(pc_plus4_e),
        .result_w(result_w),
        .forward_a_e(forward_a_e),
        .forward_b_e(forward_b_e),
        .pc_src_e(pc_src_e),
        .pc_target_e(pc_target_e),
        .reg_write_m(reg_write_m),
        .mem_write_m(mem_write_m),
        .result_src_m(result_src_m),
        .rd_m(rd_m),
        .pc_plus4_m(pc_plus4_m),
        .write_data_m(write_data_m),
        .alu_result_m(alu_result_m)
    );

    // --- 4. Memory Access Stage ---
    Memory_Cycle memory_stage (
        .clk(clk),
        .rst(rst),
        .reg_write_m(reg_write_m),
        .mem_write_m(mem_write_m),
        .result_src_m(result_src_m),
        .rd_m(rd_m),
        .pc_plus4_m(pc_plus4_m),
        .write_data_m(write_data_m),
        .alu_result_m(alu_result_m),
        .reg_write_w(reg_write_w),
        .result_src_w(result_src_w),
        .rd_w(rd_w),
        .pc_plus4_w(pc_plus4_w),
        .alu_result_w(alu_result_w),
        .read_data_w(read_data_w)
    );

    // --- 5. Writeback Stage ---
    Writeback_Cycle writeback_stage (
        .result_src_w(result_src_w),
        .alu_result_w(alu_result_w),
        .read_data_w(read_data_w),
        .pc_plus4_w(pc_plus4_w),
        .result_w(result_w)
    );

    // --- Hazard & Forwarding Unit ---
    Hazard_Unit hazard_unit (
        .rs1_e(rs1_e),
        .rs2_e(rs2_e),
        .rd_m(rd_m),
        .reg_write_m(reg_write_m),
        .rd_w(rd_w),
        .reg_write_w(reg_write_w),
        .rs1_d(rs1_d),
        .rs2_d(rs2_d),
        .rd_e(rd_e),
        .result_src_e0(result_src_e[0]),
        .pc_src_e(pc_src_e),
        .forward_a_e(forward_a_e),
        .forward_b_e(forward_b_e),
        .stall_f(stall_f),
        .stall_d(stall_d),
        .flush_e(flush_e),
        .flush_d(flush_d)
    );

endmodule
