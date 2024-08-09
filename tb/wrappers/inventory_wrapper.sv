`include "../rtl/inventory.sv"
`timescale 1ns/1ps
module inventory_wrapper
#(
    parameter FP_WORD_SIZE = 64,
    parameter DATA_WIDTH = 32,
    parameter NUM_STOCKS = 4
)
(
    input logic                                 i_clk,
    input logic                                 i_reset_n,
    input logic                                 i_ren,
    input logic [$clog2(NUM_STOCKS) - 1 : 0 ]   i_stock_id,
    input logic [FP_WORD_SIZE - 1 : 0]          i_max_inventory_reciprocal, // keep this the same for all stocks for simplicity
    input logic [DATA_WIDTH - 1 : 0]            i_execute_order_quantity, // When we have a i_execute order, we need to re adjust the normalised inventory, this needs to happen during the culculation of volatility 
    input logic                                 i_execute_order,
    input logic                                 i_execute_order_side,
    output logic signed [FP_WORD_SIZE - 1 : 0]  o_norm_inventory // output inventory
);

    inventory inventory
    (
        .i_clk(i_clk),
        .i_reset_n(i_reset_n),
        .i_ren(i_ren),
        .i_stock_id(i_stock_id),
        .i_max_inventory_reciprocal(i_max_inventory_reciprocal),
        .i_execute_order_quantity(i_execute_order_quantity),
        .i_execute_order(i_execute_order),
        .i_execute_order_side(i_execute_order_side),
        .o_norm_inventory(o_norm_inventory)
    );

    initial
    begin
        $dumpfile("test.vcd");
        $dumpvars;
    end

endmodule