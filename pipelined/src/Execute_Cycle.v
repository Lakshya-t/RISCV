`timescale 1ns / 1ps

module Execute_Cycle (
    input         clk,
    input         rst,
    input         reg_write_e,
    input         alu_src_e,
    input         mem_write_e,
    input  [1:0]  result_src_e,
    input         branch_e,
    input  [2:0]  branch_op_e,
    input         jump_e,
    input  [3:0]  alu_control_e,
    input  [31:0] rd1_e,
    input  [31:0] rd2_e,
    input  [31:0] imm_ext_e,
    input  [4:0]  rd_e,
    input  [31:0] pc_e,
    input  [31:0] pc_plus4_e,
    input  [31:0] result_w,
    input  [1:0]  forward_a_e,
    input  [1:0]  forward_b_e,
    output        pc_src_e,
    output [31:0] pc_target_e,
    output reg    reg_write_m,
    output reg    mem_write_m,
    output reg [1:0] result_src_m,
    output reg [4:0]  rd_m,
    output reg [31:0] pc_plus4_m,
    output reg [31:0] write_data_m,
    output reg [31:0] alu_result_m
);

    wire [31:0] src_a;
    wire [31:0] src_b_forwarded;
    wire [31:0] src_b;
    wire [31:0] alu_out;
    wire zero, less_than, less_than_unsigned;
    reg  branch_taken;

    // 3:1 Mux for Operand A Forwarding
    Mux_3_by_1 forward_mux_a (
        .a(rd1_e),
        .b(result_w),
        .c(alu_result_m),
        .s(forward_a_e),
        .d(src_a)
    );

    // 3:1 Mux for Operand B Forwarding
    Mux_3_by_1 forward_mux_b (
        .a(rd2_e),
        .b(result_w),
        .c(alu_result_m),
        .s(forward_b_e),
        .d(src_b_forwarded)
    );

    // ALU Source Multiplexer (Register operand vs Immediate)
    Mux alu_src_mux (
        .a(src_b_forwarded),
        .b(imm_ext_e),
        .s(alu_src_e),
        .c(src_b)
    );

    // Arithmetic Logic Unit (ALU)
    ALU alu_inst (
        .a(src_a),
        .b(src_b),
        .alu_control(alu_control_e),
        .alu_result(alu_out),
        .zero(zero),
        .less_than(less_than),
        .less_than_unsigned(less_than_unsigned)
    );

    // Branch Target Calculation: PC + Immediate
    PC_Adder branch_adder (
        .a(pc_e),
        .b(imm_ext_e),
        .c(pc_target_e)
    );

    // Branch condition evaluation
    always @(*) begin
        case (branch_op_e)
            3'b000: branch_taken = zero;                 // BEQ
            3'b001: branch_taken = ~zero;                // BNE
            3'b100: branch_taken = less_than;           // BLT
            3'b101: branch_taken = ~less_than;          // BGE
            3'b110: branch_taken = less_than_unsigned;  // BLTU
            3'b111: branch_taken = ~less_than_unsigned; // BGEU
            default: branch_taken = 1'b0;
        endcase
    end

    // Next PC selection flag
    assign pc_src_e = (branch_e & branch_taken) | jump_e;

    // EX/MEM Pipeline Register
    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            reg_write_m  <= 1'b0;
            mem_write_m  <= 1'b0;
            result_src_m <= 2'b00;
            rd_m         <= 5'd0;
            pc_plus4_m   <= 32'd0;
            write_data_m <= 32'd0;
            alu_result_m <= 32'd0;
        end else begin
            reg_write_m  <= reg_write_e;
            mem_write_m  <= mem_write_e;
            result_src_m <= result_src_e;
            rd_m         <= rd_e;
            pc_plus4_m   <= pc_plus4_e;
            write_data_m <= src_b_forwarded;
            alu_result_m <= alu_out;
        end
    end

endmodule