`include "../rtl/parser.sv"
`include "../rtl/order_book.sv"
`include "../rtl/trading_logic.sv"
`include "../rtl/inventory.sv"
`include "../rtl/order_quantity.sv"
`include "../rtl/reverse_parser.sv"

// verilator lint_off UNUSED

module hft_top
#(
    parameter DATA_WIDTH = 32,
    parameter FP_WORD_SIZE = 64,
    parameter NUM_STOCKS = 4,
    parameter BUFFER_SIZE = 32,
    parameter REG_WIDTH = 32
)
(
    input logic                          i_clk,
    input logic                          i_data_valid,
    input logic                          i_reset_n,
    input logic                          i_book_is_busy,
    input logic [REG_WIDTH - 1 : 0]      i_reg_0,
    input logic [REG_WIDTH - 1 : 0]      i_reg_1,
    input logic [REG_WIDTH - 1 : 0]      i_reg_2,
    input logic [REG_WIDTH - 1 : 0]      i_reg_3,
    input logic [REG_WIDTH - 1 : 0]      i_reg_4,
    input logic [REG_WIDTH - 1 : 0]      i_reg_5,
    input logic [REG_WIDTH - 1 : 0]      i_reg_6,
    input logic [REG_WIDTH - 1 : 0]      i_reg_7,
    input logic [REG_WIDTH - 1 : 0]      i_reg_8,

    output logic [REG_WIDTH - 1 : 0]     o_reg_0_b,
    output logic [REG_WIDTH - 1 : 0]     o_reg_1_b,
    output logic [REG_WIDTH - 1 : 0]     o_reg_2_b,
    output logic [REG_WIDTH - 1 : 0]     o_reg_3_b,
    output logic [REG_WIDTH - 1 : 0]     o_reg_4_b,
    output logic [REG_WIDTH - 1 : 0]     o_reg_5_b,
    output logic [REG_WIDTH - 1 : 0]     o_reg_6_b,
    output logic [REG_WIDTH - 1 : 0]     o_reg_7_b,
    output logic [REG_WIDTH - 1 : 0]     o_reg_8_b,

     
    output logic [REG_WIDTH - 1 : 0]     o_reg_0_s,
    output logic [REG_WIDTH - 1 : 0]     o_reg_1_s,
    output logic [REG_WIDTH - 1 : 0]     o_reg_2_s,
    output logic [REG_WIDTH - 1 : 0]     o_reg_3_s,
    output logic [REG_WIDTH - 1 : 0]     o_reg_4_s,
    output logic [REG_WIDTH - 1 : 0]     o_reg_5_s,
    output logic [REG_WIDTH - 1 : 0]     o_reg_6_s,
    output logic [REG_WIDTH - 1 : 0]     o_reg_7_s,
    output logic [REG_WIDTH - 1 : 0]     o_reg_8_s,
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
    logic [1:0]                          itnl_stock_id;

            
    logic [31:0]                         itnl_best_bid;
    logic [31:0]                         itnl_best_ask;
    logic                                itnl_book_is_busy; // can only read from the book (from trading logic) when book is not busy
    logic                                itnl_data_valid;
    logic [15:0]                         itnl_locate_code;
    logic [15:0]                         itnl_tracking_number;
    
    // order book internal signals
    logic order_book_itnl_data_valid;
            
    // trading logic internal signals
    // logic [FP_WORD_SIZE - 1 : 0]         itnl_inventory_state;
    logic [DATA_WIDTH - 1 : 0]           itnl_buy_price;
    logic [DATA_WIDTH - 1 : 0]           itnl_sell_price;

    // inventory internal signals
    logic signed [FP_WORD_SIZE - 1 : 0]  itnl_norm_inventory;

    logic [DATA_WIDTH - 1 : 0]           itnl_order_book_quantity;
    logic [FP_WORD_SIZE - 1 : 0]         intl_parser_curr_time;
    logic                                intl_execute_order;
    logic                                itnl_execute_trade_type;

    // order_quantity internal signals
    logic [63:0] itnl_order_out;
    logic [31:0] itnl_order_filter;

    parser parser (
        .i_clk(i_clk),
        .i_data_valid(i_data_valid),
        .i_book_is_busy(itnl_book_is_busy),
        .i_reg_0(i_reg_0),
        .i_reg_1(i_reg_1),
        .i_reg_2(i_reg_2),
        .i_reg_3(i_reg_3),
        .i_reg_4(i_reg_4),
        .i_reg_5(i_reg_5),
        .i_reg_6(i_reg_6),
        .i_reg_7(i_reg_7),
        .i_reg_8(i_reg_8),

        .o_stock_symbol(itnl_stock_id),
        .o_order_id(itnl_order_id),
        .o_price(itnl_price),
        .o_quantity(itnl_quantity),
        .o_order_type(itnl_order_type),
        .o_trade_type(itnl_trade_type),
        .o_curr_time(intl_parser_curr_time),
        .o_locate_code(itnl_locate_code),
        .o_tracking_number(itnl_tracking_number),
        .o_valid(itnl_valid)
    );

    order_book order_book (
        .i_clk(i_clk),
        .i_reset_n(i_reset_n),
        .i_trade_type(itnl_trade_type),
        .i_stock_id(itnl_stock_id),
        .i_order_type(itnl_order_type),
        .i_quantity(itnl_quantity),
        .i_price(itnl_price),
        .i_order_id(itnl_order_id),
        .i_data_valid(itnl_valid),
        .i_execute_order_quantity(itnl_order_filter),
        .i_curr_time(intl_parser_curr_time),

        .o_best_bid(itnl_best_bid),
        .o_best_ask(itnl_best_ask),
        .o_book_is_busy(itnl_book_is_busy),
        .o_execute_order(intl_execute_order),
        .o_quantity(itnl_order_book_quantity),
        .o_curr_time(itnl_curr_time),
        .o_trade_type(itnl_execute_trade_type),
        .o_data_valid(order_book_itnl_data_valid)
    );

    trading_logic trading_logic (
        .i_clk(i_clk),
        .i_reset_n(i_reset_n),
        .i_best_ask(itnl_best_ask),
        .i_best_bid(itnl_best_bid),
        .i_curr_time(itnl_curr_time),
        .i_inventory_state(itnl_norm_inventory),
        .i_data_valid(order_book_itnl_data_valid),
        .i_stock_id(itnl_stock_id),

        .o_buy_price(itnl_buy_price),
        .o_sell_price(itnl_sell_price),
        .o_data_valid(itnl_data_valid)
    );

    inventory inventory (
        .i_clk(i_clk),
        .i_reset_n(i_reset_n),
        .i_stock_id(itnl_stock_id),
        .i_max_inventory_reciprocal(64'd262144), // 1/16384 where 16384 is max inventory // again no idea
        .i_execute_order_quantity(itnl_quantity), // not sure if u want some volatility output here
        .i_execute_order(intl_execute_order),
        .i_execute_order_side(itnl_execute_trade_type),

        .o_norm_inventory(itnl_norm_inventory)
    );

    order_quantity order_quantity(
        .i_clk(i_clk),
        .i_inventory_state(itnl_norm_inventory),

        .o_order_out(itnl_order_out),
        .o_order_filter(itnl_order_filter)
    );

    reverse_parser reverse_parser (
        .i_clk(i_clk),
        .i_stock_symbol(itnl_stock_id),
        .i_buy_price(itnl_buy_price),
        .i_sell_price(itnl_sell_price),
        .i_order_id(itnl_order_id),
        .i_quantity(itnl_order_filter), // floored quantity value 
        .i_trade_type(itnl_trade_type),
        .i_locate_code(itnl_locate_code),
        .i_tracking_number(itnl_tracking_number),
        .i_timestamp(itnl_curr_time),
        .i_book_is_busy(itnl_book_is_busy),
        .i_data_valid(itnl_data_valid),


        .o_reg_0_b(o_reg_0_b),
        .o_reg_1_b(o_reg_1_b),
        .o_reg_2_b(o_reg_2_b),
        .o_reg_3_b(o_reg_3_b),
        .o_reg_4_b(o_reg_4_b),
        .o_reg_5_b(o_reg_5_b),
        .o_reg_6_b(o_reg_6_b),
        .o_reg_7_b(o_reg_7_b),
        .o_reg_8_b(o_reg_8_b),

        .o_reg_0_s(o_reg_0_s),
        .o_reg_1_s(o_reg_1_s),
        .o_reg_2_s(o_reg_2_s),
        .o_reg_3_s(o_reg_3_s),
        .o_reg_4_s(o_reg_4_s),
        .o_reg_5_s(o_reg_5_s),
        .o_reg_6_s(o_reg_6_s),
        .o_reg_7_s(o_reg_7_s),
        .o_reg_8_s(o_reg_8_s),
        .o_valid(o_valid)
    );




endmodule
