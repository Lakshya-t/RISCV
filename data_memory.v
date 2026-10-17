`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: 
// Module Name: data_memory
//////////////////////////////////////////////////////////////////////////////////

// 32-byte data memory (RAM) used for load and store operations
// writing (store) is synchronous on clock edge
// reading (load) is asynchronous / combinational

module data_memory(
    input clk,                         // clock from datapath
    input rst,                         // reset from datapath
    input [4:0] wr_addr,               // write address coming from immediate offset (imm_val[4:0])
    input [31:0] wr_data,              // data to be written coming from register file (data_out_2_dm)
    input sw,                          // store enable signal from control unit
    input [4:0] rd_addr,               // read address coming from immediate offset (imm_val[4:0])
    output [31:0] data_out             // data read from memory going to register file (write_data_dm)
    );
    
    // memory storage: 32 locations of 8 bits each (32 bytes total)
    reg [7:0] data_mem [31:0];
    integer i;
    
    always@(posedge clk)
        begin
            if(rst)
                begin
                    // initialize memory locations with their index values for simulation testing
                    for(i = 0; i < 32; i = i + 1)
                        data_mem[i] <= i;
                 end
            else
                begin
                    // store operation: write data from register into memory on posedge clk
                    if(sw)
                        data_mem[wr_addr] <= wr_data[7:0];
                end
       end
       
       // load operation: continuous asynchronous read at rd_addr
       assign data_out = data_mem[rd_addr];
                   
endmodule