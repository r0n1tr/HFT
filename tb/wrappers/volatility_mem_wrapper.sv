`include "../rtl/volatility_mem.sv"
`timescale 1ns/1ps
module volatility_mem_wrapper
#(
    parameter FP_WORD_SIZE = 64,
    parameter DATA_WIDTH = 32,
    parameter BUFFER_SIZE = 20,
    parameter NUM_STOCKS = 4
)
(
    input logic                                                 i_clk,
    input logic                                                 i_reset_n,
    input logic [$clog2(NUM_STOCKS * BUFFER_SIZE) - 1 : 0]      i_write_address,
    input logic [DATA_WIDTH - 1 : 0]                            i_best_ask,
    input logic [DATA_WIDTH - 1 : 0]                            i_best_bid,
    input logic [$clog2(NUM_STOCKS) - 1 : 0]                    i_stock_id,
    input logic                                                 i_valid,
    input logic [DATA_WIDTH - 1 : 0]                            i_buffer_size,
    input logic [FP_WORD_SIZE - 1 : 0]                          i_buffer_size_reciprocal,
    input logic [DATA_WIDTH - 1 : 0]                            i_num_stocks,
    output logic [FP_WORD_SIZE - 1 : 0]                         o_volatility,
    output logic [DATA_WIDTH - 1 : 0]                           o_curr_price,
    output logic                                                o_data_valid
);  

    volatility_mem volatility_mem
    (
        .i_clk(i_clk),
        .i_reset_n(i_reset_n),
        .i_write_address(i_write_address),
        .i_best_ask(i_best_ask),
        .i_best_bid(i_best_bid),
        .i_stock_id(i_stock_id),
        .i_valid(i_valid),
        .i_buffer_size(i_buffer_size),
        .i_buffer_size_reciprocal(i_buffer_size_reciprocal),
        .i_num_stocks(i_num_stocks),
        .o_volatility(o_volatility),
        .o_curr_price(o_curr_price),
        .o_data_valid(o_data_valid)
    );

    initial
    begin
        $dumpfile("test.vcd");
        $dumpvars(0, volatility_mem_wrapper);
    end



endmodule