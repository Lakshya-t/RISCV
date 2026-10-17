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
        // 1. Basic Immediate Arithmetic
        memory[0]  = 32'h00500293; // addi x5,  x0, 5        (x5 = 5)
        memory[1]  = 32'h00300313; // addi x6,  x0, 3        (x6 = 3)

        // 2. RAW Dependencies & Data Forwarding
        memory[2]  = 32'h006283b3; // add  x7,  x5, x6       (x7 = 8, tests EX-to-EX forwarding)
        memory[3]  = 32'h40628433; // sub  x8,  x5, x6       (x8 = 2, tests subtraction)
        memory[4]  = 32'h0062f4b3; // and  x9,  x5, x6       (x9 = 1, tests bitwise AND)
        memory[5]  = 32'h0062e533; // or   x10, x5, x6       (x10 = 7, tests bitwise OR)
        memory[6]  = 32'h0062c5b3; // xor  x11, x5, x6       (x11 = 6, tests bitwise XOR)
        memory[7]  = 32'h00629633; // sll  x12, x5, x6       (x12 = 40, shift left logical)
        memory[8]  = 32'h005326b3; // slt  x13, x6, x5       (x13 = 1, set less than signed)

        // 3. Memory Access & Load-Use Hazard Stalling
        memory[9]  = 32'h00702023; // sw   x7,  0(x0)        (Store 8 into Data_RAM[0])
        memory[10] = 32'h00002703; // lw   x14, 0(x0)        (Load from Data_RAM[0])
        memory[11] = 32'h00270793; // addi x15, x14, 2       (x15 = 10, triggers 1-cycle stall bubble)

        // 4. Upper Immediate
        memory[12] = 32'h12345837; // lui  x16, 0x12345      (x16 = 0x12345000)

        // 5. Control Hazards: Branch NOT Taken
        memory[13] = 32'h00628463; // beq  x5,  x6, 8        (5 == 3 is FALSE -> fall through)

        // 6. Control Hazards: Branch TAKEN & Pipeline Flush
        memory[14] = 32'h00629463; // bne  x5,  x6, 8        (5 != 3 is TRUE -> jumps to index 16)
        memory[15] = 32'h06300893; // addi x17, x0, 99       (Flushed! x17 must remain 0)

        // 7. JAL Jump and Link & Pipeline Flush
        memory[16] = 32'h008000ef; // jal  x1,  8            (Jumps to index 18, x1 = PC + 4)
        memory[17] = 32'h06300913; // addi x18, x0, 99       (Flushed! x18 must remain 0)

        // 8. Final Success Check
        memory[18] = 32'h02a00993; // addi x19, x0, 42       (x19 = 42, confirms complete execution)
        memory[19] = 32'h00000013; // nop                    (addi x0, x0, 0)
    end

endmodule