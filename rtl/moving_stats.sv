module moving_stats
#(
    parameter DATA_WIDTH = 32
)
(
    input logic                             i_clk,
    input logic                             i_reset_n,
    input logic [DATA_WIDTH - 1 : 0]        i_incoming_data,
    input logic [DATA_WIDTH - 1 : 0]        i_outgoing_data,
    output logic [DATA_WIDTH - 1 : 0]       o_mean,
    output logic [DATA_WIDTH - 1 : 0]       o_stddev
)

    // TODO: 
    // adjust the running total with the incoming and outgoing data
    // Do the same with sum of n*n 
    // return mean 
    // pass E(x)^2 - E(x^2) to the square root function to get standard deviation.

endmodule