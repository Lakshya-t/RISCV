`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: 
// Module Name: top_tb
//////////////////////////////////////////////////////////////////////////////////


module top_tb(
    );
    
    reg clk;                           // clock signal
    reg reset;                         // active-high reset signal
    reg [4:0] address;                 // unused test signals
    reg [31:0] instruction_code;
    reg [7:0] instruction_code_2;
    reg [31:0] data_in_top;
    reg wr_en;
     
    // instantiate processor core (device under test)
    top_riscv dut(clk, reset);
     
    initial
        begin
            clk = 0;                   // initialize clock to 0
        end
         
    // generate clock with 20ns period (50 MHz frequency)
    always #10 clk = ~ clk;    
    
    // reset sequence: assert reset for 100ns to initialize processor then deassert
    initial
        begin
            reset = 1'b1;              // start with reset high (initialize memory and registers)
            #100;                      // wait 100ns (5 clock cycles)
            reset = 1'b0;              // release reset to start program execution from PC = 0
            
            // run simulation for 600ns to allow instructions to execute, then finish
            #600;
            $finish;
        end

    // dump waveforms for GTKWave viewing
    initial
        begin
            $dumpfile("waveform.vcd");
            $dumpvars(0, top_tb);
        end

endmodule