`timescale 1ns / 1ps

module top_riscv (
    input clk,
    input reset
);

    // Fetch unit wires
    wire [31:0] pc;
    wire [31:0] pc_plus4;
    wire [31:0] target_pc;
    wire        pc_src;

    // Instruction bus
    wire [31:0] instruction;

    // Control signals
    wire        reg_write;
    wire [2:0]  imm_src;
    wire        alu_src;
    wire        mem_write;
    wire        mem_to_reg;
    wire        branch;
    wire [2:0]  branch_op;
    wire        jump;
    wire        jalr;
    wire        auipc;
    wire [3:0]  alu_control;

    // Immediate extension
    wire [31:0] imm_ext;

    // 1. Instruction Fetch Unit (PC management)
    instruction_fetch_unit ifu (
        .clk(clk),
        .reset(reset),
        .pc_src(pc_src),
        .target_pc(target_pc),
        .pc(pc),
        .pc_plus4(pc_plus4)
    );

    // 2. Instruction Memory (ROM)
    instruction_memory imem (
        .addr(pc),
        .read_data(instruction)
    );

    // 3. Control Unit Decoder
    control_unit cu (
        .opcode(instruction[6:0]),
        .funct3(instruction[14:12]),
        .funct7_5(instruction[30]),
        .reg_write(reg_write),
        .imm_src(imm_src),
        .alu_src(alu_src),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .branch_op(branch_op),
        .jump(jump),
        .jalr(jalr),
        .auipc(auipc),
        .alu_control(alu_control)
    );

    // 4. Immediate Generator
    imm_gen ig (
        .instr(instruction),
        .imm_src(imm_src),
        .imm_ext(imm_ext)
    );

    // 5. Datapath Unit (Registers, ALU, Data Memory)
    data_path dpu (
        .clk(clk),
        .reset(reset),
        .rs1(instruction[19:15]),
        .rs2(instruction[24:20]),
        .rd(instruction[11:7]),
        .reg_write(reg_write),
        .imm_ext(imm_ext),
        .alu_src(alu_src),
        .alu_control(alu_control),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .branch_op(branch_op),
        .jump(jump),
        .jalr(jalr),
        .auipc(auipc),
        .pc(pc),
        .pc_plus4(pc_plus4),
        .pc_src(pc_src),
        .target_pc(target_pc)
    );

endmodule