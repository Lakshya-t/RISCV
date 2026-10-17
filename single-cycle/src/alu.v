`timescale 1ns / 1ps

module alu (
    input  [31:0] src1,
    input  [31:0] src2,
    input  [3:0]  alu_control,
    output reg [31:0] result,
    output        zero,
    output        less_than,
    output        less_than_unsigned
);

    // Branch condition comparison flags
    assign zero = (src1 == src2);
    assign less_than = ($signed(src1) < $signed(src2));
    assign less_than_unsigned = (src1 < src2);

    always @(*) begin
        case (alu_control)
            4'b0000: result = src1 + src2;                               // ADD / ADDI / Load / Store address
            4'b0001: result = src1 - src2;                               // SUB
            4'b0010: result = src1 << src2[4:0];                         // SLL / SLLI (Shift left logical)
            4'b0011: result = ($signed(src1) < $signed(src2)) ? 32'd1 : 32'd0; // SLT / SLTI (Set less than signed)
            4'b0100: result = (src1 < src2) ? 32'd1 : 32'd0;             // SLTU / SLTIU (Set less than unsigned)
            4'b0101: result = src1 ^ src2;                               // XOR / XORI
            4'b0110: result = src1 >> src2[4:0];                         // SRL / SRLI (Shift right logical)
            4'b0111: result = $signed(src1) >>> src2[4:0];               // SRA / SRAI (Shift right arithmetic)
            4'b1000: result = src1 | src2;                               // OR / ORI
            4'b1001: result = src1 & src2;                               // AND / ANDI
            4'b1010: result = src2;                                      // LUI (Pass immediate)
            default: result = 32'd0;
        endcase
    end

endmodule