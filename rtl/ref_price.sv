module ref_price
#(
    parameter FP_WORD_SIZE = 64,
    parameter DATA_WIDTH = 32
)
(
    input logic                                         i_clk,
    input logic                                         i_reset_n,
    input logic [DATA_WIDTH - 1 : 0]                    i_curr_price, // not fixed point, need to conver it to fixed point
    input logic [FP_WORD_SIZE - 1 : 0]                  i_inventory_state, // normalised inventory
    input logic [DATA_WIDTH - 1 : 0]                    i_curr_time, 
    input logic [FP_WORD_SIZE - 1 : 0]                  i_volatility,
    input logic [DATA_WIDTH - 1 : 0]                    i_terminal_time,
    input logic [FP_WORD_SIZE - 1 : 0]                  i_risk_factor,
    input logic                                         i_data_valid,
    output logic [FP_WORD_SIZE - 1 : 0]                 o_ref_price,
    output logic                                        o_data_valid
);

    logic [4*FP_WORD_SIZE - 1 : 0]                      reg_ref_price;

    always_ff @(posedge i_clk) begin
        if(!i_reset_n) begin
            reg_ref_price <= 0;
            o_data_valid <= 0;
        end
        else begin
            if(i_data_valid) begin 
                // Calculation is doing: curr_price - (inventory * volatility * risk_factor *(terminal - curr time))
                reg_ref_price <= ({{(FP_WORD_SIZE+DATA_WIDTH){1'b0}}, {i_curr_price}, {(2*FP_WORD_SIZE){1'b0}}}) - (i_inventory_state * i_risk_factor * i_volatility*({i_terminal_time, {(DATA_WIDTH){1'b0}}} - {i_curr_time, {(DATA_WIDTH){1'b0}}}));
                o_data_valid <= 1;
            end
            else begin
                reg_ref_price <= 0;
                o_data_valid <= 0;
            end
        end
    end

    assign o_ref_price = reg_ref_price[159:96];



endmodule