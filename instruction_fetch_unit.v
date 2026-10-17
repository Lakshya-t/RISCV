`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: INSTRUCTION FETCH UNIT
// Module Name: instruction_fetch_unit
//////////////////////////////////////////////////////////////////////////////////


module instruction_fetch_unit(
    input clk,                         // clock source from top module
    input reset,                       // reset signal from top module
    input [31:0] imm_address,          // branch offset from top module (imm_val_branch_top)
    input [31:0] imm_address_jump,     // jump offset from top module (imm_val_jump)
    input beq,                         // beq taken flag from datapath
    input bneq,                        // bne taken flag from datapath
    input bge,                         // bge taken flag from datapath
    input blt,                         // blt taken flag from datapath
    input jump,                        // jump enable signal from control unit
    output reg [31:0] pc,              // program counter sent to instruction memory
    output reg [31:0] current_pc       // return address (pc + 4) stored for jal link
);

///////////////////////// LOGIC FOR INCREMENTING PROGRAMME COUNTER /////////////////////////

always@(posedge clk)
begin
    // reset sets PC to 0 to start execution from first instruction
    if(reset == 1)
        begin
            pc <= 0;
        end
    // normal execution: no branch or jump, fetch next sequential instruction (pc + 4)
    else if(beq == 0 && bneq == 0 && bge == 0 && blt == 0 && jump == 0)
        pc <= pc + 4;

    // branch condition met: add branch immediate offset to pc
    else if(beq == 1 || bneq == 1 || bge == 1 || blt == 1)
        pc <= pc + imm_address;

    // unconditional jump: add jump immediate offset to pc
    else if(jump)
        pc <= pc + imm_address_jump;
end

/////////////////// LOGIC FOR STORING RETURN ADDRESS OF PROGRAMME COUNTER ///////////////////

always@(posedge clk)
begin
    if(reset)
        begin
            current_pc <= 0;
        end
    // while running normally, keep updating return address as next pc (pc + 4)
    else if(reset == 0 && jump == 0)
        current_pc <= pc + 4;
    // during jump, latch current_pc so it holds the return address for jal
    else
        current_pc <= current_pc;
end

endmodule