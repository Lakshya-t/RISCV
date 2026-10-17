`timescale 1ns / 1ps

module PC_Module (
    input         clk,
    input         rst,
    input         en,
    input  [31:0] pc_next,
    output reg [31:0] pc
);

    // Synchronous program counter register with stall enable
    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            pc <= 32'd0;
        end else if (en) begin
            pc <= pc_next;
        end
    end

endmodule
