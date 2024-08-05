module spread
#(
    parameter DATA_WIDTH = 32,
    parameter LOGARITHM = 121, // TODO: work out + more appropriate name
    parameter RISK_FACTOR = 0.1, // TODO
    parameter TERMINAL_TIME = 10000 // TODO
)
(
    input logic         i_clk,
    input logic [DATA_WIDTH - 1 : 0] i_curr_time,
    input logic [DATA_WIDTH - 1 : 0] i_volatility,
    input logic                      i_data_valid,
    output real                      o_spread,
    output logic                     o_data_valid
);

    always_ff @(posedge i_clk) begin 
        if(i_data_valid) begin
            o_spread <= RISK_FACTOR * i_volatility*(TERMINAL_TIME - i_curr_time) + LOGARITHM;
            o_data_valid <= 1; 
        end
        else begin 
            o_data_valid <= 0;
        end
    end

endmodule