`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Design Name: INSTRUCTION_MEMORY
// Module Name: instruction_memory
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


module instruction_memory(
    input clk,
    input [31:0] pc,                    // program counter coming from ifu
    input reset,                        // active-high reset
    output [31:0] instruction_code      // 32-bit fetched instruction going to cu and datapath
    );
    
    // byte-addressable memory array: 109 locations (bytes 0 to 108)
    reg [7:0] memory [108:0];
    
    // instruction fetching from memory: little-endian format
    // byte at pc is the least significant byte (bits 7:0), byte at pc+3 is the most significant byte (bits 31:24)
    assign instruction_code = {memory[pc+3], memory[pc+2], memory[pc+1], memory[pc]}; 
    
    always@(posedge clk)
        begin
            if(reset == 1)
                begin
                    // R-type instructions (opcode: 0110011)
                    
                    // add: 0x00940333 -> add x6, x8, x9
                    memory[3] = 8'h00;
                    memory[2] = 8'h94;
                    memory[1] = 8'h03;
                    memory[0] = 8'h33;

                    // sub: 0x800100b3 -> sub x1, x2, x0
                    memory[7] = 8'h80;
                    memory[6] = 8'h01;
                    memory[5] = 8'h00;
                    memory[4] = 8'hb3;

                    // sll: 0x00209133 -> sll x2, x1, x2
                    memory[11] = 8'h00;
                    memory[10] = 8'h20;
                    memory[9]  = 8'h91;
                    memory[8]  = 8'h33;

                    // xor: 0x00c54ab3 -> xor x21, x10, x12
                    memory[15] = 8'h00;
                    memory[14] = 8'hc5;
                    memory[13] = 8'h4a;
                    memory[12] = 8'hb3;

                    // srl: 0x00c55ab3 -> srl x21, x10, x12
                    memory[19] = 8'h00;
                    memory[18] = 8'hc5;
                    memory[17] = 8'h5a;
                    memory[16] = 8'hb3;

                    // sra: 0x01bd5f33 -> sra x30, x26, x27
                    memory[23] = 8'h01;
                    memory[22] = 8'hbd;
                    memory[21] = 8'h5f;
                    memory[20] = 8'h33;

                    // or: 0x00d67fb3 -> or x31, x12, x13
                    memory[27] = 8'h00;
                    memory[26] = 8'hd6;
                    memory[25] = 8'h7f;
                    memory[24] = 8'hb3;

                    // and: 0x00f768b3 -> and x17, x14, x15
                    memory[31] = 8'h00;
                    memory[30] = 8'hf7;
                    memory[29] = 8'h68;
                    memory[28] = 8'hb3;
                   
                    // I-type arithmetic / logical instructions (opcode: 0010011)
                    
                    // addi: 0x00a08513 -> addi x10, x1, 10
                    memory[35] = 8'h00;
                    memory[34] = 8'ha0;
                    memory[33] = 8'h85;
                    memory[32] = 8'h13;
                    
                    // slli: 0x00419313 -> slli x6, x3, 4
                    memory[39] = 8'h00;
                    memory[38] = 8'h41;
                    memory[37] = 8'h93;
                    memory[36] = 8'h13;
                    
                    // xori: 0x03f2c726
                    memory[43] = 8'h03;
                    memory[42] = 8'hf2;
                    memory[41] = 8'hc7;
                    memory[40] = 8'h26;
                                
                    // slti: 0x00a12093 -> slti x1, x2, 10
                    memory[47] = 8'h00;
                    memory[46] = 8'ha1;
                    memory[45] = 8'h20;
                    memory[44] = 8'h93;
                    
                    // srli: 0x00315093 -> srli x1, x2, 3
                    memory[51] = 8'h00;
                    memory[50] = 8'h31;
                    memory[49] = 8'h50;
                    memory[48] = 8'h93;
                    
                    // ori: 0x00f16093 -> ori x1, x2, 15
                    memory[55] = 8'h00;
                    memory[54] = 8'hf1;
                    memory[53] = 8'h60;
                    memory[52] = 8'h93;
                      
                    // andi: 0x00f17093 -> andi x1, x2, 15
                    memory[59] = 8'h00;
                    memory[58] = 8'hf1;
                    memory[57] = 8'h70;
                    memory[56] = 8'h93;
                    
                    // Load instructions (opcode: 0000011)
                    // lw: 0x00430283 -> lw x5, 4(x6)
                    memory[63] = 8'h00;
                    memory[62] = 8'h43;
                    memory[61] = 8'h02;
                    memory[60] = 8'h83;
                    
                    // Store instructions (opcode: 0100011)
                    // sw: 0x00732823 -> sw x7, 16(x6)
                    memory[67] = 8'h00;
                    memory[66] = 8'h73;
                    memory[65] = 8'h28;
                    memory[64] = 8'h23;
                    
                    // Branch instructions (opcode: 1100011)
                    
                    // beq: 0x00410063 -> beq x2, x4, offset
                    memory[71] = 8'h00;
                    memory[70] = 8'h41;
                    memory[69] = 8'h00;
                    memory[68] = 8'h63;
                    
                    // bne: 0x00209463 -> bne x1, x2, offset (jumps to PC = 80)
                    memory[75] = 8'h00;
                    memory[74] = 8'h20;
                    memory[73] = 8'h94;
                    memory[72] = 8'h63;
                    
                    // bge: 0x0041a463 -> bge x3, x4, offset
                    memory[83] = 8'h00;
                    memory[82] = 8'h41;
                    memory[81] = 8'ha4;
                    memory[80] = 8'h63;
                    
                    // blt: 0x0020c163 -> blt x1, x2, offset
                    memory[87] = 8'h00;
                    memory[86] = 8'h20;
                    memory[85] = 8'hc1;
                    memory[84] = 8'h63;
                    
                    // U-type instruction (opcode: 0110111)
                    // lui: 0x123452b7 -> lui x5, 0x12345
                    memory[91] = 8'h12;
                    memory[90] = 8'h34;
                    memory[89] = 8'h52;
                    memory[88] = 8'hb7;
                    
                    // J-type instruction (opcode: 1101111)
                    // jal: 0x000080ef -> jal x1, offset
                    memory[95] = 8'h00;
                    memory[94] = 8'h00;
                    memory[93] = 8'h80;
                    memory[92] = 8'hef;
                    
                end
        end

endmodule