`timescale 1ns / 1ps

module instruction_memory (
    input  [31:0] addr,
    output [31:0] read_data
);

    // 1024-word instruction memory (4 KB)
    reg [31:0] memory [0:1023];
    integer i;

    // Asynchronous read (word-aligned addr[11:2])
    assign read_data = memory[addr[11:2]];

    initial begin
        // Initialize memory with NOPs (addi x0, x0, 0)
        for (i = 0; i < 1024; i = i + 1) begin
            memory[i] = 32'h00000013;
        end

        // -------------------------------------------------------------
        // Standard RV32I Test Program
        // -------------------------------------------------------------
        memory[0]  = 32'h00500293; // addi x5,  x0, 5        (x5 = 5)
        memory[1]  = 32'h00300313; // addi x6,  x0, 3        (x6 = 3)
        memory[2]  = 32'h006283b3; // add  x7,  x5, x6       (x7 = 8)
        memory[3]  = 32'h40628433; // sub  x8,  x5, x6       (x8 = 2)
        memory[4]  = 32'h0062f4b3; // and  x9,  x5, x6       (x9 = 1)
        memory[5]  = 32'h0062e533; // or   x10, x5, x6       (x10 = 7)
        memory[6]  = 32'h0062c5b3; // xor  x11, x5, x6       (x11 = 6)
        memory[7]  = 32'h00629633; // sll  x12, x5, x6       (x12 = 40)
        memory[8]  = 32'h005326b3; // slt  x13, x6, x5       (x13 = 1)
        memory[9]  = 32'h00702023; // sw   x7,  0(x0)        (Store 8 into Data_RAM[0])
        memory[10] = 32'h00002703; // lw   x14, 0(x0)        (Load 8 from Data_RAM[0])
        memory[11] = 32'h00270793; // addi x15, x14, 2       (x15 = 10)
        memory[12] = 32'h12345837; // lui  x16, 0x12345      (x16 = 0x12345000)
        memory[13] = 32'h00628463; // beq  x5,  x6, 8        (5 == 3 is FALSE -> no branch)
        memory[14] = 32'h00629463; // bne  x5,  x6, 8        (5 != 3 is TRUE -> branch to index 16)
        memory[15] = 32'h06300893; // addi x17, x0, 99       (Skipped by branch!)
        memory[16] = 32'h008000ef; // jal  x1,  8            (Jumps to index 18, x1 = PC + 4)
        memory[17] = 32'h06300913; // addi x18, x0, 99       (Skipped by JAL!)
        memory[18] = 32'h02a00993; // addi x19, x0, 42       (x19 = 42, confirms complete execution)
        memory[19] = 32'h00000013; // nop
    end

endmodule