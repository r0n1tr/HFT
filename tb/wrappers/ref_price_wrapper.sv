`include "../rtl/ref_price.sv"
`timescale 1ns/1ps
module ref_price_wrapper
#(
    parameter FP_WORD_SIZE = 64,
    parameter DATA_WIDTH = 32
)
(
    input logic                                         i_clk,
    input logic                                         i_reset_n,
    input logic [DATA_WIDTH - 1 : 0]                    i_curr_price, // not fixed point, need to conver it to fixed point
    input logic [FP_WORD_SIZE - 1 : 0]                  i_inventory_state,
    input logic [DATA_WIDTH - 1 : 0]                    i_curr_time, 
    input logic [FP_WORD_SIZE - 1 : 0]                  i_volatility,
    input logic [DATA_WIDTH - 1 : 0]                    i_terminal_time,
    input logic [FP_WORD_SIZE - 1 : 0]                  i_risk_factor,
    input logic                                         i_data_valid,
    output logic [FP_WORD_SIZE - 1 : 0]                 o_ref_price,
    output logic                                        o_data_valid
);

    ref_price ref_price
    (
        .i_clk(i_clk),
        .i_reset_n(i_reset_n),
        .i_curr_price(i_curr_price),
        .i_inventory_state(i_inventory_state),
        .i_curr_time(i_curr_time),
        .i_volatility(i_volatility),
        .i_terminal_time(i_terminal_time),
        .i_risk_factor(i_risk_factor),
        .i_data_valid(i_data_valid),
        .o_ref_price(o_ref_price),
        .o_data_valid(o_data_valid)
    );

    initial
    begin
        $dumpfile("test.vcd");
        $dumpvars;
    end

endmodule