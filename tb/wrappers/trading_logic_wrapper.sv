`include "../rtl/quote_price.sv"
`include "../rtl/ref_price.sv"
`include "../rtl/spread.sv"
`include "../rtl/volatility_ctrl.sv"
`include "../rtl/volatility_mem.sv"
`include "../rtl/volatility.sv"
`include "../rtl/trading_logic.sv"
`timescale 1ns/1ps
module trading_logic_wrapper
#(
    parameter DATA_WIDTH = 32,
    parameter FP_WORD_SIZE = 64,
    parameter NUM_STOCKS = 4,
    parameter BUFFER_SIZE = 32
)
(
    input logic                                     i_clk,
    input logic                                     i_reset_n,
    input logic [DATA_WIDTH - 1 : 0]                i_best_ask,
    input logic [DATA_WIDTH - 1 : 0]                i_best_bid,
    input logic [FP_WORD_SIZE - 1 : 0]              i_curr_time,
    input logic [FP_WORD_SIZE - 1 : 0]              i_inventory_state,
    input logic                                     i_data_valid,
    input logic  [$clog2(NUM_STOCKS) - 1 : 0]       i_stock_id,
    output logic [DATA_WIDTH - 1 : 0]               o_buy_price,
    output logic [DATA_WIDTH - 1 : 0]               o_sell_price,
    output logic                                    o_data_valid
);

    trading_logic trading_logic
    (
        .i_clk(i_clk),
        .i_reset_n(i_reset_n),
        .i_best_ask(i_best_ask),
        .i_best_bid(i_best_bid),
        .i_curr_time(i_curr_time),
        .i_inventory_state(i_inventory_state),
        .i_data_valid(i_data_valid),
        .i_stock_id(i_stock_id),
        .o_buy_price(o_buy_price),
        .o_sell_price(o_sell_price),
        .o_data_valid(o_data_valid)  
    );

    initial
    begin
        $dumpfile("test.vcd");
        $dumpvars;
    end

endmodule