`include "../rtl/exp_lut.sv"
`timescale 1ns/1ps
module exp_lut_wrapper
#(
    parameter array_size = 1_000_000
)
(
    input logic i_clk,
    input logic signed [34:0] input_value, // q1.34 fixed-point input
    output logic [63:0] exp_value // Scaled exponential value output
);

    exp_lut exp_lut
    (
        .i_clk(i_clk),
        .input_value(input_value),
        
        .exp_value(exp_value)
    );

    initial
    begin
        $dumpfile("exp_lut_wrapper.vcd");
        $dumpvars;
    end

endmodule