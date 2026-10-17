`timescale 1ns / 1ps

module Instruction_Memory (
    input         rst,
    input  [31:0] addr,
    output [31:0] read_data
);

    // 1024-word instruction memory (4 KB)
    reg [31:0] memory [0:1023];
    integer i;

    // Asynchronous instruction read with word alignment (addr[31:2])
    assign read_data = (rst == 1'b0) ? 32'd0 : memory[addr[11:2]];

    initial begin
        // Initialize instruction memory with NOPs (addi x0, x0, 0)
        for (i = 0; i < 1024; i = i + 1) begin
            memory[i] = 32'h00000013;
        end

        // ---------------------------------------------------------------------
        // Comprehensive Pipeline Verification Benchmark Suite
        // ---------------------------------------------------------------------
        // 1. Basic Arithmetic & Immediate Instructions
        memory[0]  = 32'h00500293; // addi x5, x0, 5        (x5 = 5)
        memory[1]  = 32'h00300313; // addi x6, x0, 3        (x6 = 3)

        // 2. RAW Dependencies & Data Forwarding
        memory[2]  = 32'h006283b3; // add  x7, x5, x6       (x7 = 8)
        memory[3]  = 32'h40638433; // sub  x8, x7, x6       (x8 = 5, distance 1 forwarding)
        memory[4]  = 32'h0082f4b3; // and  x9, x5, x8       (x9 = 5, distance 2 forwarding)
        memory[5]  = 32'h0062e533; // or   x10, x5, x6      (x10 = 7)
        memory[6]  = 32'h0062c5b3; // xor  x11, x5, x6      (x11 = 6)

        // 3. Shifts (including shift amounts >= 16)
        memory[7]  = 32'h01129613; // slli x12, x5, 17      (x12 = 5 << 17 = 0x000a0000)
        memory[8]  = 32'h01065693; // srli x13, x12, 16     (x13 = 10)
        memory[9]  = 32'h00629133; // sll  x2, x5, x6       (x2 = 5 << 3 = 40)
        memory[10] = 32'h006151b3; // srl  x3, x2, x6       (x3 = 40 >> 3 = 5)

        // 4. Negative Arithmetic, Arithmetic Shifts & Signed/Unsigned Comparisons
        memory[11] = 32'hff000213; // addi x4, x0, -16      (x4 = 0xfffffff0 = -16)
        memory[12] = 32'h40625a33; // sra  x20, x4, x6      (x20 = (-16) >>> 3 = -2 = 0xfffffffe)
        memory[13] = 32'h40225a93; // srai x21, x4, 2       (x21 = (-16) >>> 2 = -4 = 0xfffffffc)
        memory[14] = 32'h00522b33; // slt  x22, x4, x5      (-16 < 5 signed -> 1)
        memory[15] = 32'h00523bb3; // sltu x23, x4, x5      (0xfffffff0 < 5 unsigned -> 0)
        memory[16] = 32'hff622c13; // slti x24, x4, -10     (-16 < -10 signed -> 1)
        memory[17] = 32'h00a23c93; // sltiu x25, x4, 10     (0xfffffff0 < 10 unsigned -> 0)

        // 5. Memory Operations, Store-Data Forwarding & Load-Use Hazard into Branch
        memory[18] = 32'h05800d13; // addi x26, x0, 88      (x26 = 88)
        memory[19] = 32'h01a02023; // sw   x26, 0(x0)       (store-data forwarding from EX/MEM)
        memory[20] = 32'h00002703; // lw   x14, 0(x0)       (x14 = 88 from RAM[0])
        memory[21] = 32'h00c70793; // addi x15, x14, 12     (load-use stall -> x15 = 100)
        memory[22] = 32'h00f02223; // sw   x15, 4(x0)       (store 100 into RAM[1])
        memory[23] = 32'h00402d83; // lw   x27, 4(x0)       (x27 = 100 from RAM[1])
        memory[24] = 32'h00fd8463; // beq  x27, x15, 8      (load-use hazard into branch -> TAKEN)
        memory[25] = 32'h06300913; // addi x18, x0, 99      (FLUSHED / SKIPPED)

        // 6. Upper Immediates (LUI & AUIPC)
        memory[26] = 32'h12345837; // lui   x16, 0x12345    (x16 = 0x12345000)
        memory[27] = 32'h00002e17; // auipc x28, 0x2        (x28 = PC + 0x2000 = 0x0000206c)

        // 7. Branches - NOT TAKEN Tests (BEQ, BNE, BLT, BGE, BLTU, BGEU)
        memory[28] = 32'h00628463; // beq  x5, x6, 8        (5 == 3 FALSE -> NOT TAKEN)
        memory[29] = 32'h00529463; // bne  x5, x5, 8        (5 != 5 FALSE -> NOT TAKEN)
        memory[30] = 32'h0042c463; // blt  x5, x4, 8        (5 < -16 FALSE -> NOT TAKEN)
        memory[31] = 32'h00525463; // bge  x4, x5, 8        (-16 >= 5 FALSE -> NOT TAKEN)
        memory[32] = 32'h00526463; // bltu x4, x5, 8        (0xfffffff0 < 5 FALSE -> NOT TAKEN)
        memory[33] = 32'h0042f463; // bgeu x5, x4, 8        (5 >= 0xfffffff0 FALSE -> NOT TAKEN)

        // 8. Branches - TAKEN Tests (BNE, BLT, BGE, BLTU, BGEU)
        memory[34] = 32'h00629463; // bne  x5, x6, 8        (5 != 3 TRUE -> TAKEN)
        memory[35] = 32'h05b00913; // addi x18, x0, 91      (FLUSHED / SKIPPED)
        memory[36] = 32'h00524463; // blt  x4, x5, 8        (-16 < 5 TRUE -> TAKEN)
        memory[37] = 32'h05c00913; // addi x18, x0, 92      (FLUSHED / SKIPPED)
        memory[38] = 32'h0042d463; // bge  x5, x4, 8        (5 >= -16 TRUE -> TAKEN)
        memory[39] = 32'h05d00913; // addi x18, x0, 93      (FLUSHED / SKIPPED)
        memory[40] = 32'h0042e463; // bltu x5, x4, 8        (5 < 0xfffffff0 TRUE -> TAKEN)
        memory[41] = 32'h05e00913; // addi x18, x0, 94      (FLUSHED / SKIPPED)
        memory[42] = 32'h00527463; // bgeu x4, x5, 8        (0xfffffff0 >= 5 TRUE -> TAKEN)
        memory[43] = 32'h05f00913; // addi x18, x0, 95      (FLUSHED / SKIPPED)

        // 9. Backward Branch Loop (executes twice: x29 = 2 -> 1 -> 0)
        memory[44] = 32'h00200e93; // addi x29, x0, 2       (x29 = 2)
        memory[45] = 32'hfffe8e93; // addi x29, x29, -1     (decrement counter)
        memory[46] = 32'hfe0e9ee3; // bne  x29, x0, -4      (BACKWARD BRANCH to index 45)

        // 10. JAL Jump and Link
        memory[47] = 32'h008000ef; // jal  x1, 8            (x1 = PC + 4 = 192 = 0x000000c0, jumps to 49)
        memory[48] = 32'h06000913; // addi x18, x0, 96      (FLUSHED / SKIPPED)

        // 11. JALR Jump and Link Register (with bit 0 cleared)
        memory[49] = 32'h0d100f13; // addi x30, x0, 209     (odd target 209 to test bit 0 clear)
        memory[50] = 32'h000f08e7; // jalr x17, x30, 0      (target=(209)&~1=208, link x17=PC+4=204)
        memory[51] = 32'h06100913; // addi x18, x0, 97      (FLUSHED / SKIPPED)

        // 12. Final Success Marker
        memory[52] = 32'h02a00993; // addi x19, x0, 42      (x19 = 42, confirms complete execution)
        memory[53] = 32'h00000013; // nop
        memory[54] = 32'h00000013; // nop
        memory[55] = 32'h00000013; // nop
    end

endmodule