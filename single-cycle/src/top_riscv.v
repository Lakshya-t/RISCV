`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Design Name: TOP 
// Module Name: top_riscv
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


module top_riscv(
    input clk,                      // system clock
    input reset                     // active-high reset
    );
    
    // internal interconnect wires between modules
    wire [31:0] pc;                 // program counter from ifu to instruction memory
    wire [31:0] current_pc;         // return program counter from ifu (for jal link)
    wire [31:0] instruction_out;    // 32-bit instruction read from instruction memory
    
    // control unit signals
    wire [5:0] alu_control;         // 6-bit alu operation selector from control_unit
    wire mem_to_reg;                // memory to register writeback enable
    wire beq_control;               // beq enable from control_unit
    wire bneq_control;              // bne enable from control_unit
    wire bgeq_control;              // bge enable from control_unit
    wire blt_control;               // blt enable from control_unit
    wire jump;                      // jump enable from control_unit
    wire lb;                        // load enable from control_unit
    wire sw;                        // store enable from control_unit
    wire lui_control;               // lui enable from control_unit
    
    // branch decision signals (from datapath back to ifu)
    wire beq, bneq, bge, blt;
    
    // immediate values extracted from instruction
    wire [31:0] imm_val_top;        // sign-extended immediate for i-type arithmetic / memory offset
    wire [31:0] imm_val;            // alias for imm_val_top passed to datapath
    wire [31:0] imm_val_branch_top; // branch immediate offset sent to ifu
    wire [31:0] imm_val_lui;        // upper immediate value for lui
    wire [31:0] imm_val_jump;       // jump immediate offset for jal
    
    wire [4:0] read_data_addr_dm;   // data memory address forwarded from datapath (5 bits)
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // INSTRUCTION FETCH UNIT
    // Maintains and updates the Program Counter (PC). On branches or jumps, adds the immediate offset.
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    instruction_fetch_unit ifu(
        clk,
        reset,
        imm_val_branch_top,         // branch target offset
        imm_val_jump,               // jal jump target offset
        beq,                        // branch equal flag from datapath
        bneq,                       // branch not equal flag from datapath
        bge,                        // branch greater than equal flag from datapath
        blt,                        // branch less than flag from datapath
        jump,                       // jump signal from control_unit
        pc,                         // current pc sent to instruction memory
        current_pc                  // pc + 4 return address
    );

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // INSTRUCTION MEMORY (ROM)
    // Stores the preloaded test program. Takes PC as address and outputs 32-bit instruction code.
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
    instruction_memory imu(
        clk,
        pc,                         // address from ifu
        reset,
        instruction_out             // fetched 32-bit instruction
    );
                           
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // CONTROL UNIT
    // Decodes the opcode, funct3, and funct7 fields to generate all control signals.
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
    control_unit cu(
        reset,
        instruction_out[31:25],     // funct7
        instruction_out[14:12],     // funct3
        instruction_out[6:0],       // opcode
        alu_control,                // alu operation code
        lb,                         // load enable
        mem_to_reg,                 // memory to register enable
        bneq_control,               // bne enable
        beq_control,                // beq enable
        bgeq_control,               // bge enable
        blt_control,                // blt enable
        jump,                       // jump enable
        sw,                         // store enable
        lui_control                 // lui enable
    );
   
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // DATA PATH UNIT
    // Contains Register File, ALU, and Data Memory. Computes results and evaluates branch conditions.
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    data_path dpu(
        clk,
        reset,
        instruction_out[19:15],     // rs1 (source register 1)
        instruction_out[24:20],     // rs2 (source register 2)
        instruction_out[11:7],      // rd (destination register)
        alu_control,                // operation selector from control_unit
        jump,                       // jump flag
        beq_control,                // beq enable
        bneq_control,               // bne enable
        imm_val,                    // immediate value for alu / data memory offset
        imm_val[3:0],               // shift amount (shamt)
        lb,                         // load enable
        sw,                         // store enable
        bgeq_control,               // bge enable
        blt_control,                // blt enable
        lui_control,                // lui enable
        imm_val_lui,                // upper immediate value
        
        read_data_addr_dm,          // forwarded address
        beq,                        // beq taken flag to ifu
        bneq,                       // bne taken flag to ifu
        bge,                        // bge taken flag to ifu
        blt                         // blt taken flag to ifu
    );
                  
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // IMMEDIATE VALUE GENERATION
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // I-type immediate (sign extended 12-bit immediate from instruction[31:20])
    assign imm_val_top = {{20{instruction_out[31]}}, instruction_out[31:20]};
    assign imm_val = imm_val_top;

    // B-type branch immediate: imm[12]=instr[31], imm[11]=instr[7], imm[10:5]=instr[30:25], imm[4:1]=instr[11:8], imm[0]=0
    assign imm_val_branch_top = {{20{instruction_out[31]}}, instruction_out[7], instruction_out[30:25], instruction_out[11:8], 1'b0};

    // U-type immediate for LUI: upper 20 bits zero-padded
    assign imm_val_lui = {10'b0, instruction_out[31:12]};

    // J-type immediate for JAL: sign extended 20-bit offset
    assign imm_val_jump = {{10{instruction_out[31]}}, instruction_out[31:12]};

endmodule