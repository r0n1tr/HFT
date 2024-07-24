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
    output logic [DATA_WIDTH - 1 : 0]       o_stddev,
    output logic                            o_data_valid,
)

    // TODO: 
    // adjust the running total with the incoming and outgoing data
    // Do the same with sum of n*n 
    // return mean 
    // pass E(x)^2 - E(x^2) to the square root function to get standard deviation.

    /*
    lets say: 
    [4, 5, 6, 7, 8] - average is 6
    now:
    [9, 4, 5, 6, 7] - average is now 31/5 = 6.2: same as mean - (in - out )/ 2


    variance:
    E(X^2) - E(X)^2
    */

    logic signed [DATA_WIDTH - 1 : 0]       mean_reg, 
    logic signed [DATA_WIDTH - 1 : 0]       mean_squared_reg;
    logic                                   input_valid;
    logic                                   square_root_data_out;
    logic                                   square_root_data_valid;

    always_ff @(posedge i_clk) begin
        mean_reg <= mean_reg + (i_incoming_data - i_outgoing_data)/2;
        mean_squared_reg <= mean_squared_reg + (i_incoming_data**2 - i_outgoing_data**2)/2;     
        input_valid <= 1;
    end

    assign o_mean <= mean_reg;
    assign o_stddev <= square_root_data_out;
    assign o_data_valid <= square_root_data_valid;


endmodule