`timescale 1ns / 1ps

module Register_File (
    input         clk,
    input         rst,
    input         reg_write,
    input  [4:0]  rs1,
    input  [4:0]  rs2,
    input  [4:0]  rd,
    input  [31:0] write_data,
    output [31:0] read_data1,
    output [31:0] read_data2
);

    reg [31:0] registers [31:0];
    integer i;

    // Asynchronous reads with x0 hardwired to zero
    // Includes internal write-to-read bypass for writeback conflicts
    assign read_data1 = (rst == 1'b0) ? 32'd0 :
                        (rs1 == 5'd0)  ? 32'd0 :
                        ((rs1 == rd) && reg_write) ? write_data :
                        registers[rs1];

    assign read_data2 = (rst == 1'b0) ? 32'd0 :
                        (rs2 == 5'd0)  ? 32'd0 :
                        ((rs2 == rd) && reg_write) ? write_data :
                        registers[rs2];

    // Synchronous clocked write logic
    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'd0;
            end
        end else if (reg_write && (rd != 5'd0)) begin
            registers[rd] <= write_data;
        end
    end

endmodule