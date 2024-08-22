`include "../rtl/parser.sv"
`include "../rtl/order_book.sv"
`include "../rtl/trading_logic.sv"
`include "../rtl/inventory.sv"
`include "../rtl/order_quantity.sv"
`include "../rtl/reverse_parser.sv"


module hft_top
#(
    parameter DATA_WIDTH = 32,
    parameter FP_WORD_SIZE = 64,
    parameter NUM_STOCKS = 4,
    parameter BUFFER_SIZE = 32
)
(
    input logic                          i_clk,
    input logic                          i_reset_n,
    input logic                          i_book_is_busy,
    input logic [REG_WIDTH - 1 : 0]      i_reg_1,
    input logic [REG_WIDTH - 1 : 0]      i_reg_2,
    input logic [REG_WIDTH - 1 : 0]      i_reg_3,
    input logic [REG_WIDTH - 1 : 0]      i_reg_4,
    input logic [REG_WIDTH - 1 : 0]      i_reg_5,
    input logic [REG_WIDTH - 1 : 0]      i_reg_6,
    input logic [REG_WIDTH - 1 : 0]      i_reg_7,
    input logic [REG_WIDTH - 1 : 0]      i_reg_8,

    output logic [REG_WIDTH - 1 : 0]     o_reg_1,
    output logic [REG_WIDTH - 1 : 0]     o_reg_2,
    output logic [REG_WIDTH - 1 : 0]     o_reg_3,
    output logic [REG_WIDTH - 1 : 0]     o_reg_4,
    output logic [REG_WIDTH - 1 : 0]     o_reg_5,
    output logic [REG_WIDTH - 1 : 0]     o_reg_6,
    output logic [REG_WIDTH - 1 : 0]     o_reg_7,
    output logic                         o_valid


);

//parser internal signals
logic [1:0]                          itnl_stock_symbol;
logic [REG_WIDTH - 1 : 0]            itnl_order_id;
logic [REG_WIDTH - 1 : 0]            itnl_price;
logic [15:0]                         itnl_quantity;
logic [1:0]                          itnl_order_type;
logic                                itnl_trade_type;
logic [FP_WORD_SIZE - 1 : 0]         itnl_curr_time;
logic                                itnl_valid;
        
logic [31:0]                         itnl_best_bid;
logic [31:0]                         itnl_best_ask;
logic                                itnl_book_is_busy; // can only read from the book (from trading logic) when book is not busy
logic                                itnl_data_valid;
        
        
// trading logic internal signals
logic                                itnl_trading_logic_ready;
logic [FP_WORD_SIZE - 1 : 0]         itnl_inventory_state;
logic [DATA_WIDTH - 1 : 0]           itnl_buy_price;
logic [DATA_WIDTH - 1 : 0]           itnl_sell_price;

// inventory internal signals
logic signed [FP_WORD_SIZE - 1 : 0]  itnl_norm_inventory;

// order_quantity internal signals
logic [63:0] itnl_order_out;
logic [32:0] itnl_order_filter;

parser myparser (
    .i_clk(i_clk),
    .i_book_is_busy(),
    .i_reg_1(i_reg_1),
    .i_reg_2(i_reg_2),
    .i_reg_3(i_reg_3),
    .i_reg_4(i_reg_4),
    .i_reg_5(i_reg_5),
    .i_reg_6(i_reg_6),
    .i_reg_7(i_reg_7),
    .i_reg_8(i_reg_8),

    .o_stock_symbol(itnl_stock_symbol),
    .o_order_id(itnl_order_id),
    .o_price(itnl_price),
    .o_quantity(itnl_quantity),
    .o_order_type(itnl_order_type),
    .o_trade_type(itnl_trade_type),
    .o_curr_time(itnl_curr_time),
    .o_valid(itnl_valid)
)

order_book my_order_book (
    .i_clk(i_clk),
    .i_reset_n(i_reset_n),
    .i_trade_type(itnl_trade_type),
    .i_stock_id(itnl_stock_id),
    .i_order_type(itnl_order_type),
    .i_quantity(itnl_quantity),
    .i_price(itnl_price),
    .i_order_id(itnl_order_id),
    .i_data_valid(itnl_valid),
    .i_trading_logic_ready(itnl_trading_logic_ready),

    .o_best_bid(itnl_best_bid),
    .o_best_ask(itnl_best_ask),
    .o_book_is_busy(itnl_book_is_busy),
    .o_data_valid(itnl_data_valid)
)

trading_logic my_trading_logic (
    .i_clk(i_clk),
    .i_reset_n(i_reset_n),
    .i_best_ask(itnl_best_ask),
    .i_best_bid(itnl_best_bid),
    .i_curr_time(itnl_curr_time),
    .i_inventory_state(itnl_inventory_state),
    .i_data_valid(itnl_data_valid),
    .i_stock_id(itnl_stock_id),

    .o_buy_price(itnl_buy_price),
    .o_sell_price(itnl_sell_price),
    .o_data_valid(itnl_data_valid)
)

inventory my_inventory (
    .i_clk(i_clk),
    .i_reset_n(i_reset_n),
    .i_ren(), // sne not too sure what this is
    .i_stock_id(itnl_stock_id),
    .i_max_inventory_reciprocal(), // again no idea
    .i_execute_order_quantity(itnl_quantity), // not sure if u want some volatility output here
    .i_execute_order(),
    .i_execute_order_side(),

    .o_norm_inventory(itnl_norm_inventory)
)

order_quantity my_order_quantity (
    .i_clk(i_clk),
    .i_inventory_state(itnl_norm_inventory),

    .o_order_out(itnl_order_out),
    .o_order_filter(itnl_order_filter)
)

reverse_parser my_reverse_parser (
    .i_clk(i_clk),
    .i_stock_symbol(itnl_stock_symbol),
    .i_buy_price(itnl_buy_price),
    .i_sell_price(itnl_sell_price),
    .i_quantity(itnl_order_filter), // floored quantity value 
    .i_trade_type(itnl_trade_type),
    .i_book_is_busy(itnl_book_is_busy),
    .i_stock_id(itnl_stock_id),

    .o_reg_1(o_reg_1),
    .o_reg_2(o_reg_2),
    .o_reg_3(o_reg_3),
    .o_reg_4(o_reg_4),
    .o_reg_5(o_reg_5),
    .o_reg_6(o_reg_6),
    .o_reg_7(o_reg_7),
    .o_reg_8(o_reg_8),
    .o_valid(o_valid)
)




endmodule
