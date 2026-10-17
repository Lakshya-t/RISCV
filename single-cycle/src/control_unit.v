`timescale 1ns / 1ps

module control_unit (
    input  [6:0] opcode,
    input  [2:0] funct3,
    input        funct7_5,
    output reg   reg_write,
    output reg [2:0] imm_src,
    output reg   alu_src,
    output reg   mem_write,
    output reg   mem_to_reg,
    output reg   branch,
    output reg [2:0] branch_op,
    output reg   jump,
    output reg   jalr,
    output reg   auipc,
    output reg [3:0] alu_control
);

    always @(*) begin
        // Explicit defaults to prevent latches
        reg_write   = 1'b0;
        imm_src     = 3'b000;
        alu_src     = 1'b0;
        mem_write   = 1'b0;
        mem_to_reg  = 1'b0;
        branch      = 1'b0;
        branch_op   = funct3;
        jump        = 1'b0;
        jalr        = 1'b0;
        auipc       = 1'b0;
        alu_control = 4'b0000;

        case (opcode)
            // R-Type Instructions (opcode: 0110011)
            7'b0110011: begin
                reg_write = 1'b1;
                alu_src   = 1'b0;
                case (funct3)
                    3'b000: alu_control = funct7_5 ? 4'b0001 : 4'b0000; // SUB : ADD
                    3'b001: alu_control = 4'b0010;                      // SLL
                    3'b010: alu_control = 4'b0011;                      // SLT
                    3'b011: alu_control = 4'b0100;                      // SLTU
                    3'b100: alu_control = 4'b0101;                      // XOR
                    3'b101: alu_control = funct7_5 ? 4'b0111 : 4'b0110; // SRA : SRL
                    3'b110: alu_control = 4'b1000;                      // OR
                    3'b111: alu_control = 4'b1001;                      // AND
                endcase
            end

            // I-Type Arithmetic & Shifts (opcode: 0010011)
            7'b0010011: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                imm_src   = 3'b000;
                case (funct3)
                    3'b000: alu_control = 4'b0000;                      // ADDI
                    3'b001: alu_control = 4'b0010;                      // SLLI
                    3'b010: alu_control = 4'b0011;                      // SLTI
                    3'b011: alu_control = 4'b0100;                      // SLTIU
                    3'b100: alu_control = 4'b0101;                      // XORI
                    3'b101: alu_control = funct7_5 ? 4'b0111 : 4'b0110; // SRAI : SRLI
                    3'b110: alu_control = 4'b1000;                      // ORI
                    3'b111: alu_control = 4'b1001;                      // ANDI
                endcase
            end

            // Load Word (opcode: 0000011)
            7'b0000011: begin
                reg_write   = 1'b1;
                alu_src     = 1'b1;
                imm_src     = 3'b000;
                mem_to_reg  = 1'b1;
                alu_control = 4'b0000; // ADD base + offset
            end

            // Store Word (opcode: 0100011)
            7'b0100011: begin
                reg_write   = 1'b0;
                alu_src     = 1'b1;
                imm_src     = 3'b001;
                mem_write   = 1'b1;
                alu_control = 4'b0000; // ADD base + offset
            end

            // Conditional Branches (opcode: 1100011)
            7'b1100011: begin
                reg_write   = 1'b0;
                alu_src     = 1'b0;
                imm_src     = 3'b010;
                branch      = 1'b1;
                branch_op   = funct3;
                alu_control = 4'b0001; // SUB for comparison
            end

            // LUI (opcode: 0110111)
            7'b0110111: begin
                reg_write   = 1'b1;
                alu_src     = 1'b1;
                imm_src     = 3'b100;
                alu_control = 4'b1010; // Pass upper immediate
            end

            // AUIPC (opcode: 0010111)
            7'b0010111: begin
                reg_write   = 1'b1;
                alu_src     = 1'b1;
                imm_src     = 3'b100;
                auipc       = 1'b1;
                alu_control = 4'b0000; // PC + upper imm
            end

            // JAL (opcode: 1101111)
            7'b1101111: begin
                reg_write = 1'b1;
                imm_src   = 3'b011;
                jump      = 1'b1;
            end

            // JALR (opcode: 1100111)
            7'b1100111: begin
                reg_write = 1'b1;
                imm_src   = 3'b000;
                jump      = 1'b1;
                jalr      = 1'b1;
            end

            default: begin
                reg_write   = 1'b0;
                imm_src     = 3'b000;
                alu_src     = 1'b0;
                mem_write   = 1'b0;
                mem_to_reg  = 1'b0;
                branch      = 1'b0;
                branch_op   = 3'b000;
                jump        = 1'b0;
                jalr        = 1'b0;
                alu_control = 4'b0000;
            end
        endcase
    end

endmodule