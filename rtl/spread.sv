module spread
#(
    parameter FP_WORD_SIZE = 64,
    parameter DATA_WIDTH = 32
)
(
    input logic                                     i_clk,
    input logic [FP_WORD_SIZE - 1 : 0]              i_curr_time, // Need to be converted to our standard form for fixed point
    input logic signed [FP_WORD_SIZE - 1 : 0]       i_volatility,
    input logic                                     i_data_valid,
    input logic signed [FP_WORD_SIZE - 1 : 0]       i_logarithm,
    input logic signed [FP_WORD_SIZE - 1 : 0]       i_risk_factor,
    output logic signed [FP_WORD_SIZE - 1 : 0]      o_spread,
    output logic                                    o_data_valid
);

    logic signed [3*FP_WORD_SIZE - 1 : 0] mult_result;

    always_ff @(posedge i_clk) begin 
        if(i_data_valid) begin
            mult_result <= i_risk_factor*i_volatility*(i_curr_time) + {{(FP_WORD_SIZE){1'b0}}, i_logarithm, {(FP_WORD_SIZE){1'b0}}};
            o_data_valid <= 1; 
        end
        else begin 
            mult_result <= 0;
            o_data_valid <= 0;
        end
    end   

    assign o_spread = mult_result[127:64]; 

endmodule
