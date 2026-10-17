`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: 
// Module Name: imm_gen
//////////////////////////////////////////////////////////////////////////////////

// immediate generator module
// extracts the 12-bit immediate field from I-type instructions (opcode 0010011)
// Note: In top_riscv.v, immediate extraction for all instruction types (I, B, U, J)
// is handled directly using continuous assign statements.

module imm_gen(
    input [31:0] instr_memory,         // 32-bit instruction code
    output [31:0] imm_val_r            // sign-extended immediate output
    );
    
    reg [6:0] opcode; 
    reg [31:0] imm_val_reg;
    
    // extract 7-bit opcode field (bits 6:0 of instruction)
    always@(*)
        begin
            opcode = instr_memory[6:0];
        end
        
    // decode immediate based on opcode
    always@(*)
        begin
            // if I-type arithmetic instruction (e.g. ADDI, SLTI, ORI)
            if(opcode == 7'b001_0011)
                begin
                    // extract bits 31:20 (12-bit immediate)
                    imm_val_reg = {{20{instr_memory[31]}}, instr_memory[31:20]};
                end
            else
                begin
                    imm_val_reg = 32'd0;
                end
        end
        
    assign imm_val_r = imm_val_reg;
                              
endmodule