`timescale 1ns / 1ps

module imm_gen (
    input  [31:0] instr,
    input  [2:0]  imm_src,
    output reg [31:0] imm_ext
);

    always @(*) begin
        case (imm_src)
            // I-Type immediate (Arithmetic, Loads, JALR)
            3'b000: imm_ext = {{20{instr[31]}}, instr[31:20]};

            // S-Type immediate (Stores)
            3'b001: imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            // B-Type immediate (Branches)
            3'b010: imm_ext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};

            // J-Type immediate (JAL)
            3'b011: imm_ext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

            // U-Type immediate (LUI, AUIPC)
            3'b100: imm_ext = {instr[31:12], 12'b0};

            default: imm_ext = 32'd0;
        endcase
    end

endmodule