`timescale 1ns / 1ps

module Fetch_Cycle (
    input         clk,
    input         rst,
    input         stall_f,
    input         stall_d,
    input         flush_d,
    input         pc_src_e,
    input  [31:0] pc_target_e,
    output reg [31:0] instr_d,
    output reg [31:0] pc_d,
    output reg [31:0] pc_plus4_d
);

    wire [31:0] pc_next;
    wire [31:0] pc_f;
    wire [31:0] pc_plus4_f;
    wire [31:0] instr_f;

    // Next PC Selection: PC+4 vs Branch/Jump Target
    Mux pc_mux (
        .a(pc_plus4_f),
        .b(pc_target_e),
        .s(pc_src_e),
        .c(pc_next)
    );

    // Program Counter register with stall enable
    PC_Module pc_reg (
        .clk(clk),
        .rst(rst),
        .en(~stall_f),
        .pc_next(pc_next),
        .pc(pc_f)
    );

    // PC Incrementer (+4)
    PC_Adder pc_adder_inst (
        .a(pc_f),
        .b(32'd4),
        .c(pc_plus4_f)
    );

    // Instruction Memory (ROM)
    Instruction_Memory imem (
        .rst(rst),
        .addr(pc_f),
        .read_data(instr_f)
    );

    // IF/ID Pipeline Register: Synthesizable priority (async reset > sync flush > enable)
    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            instr_d    <= 32'h00000013; // NOP (addi x0, x0, 0)
            pc_d       <= 32'd0;
            pc_plus4_d <= 32'd0;
        end else if (flush_d) begin
            instr_d    <= 32'h00000013; // NOP (flush bubble)
            pc_d       <= 32'd0;
            pc_plus4_d <= 32'd0;
        end else if (!stall_d) begin
            instr_d    <= instr_f;
            pc_d       <= pc_f;
            pc_plus4_d <= pc_plus4_f;
        end
    end

endmodule
