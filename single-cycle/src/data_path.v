`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: 
// Module Name: data_path
//////////////////////////////////////////////////////////////////////////////////


module data_path(
    input clk,                         // clock from top module
    input rst,                         // reset from top module
    input [4:0] read_reg_num1,         // rs1 address from instruction_out[19:15]
    input [4:0] read_reg_num2,         // rs2 address from instruction_out[24:20]
    input [4:0] write_reg_num1,        // rd address from instruction_out[11:7]
    input [5:0] alu_control,           // 6-bit control signal from control_unit
    input jump,                        // jump signal from control_unit
    input beq_control,                 // branch equal control from control_unit
    input bne_control,                 // branch not equal control from control_unit
    input [31:0] imm_val,              // sign extended immediate from top module
    input [3:0] shamt,                 // shift amount from imm_val[3:0]
    input lb,                          // load enable from control_unit
    input sw,                          // store enable from control_unit
    input bgeq_control,                // branch greater than equal control from control_unit
    input blt_control,                 // branch less than control from control_unit
    input lui_control,                 // lui enable from control_unit
    input [31:0] imm_val_lui,          // upper immediate from top module
    
    output [4:0] read_data_addr_dm,    // address forwarded to data memory
    output beq,bneq,bge,blt            // branch decision signals going to ifu
    );
    
    // internal wires connecting register file, alu, and data memory
    wire [31:0] read_data1;            // output from regfile rs1, goes to alu src1
    wire [31:0] read_data2;            // output from regfile rs2, goes to alu src2
    wire [4:0] read_data_addr_dm_2;    // rd address from regfile
    wire [31:0] write_data_alu;        // alu result: used for branch comparison and register writeback
    wire [31:0] data_out;              // data read from data memory, goes to regfile
    wire [31:0] data_out_2_dm;         // data from regfile, goes to data memory for store

    // active for R-type and I-type arithmetic instructions (not a branch, store, load, jump, or LUI)
    wire is_branch = beq_control | bne_control | bgeq_control | blt_control;
    wire reg_write_alu = (!lb && !sw && !lui_control && !jump && !is_branch);

    // register file instantiation
    register_file rfu (
        clk,
        rst,
        read_reg_num1,
        read_reg_num2,
        write_reg_num1,
        data_out,                      // write data coming from data memory (for loads)
        write_data_alu,                // calculation result from alu (for R-type and I-type)
        lb,
        lui_control,
        imm_val_lui,
        reg_write_alu,                 // enable writing alu result into rd
        jump,
        read_data1,                    // data out 1 to alu
        read_data2,                    // data out 2 to alu
        read_data_addr_dm_2,
        data_out_2_dm,                 // data to be stored into data memory
        sw
    );
    
    // alu instantiation
    alu alu_unit(
        read_data1,                    // operand 1 from register file
        read_data2,                    // operand 2 from register file
        alu_control,                   // operation selector from control unit
        imm_val,                       // immediate value from top module
        shamt,                         // shift amount
        write_data_alu                 // output result
    );
    
    // data memory instantiation
    data_memory dmu(
        clk,
        rst,
        imm_val[4:0],                  // write address from immediate offset
        data_out_2_dm,                 // data to write from register file
        sw,                            // write enable
        imm_val[4:0],                  // read address from immediate offset
        data_out                       // read data output to register file
    );
   
    assign read_data_addr_dm = read_data_addr_dm_2;
     
    // branch condition flags: alu outputs 1 if condition met, anded with control signal
    assign beq = (write_data_alu == 1 && beq_control == 1) ? 1 : 0;
    assign bneq = (write_data_alu == 1 && bne_control == 1) ? 1 : 0;
    assign bge = (write_data_alu == 1 && bgeq_control == 1) ? 1 : 0;
    assign blt = (write_data_alu == 1 && blt_control == 1) ? 1 : 0;
         
endmodule