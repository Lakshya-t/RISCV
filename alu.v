`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: 
// Module Name: alu
//////////////////////////////////////////////////////////////////////////////////


module alu(
            input [31:0] src1,          // operand 1 coming from register file read_data1 (rs1)
            input [31:0] src2,          // operand 2 coming from register file read_data2 (rs2)
            input [5:0] alu_control,    // 6-bit control code coming from control_unit
            input [31:0] imm_val_r,     // sign extended immediate value coming from top module
            input [3:0] shamt,          // shift amount coming from imm_val[3:0]
            output reg [31:0] result    // 32-bit output result going to datapath write_data_alu
    );
    
    always@(*)
        begin
            case(alu_control)
            
                // R-type operations (register - register)
                6'b000001: result = src1 + src2;           // ADD
                6'b000010: result = src1 - src2;           // SUB
                6'b000011: result = src1 << src2;          // SLL (shift left logical)
                6'b000100: result = (src1 < src2) ? 1 : 0; // SLT (set less than signed)
                6'b000101: result = (src1 < src2) ? 1 : 0; // SLTU (set less than unsigned)
                6'b000110: result = src1 ^ src2;           // XOR
                6'b000111: result = src1 >> src2;          // SRL (shift right logical)
                6'b001000: result = src1 >>> src2;         // SRA (shift right arithmetic)
                6'b001001: result = src1 | src2;           // OR
                6'b001010: result = (src1) & src2;         // AND
                          
                // I-type arithmetic and logic operations (register - immediate)
                6'b001011: result = src1 + imm_val_r;      // ADDI (add immediate)
                6'b001100: result = imm_val_r << shamt;    // SLLI (shift left logical immediate)
                6'b001101: result = (imm_val_r < src1) ? 1 : 0; // SLTI (set less than immediate)
                6'b001110: result = src1 & src2;           // ANDI
                6'b001111: result = src1 ^ imm_val_r;      // XORI (xor immediate)
                6'b010000: result = src1 >> imm_val_r;     // SRLI (shift right logical immediate)
                6'b010001: result = src1 | imm_val_r;      // ORI (or immediate)
                6'b010010: result = src1 & imm_val_r;      // ANDI (and immediate)
                               
                // B-type branch comparisons
                // For branch instructions, ALU outputs 1 if condition is true, 0 if false
                // This 1 or 0 goes to data_path.v to decide beq, bneq, bge, blt flags
                6'b011011: result = (src1 == src2) ? 1 : 0; // BEQ (branch if equal)
                6'b011100: result = (src1 != src2) ? 1 : 0; // BNE (branch if not equal)
                6'b011111: result = (src2 >= src1) ? 1 : 0; // BGE (branch if greater than or equal)
                6'b100000: result = (src1 < src2)  ? 1 : 0; // BLT (branch if less than)
                    
                default:   result = 0;
                                
            endcase
        end
 
endmodule