`timescale 1ns / 1ps

module data_memory (
    input         clk,
    input         rst,
    input  [31:0] addr,
    input  [31:0] write_data,
    input         mem_write,
    output [31:0] read_data
);

    // 1024-word RAM (4 KB)
    reg [31:0] memory [0:1023];
    integer i;

    // Asynchronous read (word-aligned addr[11:2])
    assign read_data = (rst) ? 32'd0 : memory[addr[11:2]];

    // Synchronous write
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 64; i = i + 1) begin
                memory[i] <= 32'd0;
            end
        end else if (mem_write) begin
            memory[addr[11:2]] <= write_data;
        end
    end

endmodule