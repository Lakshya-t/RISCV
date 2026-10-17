`timescale 1ns / 1ps

module Mux (
    input  [31:0] a,
    input  [31:0] b,
    input         s,
    output [31:0] c
);

    assign c = s ? b : a;

endmodule

module Mux_3_by_1 (
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,
    input  [1:0]  s,
    output [31:0] d
);

    assign d = (s == 2'b00) ? a :
               (s == 2'b01) ? b :
               (s == 2'b10) ? c : 32'd0;

endmodule
