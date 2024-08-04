module quote_price
#(
    parameter DATA_WIDTH = 32
)
(
    input logic                         i_clk,
    input logic [DATA_WIDTH - 1 : 0]    i_ref_price,
    input logic [DATA_WIDTH - 1 : 0]    i_spread,
    input logic                         i_data_valid,
    output logic [DATA_WIDTH - 1 : 0]   o_buy_price,
    output logic [DATA_WIDTH - 1 : 0]   o_ask_price,
    output logic                        o_data_valid
);

    always_ff @(posedge i_clk) begin
        if(i_data_valid) begin
            o_buy_price <= i_ref_price - (i_spread / 2); // TODO: convert to fixed point
            o_ask_price <= i_ref_price + (i_spread /2); 
            o_data_valid <= 1;
        end
        else begin 
            o_data_valid <= 0;
        end 
    end

endmodule