`include "../rtl/order_quantity.sv"
`timescale 1ns/1ps
module order_quantity_wrapper
(
    input logic i_clk,
    input logic signed [63:0] inventory_state, // q1.34 fixed-point input
    output logic [63:0] order_quant // Scaled exponential value output
);

    order_quantity order_quantity
    (
        .i_clk(i_clk),
        .inventory_state(inventory_state),
        
        .order_out(order_quant)
    );

    initial
    begin
        $dumpfile("order_quantity_wrapper.vcd");
        $dumpvars;
    end

endmodule
