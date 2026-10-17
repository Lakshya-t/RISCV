`timescale 1ns / 1ps

module data_path (
    input         clk,
    input         reset,
    input  [4:0]  rs1,
    input  [4:0]  rs2,
    input  [4:0]  rd,
    input         reg_write,
    input  [31:0] imm_ext,
    input         alu_src,
    input  [3:0]  alu_control,
    input         mem_write,
    input         mem_to_reg,
    input         branch,
    input  [2:0]  branch_op,
    input         jump,
    input         jalr,
    input         auipc,
    input  [31:0] pc,
    input  [31:0] pc_plus4,
    output        pc_src,
    output [31:0] target_pc
);

    wire [31:0] src1;
    wire [31:0] src2_reg;
    wire [31:0] src2;
    wire [31:0] alu_src1;
    wire [31:0] alu_result;
    wire [31:0] mem_read_data;
    wire [31:0] write_back_data;
    wire zero, less_than, less_than_unsigned;
    reg  branch_taken;

    // Register File
    register_file rf (
        .clk(clk),
        .rst(reset),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .reg_write(reg_write),
        .write_data(write_back_data),
        .read_data1(src1),
        .read_data2(src2_reg)
    );

    // ALU input A selection (Register vs PC for AUIPC)
    assign alu_src1 = auipc ? pc : src1;

    // ALU input B selection (Register vs Immediate)
    assign src2 = alu_src ? imm_ext : src2_reg;

    // Arithmetic Logic Unit
    alu alu_inst (
        .src1(alu_src1),
        .src2(src2),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(zero),
        .less_than(less_than),
        .less_than_unsigned(less_than_unsigned)
    );

    // Data Memory RAM
    data_memory dmem (
        .clk(clk),
        .rst(reset),
        .addr(alu_result),
        .write_data(src2_reg),
        .mem_write(mem_write),
        .read_data(mem_read_data)
    );

    // Writeback Multiplexer:
    // If jump (JAL / JALR): write PC + 4 to rd
    // If load (LW): write mem_read_data to rd
    // Else: write alu_result to rd
    assign write_back_data = jump       ? pc_plus4 :
                             mem_to_reg ? mem_read_data :
                                          alu_result;

    // Branch condition evaluation
    always @(*) begin
        case (branch_op)
            3'b000: branch_taken = zero;                 // BEQ
            3'b001: branch_taken = ~zero;                // BNE
            3'b100: branch_taken = less_than;           // BLT
            3'b101: branch_taken = ~less_than;          // BGE
            3'b110: branch_taken = less_than_unsigned;  // BLTU
            3'b111: branch_taken = ~less_than_unsigned; // BGEU
            default: branch_taken = 1'b0;
        endcase
    end

    // Target PC Calculation
    assign target_pc = jalr ? ((src1 + imm_ext) & ~32'd1) : (pc + imm_ext);
    assign pc_src = (branch & branch_taken) | jump;

endmodule