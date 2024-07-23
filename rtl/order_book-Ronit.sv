// TODO: add logic for whether buy or sell
// TODO: need to add logic for when the outputs are valid - should be done when order is added (cache not updated) or after the cache is updated.
module order_book 
#(  parameter NUM_STOCKS = 4,
    parameter BOOK_DEPTH = 250, // number of orders we want to store per stock
    parameter REG_WIDTH = 32,
    parameter CACHE_DEPTH = 1,
)
(
    input logic      i_clk,
    input logic      i_reset_n,
    input logic      [1:0] i_stock_id,
    input logic      [1:0] i_order_type, 
    input logic      [15:0] i_quantity, 
    input logic      [31:0] i_price, 
    input logic      [31:0] i_order_id,
    output logic     [31:0] o_curr_price,
    output logic     [31:0] o_best_bid,
    output logic     [31:0] o_best_ask,
    output logic     o_book_is_busy, // can only read from the book (from trading logic) when book is not busy
    output logic     o_data_valid
)
    // order book array. Each trade takes up 3 32 bit wide registers.
    logic [REG_WIDTH - 1 : 0] order_book_memory [BOOK_DEPTH*NUM_STOCKS*3 - 1 : 0]; // order book has BOOK_DEPTH*NUM_STOCKS*3 - 1 number of 32 bit wide registers to hold orders

    // internal cache logic - basically 12 (with our params) rows, 3 for each stock id, 1 order takes up 3 rows.
    logic [REG_WIDTH - 1 : 0] best_bid_cache [CACHE_DEPTH*NUM_STOCKS*3 - 1 : 0]
    logic [REG_WIDTH - 1 : 0] best_ask_cache [CACHE_DEPTH*NUM_STOCKS*3 - 1 : 0]

    // internal pointer logic, to keep track of where to write a new trade into - we will just keep this as an array, which we can index via the stock id
    localparam ADDR_WIDTH = $clog2(BOOK_DEPTH*NUM_STOCKS*3);
    logic [ADDR_WIDTH - 1 : 0] write_pointer_array [NUM_STOCKS - 1: 0];

    // logic fo whether an order book is full
    logic is_full_array [NUM_STOCKS - 1 : 0];

    typedef enum logic [$clog2(NUM_STOCKS) - 1: 0] { 
        ADD = 0, 
        CANCEL = 1, 
        EXECUTE = 2
    } order_t; // for clarity when using a case statement

    // state logic for order book FSM
    typedef enum logic [2:0] { 
        IDLE,
        ADD_ORDER,
        CANCEL_ORDER,
        EXECUTE_ORDER,
        SHIFT_BOOK,
        UPDATE_CACHE
     } state_t; // TODO: maybe a state for removing an order because it is too old? idk feel like this can be optimised away in another state

     state_t curr_state, next_state;


    always_ff @(posedge i_clk) begin
        if (!i_reset_n) begin
            // TODO
        end
    end


     always_ff @(posedge i_clk) begin
        case(curr_state)
            IDLE: begin
                // TODO
            end
            ADD_ORDER: begin
                // TODO
            end
            CANCEL_ORDER: begin
                // TODO
            end 
            EXECUTE_ORDER: begin
                // TODO
            end
            SHIFT_BOOK: begin
                // TODO
            end
            UPDATE_CACHE: begin
                // TODO
            end
        endcase
     end





endmodule