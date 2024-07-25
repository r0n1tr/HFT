module moving_stats
#(
    parameter DATA_WIDTH = 32,
    parameter WINDOW_SIZE = 64, // TODO: hard code this
)
(
    input logic                             i_clk,
    input logic                             i_reset_n,
    input logic [DATA_WIDTH - 1 : 0]        i_incoming_data,
    input logic [DATA_WIDTH - 1 : 0]        i_outgoing_data,
    output logic [DATA_WIDTH - 1 : 0]       o_mean,
    output logic [DATA_WIDTH - 1 : 0]       o_stddev,
    output logic                            o_data_valid,
    output logic [DATA_WIDTH - 1 : 0]       o_square_root_remainder
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

    logic signed [DATA_WIDTH - 1 : 0]       total_sum, 
    logic signed [DATA_WIDTH - 1 : 0]       total_squared_sum;
    logic                                   input_valid;
    logic                                   square_root_data_out;
    logic                                   square_root_data_valid;
    logic                                   square_root_remainder; 
    logic                                   sqaure_root_busy;

    always_ff @(posedge i_clk) begin
        total_sum <= total_sum + i_incoming_data - i_outgoing_data;
        total_squared_sum <= total_squared_sum + i_incoming_data**2 - i_outgoing_data**2;
        if(!square_root_busy) input_valid <= 1;
    end

    square_root squareRoot (
        .i_clk(i_clk),
        .i_start(input_valid),
        .o_busy(square_root_busy),
        .o_valid(square_root_data_valid),
        .i_rad(total_sum/WINDOW_SIZE - total_squared_sum/WINDOW_SIZE),
        .o_root(square_root_data_out),
        .o_rem(square_root_remainder)
    )

    assign o_mean <= total_sum/WINDOW_SIZE;
    assign o_stddev <= square_root_data_out;
    assign o_data_valid <= square_root_data_valid;
    assign o_square_root_remainder <= square_root_remainder;




endmodule