`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: 
// Module Name: register_file
//////////////////////////////////////////////////////////////////////////////////

//writing is synchronous and reading is asynchronous
//writing depends on the clk and control signals (lb, lui_control, reg_write_alu)
//reading is independent of any control signal (combinational)

module register_file(input clk,rst,
                     input [4:0] read_reg_num1, // rs1 address coming from instruction[19:15]
                     input [4:0] read_reg_num2, // rs2 address coming from instruction[24:20]
                     input [4:0] write_reg_num1,// rd address coming from instruction[11:7]
                     input [31:0] write_data_dm,// data coming from data memory (for load instructions)
                     input [31:0] write_data_alu,// calculation result coming from alu (for R-type and I-type)
                     input lb,                  // load control signal from control unit
                     input lui_control,         // lui control signal from control unit
                     input [31:0] lui_imm_val,  // immediate value for lui from top module
                     input reg_write_alu,       // write enable for alu operations (R-type and I-type)
                     
                     input jump,                // jump control signal from control unit
                     output [31:0] read_data1,  // output data of register 1 going to alu src1
                     output [31:0] read_data2,  // output data of register 2 going to alu src2
                     output [4:0] read_data_addr_dm, // rd address forwarded to data memory
                     output reg [31:0] data_out_2_dm, // data from register to be stored into data memory
                     input sw                   // store control signal from control unit
                     
    );
        reg [31:0] reg_mem [31:0];  // 32 registers of 32 bits each (x0 to x31)
        wire [31:0] write_reg_dm;   // address for load type instructions
        
        assign read_data_addr_dm = write_reg_num1;
        assign write_reg_dm = write_reg_num1;
        
        integer i;
        
        // synchronous writing logic
        always@(posedge clk)
        begin
            if(rst)
                begin
                // initializing registers with their index values for testing (x0=0, x1=1 ... x31=31)
                for(i = 0;i<32;i=i+1)
                    reg_mem[i] <= i;
                    data_out_2_dm = 0;
                end
            else
                begin
                    // register x0 is hardwired to zero: ignore any write to x0
                    if(write_reg_num1 != 5'd0)
                        begin
                            // load instruction: write data from memory into destination register rd
                            if(lb)
                                reg_mem[write_reg_num1] <= write_data_dm;
                                
                            // lui instruction: write upper immediate directly into destination register rd
                            else if(lui_control)
                                reg_mem[write_reg_num1] <= lui_imm_val;

                            // r-type and i-type arithmetic: write alu calculation result into destination register rd
                            else if(reg_write_alu)
                                reg_mem[write_reg_num1] <= write_data_alu;
                        end
                        
                    // store instruction: send register 1 data to memory to be written
                    if(sw)
                        data_out_2_dm <= (read_reg_num1 == 5'd0) ? 32'd0 : reg_mem[read_reg_num1];
                end
         end
         
         // asynchronous reading: register x0 is hardwired to 0 per RISC-V specification
         assign read_data1 = (read_reg_num1 == 5'd0) ? 32'd0 : reg_mem[read_reg_num1];
         assign read_data2 = (read_reg_num2 == 5'd0) ? 32'd0 : reg_mem[read_reg_num2];

endmodule