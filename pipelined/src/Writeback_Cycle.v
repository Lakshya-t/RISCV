`timescale 1ns / 1ps

module Writeback_Cycle (
    input  [1:0]  result_src_w,
    input  [31:0] alu_result_w,
    input  [31:0] read_data_w,
    input  [31:0] pc_plus4_w,
    output [31:0] result_w
);

    // 3:1 Mux selecting writeback source:
    // 2'b00: ALU result
    // 2'b01: Data Memory read data
    // 2'b10: PC + 4 (for JAL return address link)
    Mux_3_by_1 result_mux (
        .a(alu_result_w),
        .b(read_data_w),
        .c(pc_plus4_w),
        .s(result_src_w),
        .d(result_w)
    );

endmodule