`timescale 1ns / 1ps

module Sign_Extend (
    input  [31:7] instr,
    input  [2:0]  imm_src,
    output reg [31:0] imm_ext
);

    always @(*) begin
        case (imm_src)
            // I-Type: 12-bit signed immediate (ADDI, SLTI, LW, etc.)
            3'b000: imm_ext = {{20{instr[31]}}, instr[31:20]};

            // S-Type: 12-bit signed store immediate (SW, SB)
            3'b001: imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            // B-Type: 13-bit signed branch offset with LSB 0 (BEQ, BNE, BLT, BGE)
            3'b010: imm_ext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};

            // J-Type: 21-bit signed jump offset with LSB 0 (JAL)
            3'b011: imm_ext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

            // U-Type: 20-bit upper immediate shifted by 12 (LUI)
            3'b100: imm_ext = {instr[31:12], 12'b0};

            default: imm_ext = 32'd0;
        endcase
    end

endmodule