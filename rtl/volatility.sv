module volatility
#(
    parameter DATA_WIDTH = 32,
    parameter NUM_STOCKS = 4,
    parameter BUFFER_SIZE = 20
)
(
    input logic                                 i_clk,
    input logic                                 i_reset_n,
    input logic [$clog2(NUM_STOCKS) - 1 : 0]    i_stock_id,
    input logic                                 i_data_valid,
    input logic [DATA_WIDTH - 1 : 0]            i_best_ask,
    input logic [DATA_WIDTH - 1 : 0]            i_best_bid,
    output logic [DATA_WIDTH - 1 : 0]           o_volatility,
    output logic                                o_data_valid
);  

    logic [$clog2(NUM_STOCKS*BUFFER_SIZE) - 1 : 0] write_address;
    logic addr_valid;

    volatility_ctrl 
    #(
        .NUM_STOCKS(NUM_STOCKS),
        .BUFFER_SIZE(BUFFER_SIZE)
    ) volatility_ctrl 
    (
        .i_clk(i_clk),
        .i_reset_n(i_reset_n),
        .i_stock_id(i_stock_id),
        .i_data_valid(i_data_valid),
        .o_write_address(write_address),
        .o_addr_valid(addr_valid)
    );

    volatility_mem
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_STOCKS(NUM_STOCKS),
        .BUFFER_SIZE(BUFFER_SIZE)
    ) volatility_mem
    (
        .i_clk(i_clk),
        .i_reset_n(i_reset_n),
        .i_write_address(write_address),
        .i_best_ask(i_best_ask),
        .i_best_bid(i_best_bid),
        .i_stock_id(i_stock_id),
        .i_valid(addr_valid),
        .o_volatility(o_volatility),
        .o_data_valid(o_data_valid)
    );

endmodule
