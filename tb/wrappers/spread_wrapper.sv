`include "../rtl/spread.sv"
`timescale 1ns/1ps
module spread_wrapper
#(
    parameter FP_WORD_SIZE = 64,
    parameter DATA_WIDTH = 32
)
(
    input logic                                     i_clk,
    input logic [DATA_WIDTH - 1 : 0]                i_curr_time,
    input logic signed [FP_WORD_SIZE - 1 : 0]       i_volatility,
    input logic                                     i_data_valid,
    input logic signed [FP_WORD_SIZE - 1 : 0]       i_logarithm,
    input logic signed [FP_WORD_SIZE - 1 : 0]       i_risk_factor,
    input logic [DATA_WIDTH - 1 : 0]                i_terminal_time,
    output logic signed [FP_WORD_SIZE - 1 : 0]      o_spread,
    output logic                                    o_data_valid
);

spread spread(
    .i_clk(i_clk),
    .i_curr_time(i_curr_time),
    .i_volatility(i_volatility),
    .i_data_valid(i_data_valid),
    .i_logarithm(i_logarithm),
    .i_risk_factor(i_risk_factor),
    .i_terminal_time(i_terminal_time),
    .o_spread(o_spread),
    .o_data_valid(o_data_valid)
);

    initial
    begin
        $dumpfile("test.vcd");
        $dumpvars;
    end

endmodule
