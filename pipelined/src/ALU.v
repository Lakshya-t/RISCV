`timescale 1ns / 1ps

module ALU (
    input  [31:0] a,
    input  [31:0] b,
    input  [3:0]  alu_control,
    output reg [31:0] alu_result,
    output        zero,
    output        less_than,
    output        less_than_unsigned
);

    // Branch comparison flags
    assign zero = (a == b);
    assign less_than = ($signed(a) < $signed(b));
    assign less_than_unsigned = (a < b);

    // ALU operation execution
    always @(*) begin
        case (alu_control)
            4'b0000: alu_result = a + b;                               // ADD / ADDI / Address calculation
            4'b0001: alu_result = a - b;                               // SUB
            4'b0010: alu_result = a << b[4:0];                         // SLL / SLLI (Shift left logical)
            4'b0011: alu_result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT / SLTI (Set less than signed)
            4'b0100: alu_result = (a < b) ? 32'd1 : 32'd0;             // SLTU / SLTIU (Set less than unsigned)
            4'b0101: alu_result = a ^ b;                               // XOR / XORI
            4'b0110: alu_result = a >> b[4:0];                         // SRL / SRLI (Shift right logical)
            4'b0111: alu_result = $signed(a) >>> b[4:0];               // SRA / SRAI (Shift right arithmetic)
            4'b1000: alu_result = a | b;                               // OR / ORI
            4'b1001: alu_result = a & b;                               // AND / ANDI
            4'b1010: alu_result = b;                                   // LUI (Pass upper immediate)
            default: alu_result = 32'd0;
        endcase
    end

endmodule