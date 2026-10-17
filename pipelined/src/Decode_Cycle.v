`timescale 1ns / 1ps

module Decode_Cycle (
    input         clk,
    input         rst,
    input         flush_e,
    input  [31:0] instr_d,
    input  [31:0] pc_d,
    input  [31:0] pc_plus4_d,
    input         reg_write_w,
    input  [4:0]  rd_w,
    input  [31:0] result_w,
    output [4:0]  rs1_d,
    output [4:0]  rs2_d,
    output reg    reg_write_e,
    output reg    alu_src_e,
    output reg    mem_write_e,
    output reg [1:0] result_src_e,
    output reg    branch_e,
    output reg [2:0] branch_op_e,
    output reg    jump_e,
    output reg    jalr_e,
    output reg [3:0] alu_control_e,
    output reg [31:0] rd1_e,
    output reg [31:0] rd2_e,
    output reg [31:0] imm_ext_e,
    output reg [4:0]  rs1_e,
    output reg [4:0]  rs2_e,
    output reg [4:0]  rd_e,
    output reg [31:0] pc_e,
    output reg [31:0] pc_plus4_e
);

    // Combinational signals in Decode stage
    wire reg_write_d, alu_src_d, mem_write_d, branch_d, jump_d, jalr_d;
    wire [1:0] result_src_d;
    wire [2:0] imm_src_d;
    wire [2:0] branch_op_d;
    wire [3:0] alu_control_d;
    wire [31:0] rd1_d, rd2_d, imm_ext_d;

    assign rs1_d = instr_d[19:15];
    assign rs2_d = instr_d[24:20];

    // Main Control Unit
    Control_Unit_Top control_unit (
        .opcode(instr_d[6:0]),
        .funct3(instr_d[14:12]),
        .funct7_5(instr_d[30]),
        .reg_write(reg_write_d),
        .imm_src(imm_src_d),
        .alu_src(alu_src_d),
        .mem_write(mem_write_d),
        .result_src(result_src_d),
        .branch(branch_d),
        .branch_op(branch_op_d),
        .alu_control(alu_control_d),
        .jump(jump_d),
        .jalr(jalr_d)
    );

    // Register File (32 x 32-bit registers)
    Register_File rf (
        .clk(clk),
        .rst(rst),
        .reg_write(reg_write_w),
        .rs1(instr_d[19:15]),
        .rs2(instr_d[24:20]),
        .rd(rd_w),
        .write_data(result_w),
        .read_data1(rd1_d),
        .read_data2(rd2_d)
    );

    // Immediate Sign Extension
    Sign_Extend imm_ext_unit (
        .instr(instr_d[31:7]),
        .imm_src(imm_src_d),
        .imm_ext(imm_ext_d)
    );

    // ID/EX Pipeline Register: Synthesizable priority (async reset > sync flush > register)
    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            reg_write_e   <= 1'b0;
            alu_src_e     <= 1'b0;
            mem_write_e   <= 1'b0;
            result_src_e  <= 2'b00;
            branch_e      <= 1'b0;
            branch_op_e   <= 3'b000;
            jump_e        <= 1'b0;
            jalr_e        <= 1'b0;
            alu_control_e <= 4'b0000;
            rd1_e         <= 32'd0;
            rd2_e         <= 32'd0;
            imm_ext_e     <= 32'd0;
            rs1_e         <= 5'd0;
            rs2_e         <= 5'd0;
            rd_e          <= 5'd0;
            pc_e          <= 32'd0;
            pc_plus4_e    <= 32'd0;
        end else if (flush_e) begin
            reg_write_e   <= 1'b0;
            alu_src_e     <= 1'b0;
            mem_write_e   <= 1'b0;
            result_src_e  <= 2'b00;
            branch_e      <= 1'b0;
            branch_op_e   <= 3'b000;
            jump_e        <= 1'b0;
            jalr_e        <= 1'b0;
            alu_control_e <= 4'b0000;
            rd1_e         <= 32'd0;
            rd2_e         <= 32'd0;
            imm_ext_e     <= 32'd0;
            rs1_e         <= 5'd0;
            rs2_e         <= 5'd0;
            rd_e          <= 5'd0;
            pc_e          <= 32'd0;
            pc_plus4_e    <= 32'd0;
        end else begin
            reg_write_e   <= reg_write_d;
            alu_src_e     <= alu_src_d;
            mem_write_e   <= mem_write_d;
            result_src_e  <= result_src_d;
            branch_e      <= branch_d;
            branch_op_e   <= branch_op_d;
            jump_e        <= jump_d;
            jalr_e        <= jalr_d;
            alu_control_e <= alu_control_d;
            rd1_e         <= rd1_d;
            rd2_e         <= rd2_d;
            imm_ext_e     <= imm_ext_d;
            rs1_e         <= instr_d[19:15];
            rs2_e         <= instr_d[24:20];
            rd_e          <= instr_d[11:7];
            pc_e          <= pc_d;
            pc_plus4_e    <= pc_plus4_d;
        end
    end

endmodule