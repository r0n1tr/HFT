`include "../rtl/order_quantity.sv"
`timescale 1ns/1ps
module order_quantity_wrapper
(
    input logic i_clk,
    input logic signed [63:0] i_inventory_state, // q1.34 fixed-point input
    output logic [63:0] o_order_out, // Scaled exponential value output
    output logic [32:0] o_order_filter
);

    order_quantity order_quantity
    (
        .i_clk(i_clk),
        .i_inventory_state(i_inventory_state),
        .o_order_filter(o_order_filter),
        .o_order_out(o_order_out)
    );

    initial
    begin
        $dumpfile("order_quantity_wrapper.vcd");
        $dumpvars;
    end

endmodule
