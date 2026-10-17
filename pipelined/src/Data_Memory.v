`timescale 1ns / 1ps

module Data_Memory (
    input         clk,
    input         rst,
    input         mem_write,
    input  [31:0] addr,
    input  [31:0] write_data,
    output [31:0] read_data
);

    // 1024-word RAM storage (4 KB)
    reg [31:0] memory [0:1023];
    integer i;

    // Asynchronous read with word alignment (addr[31:2])
    assign read_data = (rst == 1'b0) ? 32'd0 : memory[addr[11:2]];

    // Synchronous write on rising clock edge
    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            for (i = 0; i < 64; i = i + 1) begin
                memory[i] <= 32'd0;
            end
        end else if (mem_write) begin
            memory[addr[11:2]] <= write_data;
        end
    end

endmodule