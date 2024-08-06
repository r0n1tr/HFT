`include "../rtl/my_design.sv"
`timescale 1ns/1ps
module my_design_wrapper
(
    input logic clk,
    output logic my_signal_1,
    output logic my_signal_2
);

my_design my_design(
    .clk(clk),
    .my_signal_1(my_signal_1), 
    .my_signal_2(my_signal_2)
);

    initial
    begin
        $dumpfile("test.vcd");
        $dumpvars(0,my_design);
    end

endmodule
