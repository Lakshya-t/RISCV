`timescale 1ns / 1ps

module instruction_fetch_unit (
    input         clk,
    input         reset,
    input         pc_src,
    input  [31:0] target_pc,
    output reg [31:0] pc,
    output [31:0] pc_plus4
);

    assign pc_plus4 = pc + 32'd4;
    wire [31:0] next_pc = pc_src ? target_pc : pc_plus4;

    always @(posedge clk) begin
        if (reset) begin
            pc <= 32'd0;
        end else begin
            pc <= next_pc;
        end
    end

endmodule