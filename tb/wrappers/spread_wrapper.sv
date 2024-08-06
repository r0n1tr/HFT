`include "../rtl/spread.sv"
`timescale 1ns/1ps
module spread_wrapper
#(
    parameter DATA_WIDTH = 32,
    parameter LOGARITHM = 121, // TODO: work out + more appropriate name
    parameter RISK_FACTOR = 0.1, // TODO
    parameter TERMINAL_TIME = 10000 // TODO
)
(
    input logic                      i_clk,
    input logic [DATA_WIDTH - 1 : 0] i_curr_time,
    input logic [DATA_WIDTH - 1 : 0] i_volatility,
    input logic                      i_data_valid,
    output logic                      o_spread,
    output logic                     o_data_valid
);

spread spread(
    .i_clk(i_clk),
    .i_curr_time(i_curr_time),
    .i_volatility(i_volatility),
    .i_data_valid(i_data_valid),
    .o_spread(o_spread),
    .o_data_valid(o_data_valid)
);

    initial
    begin
        $dumpfile("test.vcd");
        $dumpvars;
    end

endmodule
