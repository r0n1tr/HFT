module trading_logic
#(
    parameter DATA_WIDTH = 32,
    parameter FP_WORD_SIZE = 64,
    parameter NUM_STOCKS = 4,
    parameter BUFFER_SIZE = 32
)
(
    input logic                                     i_clk,
    input logic                                     i_reset_n,
    input logic [DATA_WIDTH - 1 : 0]                i_best_ask,
    input logic [DATA_WIDTH - 1 : 0]                i_best_bid,
    input logic [FP_WORD_SIZE - 1 : 0]              i_curr_time,
    input logic [FP_WORD_SIZE - 1 : 0]              i_inventory_state,
    input logic                                     i_data_valid,
    input logic  [$clog2(NUM_STOCKS) - 1 : 0]       i_stock_id,
    output logic [DATA_WIDTH - 1 : 0]               o_buy_price,
    output logic [DATA_WIDTH - 1 : 0]               o_sell_price,
    output logic                                    o_data_valid
);

    logic [FP_WORD_SIZE - 1 : 0]                    w_volatility;
    logic [DATA_WIDTH - 1 : 0]                      w_curr_price;
    logic                                           w_buffer_full;
    logic                                           w_volatility_valid;
    logic [FP_WORD_SIZE - 1 : 0]                    w_spread;
    logic                                           w_spread_valid;
    logic [FP_WORD_SIZE - 1 : 0]                    w_ref_price;
    logic                                           w_ref_price_valid;

    volatility 
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_STOCKS(NUM_STOCKS),
        .BUFFER_SIZE(BUFFER_SIZE),
        .FP_WORD_SIZE(FP_WORD_SIZE)
    ) volatility
    (
        .i_clk(i_clk),
        .i_reset_n(i_reset_n),
        .i_stock_id(i_stock_id),
        .i_data_valid(i_data_valid),
        .i_best_ask(i_best_ask),
        .i_best_bid(i_best_bid),
        .i_buffer_size(32'd32),
        .i_buffer_size_reciprocal(64'h0000_0000_0800_0000), // 1/32
        .o_volatility(w_volatility),
        .o_curr_price(w_curr_price), 
        .o_buffer_full(w_buffer_full),
        .o_data_valid(w_volatility_valid)
    );



    spread 
    #(
        .FP_WORD_SIZE(FP_WORD_SIZE),
        .DATA_WIDTH(DATA_WIDTH)
    ) spread
    (
        .i_clk(i_clk),      
        .i_curr_time(i_curr_time),  
        .i_volatility(w_volatility),
        .i_data_valid(w_volatility_valid),
        .i_logarithm(64'b0),
        .i_risk_factor(64'h0000_0000_2000_0000), // 0.125
        .o_spread(w_spread),
        .o_data_valid(w_spread_valid)
    );



    ref_price 
    #(
        .FP_WORD_SIZE(FP_WORD_SIZE),
        .DATA_WIDTH(DATA_WIDTH)
    ) ref_price
    (
        .i_clk(i_clk),
        .i_reset_n(i_reset_n),
        .i_curr_price(w_curr_price),
        .i_inventory_state(i_inventory_state),
        .i_curr_time(i_curr_time), 
        .i_volatility(w_volatility),
        .i_risk_factor(64'h0000_0000_2000_0000),
        .i_data_valid(w_volatility_valid),
        .o_ref_price(w_ref_price),
        .o_data_valid(w_ref_price_valid)
    );



    quote_price 
    #(
        .FP_WORD_SIZE(FP_WORD_SIZE),
        .DATA_WIDTH(DATA_WIDTH)
    ) quote_price
    (
        .i_clk(i_clk),
        .i_ref_price(w_ref_price),
        .i_spread(w_spread),
        .i_buffer_full(w_buffer_full),
        .i_best_ask(i_best_ask),
        .i_best_bid(i_best_bid),
        .i_data_valid(w_spread_valid && w_ref_price_valid),
        .o_buy_price(o_buy_price),
        .o_ask_price(o_sell_price),
        .o_data_valid(o_data_valid)
    );


endmodule