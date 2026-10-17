`timescale 1ns / 1ps

module Memory_Cycle (
    input         clk,
    input         rst,
    input         reg_write_m,
    input         mem_write_m,
    input  [1:0]  result_src_m,
    input  [4:0]  rd_m,
    input  [31:0] pc_plus4_m,
    input  [31:0] write_data_m,
    input  [31:0] alu_result_m,
    output reg    reg_write_w,
    output reg [1:0] result_src_w,
    output reg [4:0]  rd_w,
    output reg [31:0] pc_plus4_w,
    output reg [31:0] alu_result_w,
    output reg [31:0] read_data_w
);

    wire [31:0] read_data_m;

    // Data RAM
    Data_Memory dmem (
        .clk(clk),
        .rst(rst),
        .mem_write(mem_write_m),
        .addr(alu_result_m),
        .write_data(write_data_m),
        .read_data(read_data_m)
    );

    // MEM/WB Pipeline Register
    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            reg_write_w  <= 1'b0;
            result_src_w <= 2'b00;
            rd_w         <= 5'd0;
            pc_plus4_w   <= 32'd0;
            alu_result_w <= 32'd0;
            read_data_w  <= 32'd0;
        end else begin
            reg_write_w  <= reg_write_m;
            result_src_w <= result_src_m;
            rd_w         <= rd_m;
            pc_plus4_w   <= pc_plus4_m;
            alu_result_w <= alu_result_m;
            read_data_w  <= read_data_m;
        end
    end

endmodule
