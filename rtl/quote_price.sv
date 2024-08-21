module quote_price
#(
    parameter FP_WORD_SIZE = 64,
    parameter DATA_WIDTH = 32
)
(
    input logic                         i_clk,
    input logic [FP_WORD_SIZE - 1 : 0]  i_ref_price,
    input logic [FP_WORD_SIZE - 1 : 0]  i_spread,
    input logic                         i_buffer_full,
    input logic [DATA_WIDTH - 1 : 0]    i_best_ask,
    input logic [DATA_WIDTH - 1 : 0]    i_best_bid,
    input logic                         i_data_valid,
    output logic [DATA_WIDTH - 1 : 0]   o_buy_price,
    output logic [DATA_WIDTH - 1 : 0]   o_ask_price,
    output logic                        o_data_valid
);

    logic [FP_WORD_SIZE - 1 : 0]        reg_buy_price;
    logic [FP_WORD_SIZE - 1 : 0]        reg_ask_price;

    always_ff @(posedge i_clk) begin
        if(i_data_valid) begin
            o_data_valid <= 1;

            if (i_buffer_full) begin
                reg_buy_price <= i_ref_price - (i_spread >>> 1);
                reg_ask_price <= i_ref_price + (i_spread >>> 1);
            end
            else begin
                reg_buy_price <= {i_best_ask, 32'b0};
                reg_ask_price <= {i_best_bid, 32'b0};
            end
        end
        else begin 
            reg_ask_price <= 0;
            reg_buy_price <= 0;
            o_data_valid <= 0;
        end 
    end

    assign o_buy_price = reg_buy_price[63:32]; // cut off fractional bits before quoting
    assign o_ask_price = reg_ask_price[63:32];

endmodule