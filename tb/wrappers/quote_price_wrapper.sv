`include "../rtl/quote_price.sv"
`timescale 1ns/1ps
module quote_price_wrapper
#(
    parameter FP_WORD_SIZE = 64,
    parameter DATA_WIDTH = 32
)
(
    input logic                         i_clk,
    input logic [FP_WORD_SIZE - 1 : 0]  i_ref_price,
    input logic [FP_WORD_SIZE - 1 : 0]  i_spread,
    input logic                         i_data_valid,
    output logic [DATA_WIDTH - 1 : 0]   o_buy_price,
    output logic [DATA_WIDTH - 1 : 0]   o_ask_price,
    output logic                        o_data_valid
);

    quote_price quote_price
    (
        .i_clk(i_clk),
        .i_ref_price(i_ref_price),
        .i_spread(i_spread),
        .i_data_valid(i_data_valid),
        .o_buy_price(o_buy_price),
        .o_ask_price(o_ask_price),
        .o_data_valid(o_data_valid)
    );

    initial
    begin
        $dumpfile("test.vcd");
        $dumpvars;
    end

endmodule