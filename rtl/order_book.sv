// TODO: add logic for whether buy or sell
// TODO: need to add logic for when the outputs are valid - should be done when order is added (cache not updated) or after the cache is updated.
module order_book 
#(  parameter NUM_STOCKS = 4,
    parameter BOOK_DEPTH = 256, // number of orders we want to store per stock
    parameter REG_WIDTH = 32,
    parameter CACHE_DEPTH = 1,
)
(
    input logic      i_clk,
    input logic      i_reset_n, //LOGIC HIGH
    input logic      i_trade_type // whether it is buy or sell // logic high = buy, logic low = sell.
    input logic      [1:0] i_stock_id,
    input logic      [1:0] i_order_type, 
    input logic      [15:0] i_quantity, 
    input logic      [31:0] i_price, 
    input logic      [31:0] i_order_id,
    output logic     [31:0] o_curr_price,
    output logic     [31:0] o_best_bid,
    output logic     [31:0] o_best_ask,
    output logic     o_book_is_busy, // can only read from the book (from trading logic) when book is not busy
    output logic     o_data_valid // data is valid when high
)
    // order book array. Each trade takes up 3 32 bit wide registers.
    logic [REG_WIDTH - 1 : 0] order_book_memory [BOOK_DEPTH*NUM_STOCKS*3 - 1 : 0]; // order book has BOOK_DEPTH*NUM_STOCKS*3 - 1 number of 32 bit wide registers to hold orders


    logic [31:0] reg1 = {12'b0, {i_stock_id}, {i_order_type}, {i_quantity}}
    // internal cache logic - basically 12 (with our params) rows, 3 for each stock id, 1 order takes up 3 rows.
    logic [REG_WIDTH - 1 : 0] best_bid_cache [CACHE_DEPTH*NUM_STOCKS*3 - 1 : 0]
    logic [REG_WIDTH - 1 : 0] best_ask_cache [CACHE_DEPTH*NUM_STOCKS*3 - 1 : 0]

    // internal pointer logic, to keep track of where to write a new trade into - we will just keep this as an array, which we can index via the stock id
    localparam ADDR_WIDTH = $clog2(BOOK_DEPTH*NUM_STOCKS*3);
    logic [ADDR_WIDTH - 1 : 0] write_pointer_array [NUM_STOCKS - 1: 0];
    logic [$clog2(BOOK_DEPTH) - 1 : 0] num_trades [NUM_STOCKS - 1 : 0];

    // for cancel order 
    logic [63:0] temp_max;
    logic [ADDR_WIDTH-1:0] search_pointer;


    // logic fo whether an order book is full
    logic is_full_array [NUM_STOCKS - 1 : 0];

    logic [ADDR_WIDTH - 1 : 0] clear_pointer_array [NUM_STOCKS - 1 : 0];

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
        REMOVE_ORDER
        EXECUTE_ORDER,
        SHIFT_BOOK,
        UPDATE_CACHE
     } state_t; // TODO: maybe a state for removing an order because it is too old? idk feel like this can be optimised away in another state 

     state_t curr_state, next_state;


    always_ff @(posedge i_clk) begin
        if (!i_reset_n) begin
            // TODO
            for (int i = 0; i < BOOK_DEPTH*NUM_STOCKS*3; i++) begin
               order_book_memory[i] <= 32'b0;
            end
            for(int j = 0; j < CACHE_DEPTH*NUM_STOCKS*3; j++) begin
                best_bid_cache[j] <= 32'b0;
                best_ask_cache[j] <= 32'b0;
            
            end
            for(int k = 0; k < NUM_STOCKS; k++) begin
                write_pointer_array[k] <= ADDR_WIDTH'b0;
                is_full_array[k] <= 1'b0;
            end

        end
    end


     always_ff @(posedge i_clk) begin
        // defaults
        o_data_valid <= 0;
        o_book_is_busy < = 1; 
        o_curr_price <= i_price;
        o_best_ask <= best_ask_cache[(i_stock_id*3) + 1];
        o_best_bid <= best_bid_cache[(i_stock_id*3) + 1];

        case(curr_state)
            IDLE: begin
                
                case (i_order_type)
                ADD: 
                    o_book_is_busy <= 1;
                    next_state <= ADD_ORDER;
                CANCEL: 
                    o_book_is_busy <= 1;
                    next_state <= CANCEL_ORDER;
                EXECUTE:
                    o_book_is_busy <= 1;
                    next_state <= EXECUTE_ORDER; 
                default:
                    o_book_is_busy <= 0;
                    next_state <= curr_state;   
                endcase

            end
            ADD_ORDER: begin
                // TODO
                order_book_memory[write_pointer_array[i_stock_id]] <= reg1;
                order_book_memory[write_pointer_array[i_stock_id] + 1] <= i_price;
                order_book_memory[write_pointer_array[i_stock_id] + 2] <= i_order_id;
                // o_curr_price <= i_price;
                
                
                // for wrap around
                num_trades[i_stock_id] <= (num_trades[i_stock_id] + 1) % BOOK_DEPTH;
                write_pointer_array[i_stock_id] <= (i_stock_id * BOOK_DEPTH) + ((num_trades[i_stock_id] + 1) * 3) ;

                next_state <= UPDATE_CACHE;
            end
            CANCEL_ORDER: begin
                // TODO
                next_state <= SHIFT_BOOK;
            end 
            EXECUTE_ORDER: begin
                // TODO
                next_state <= UPDATE_CACHE;
            end
            SHIFT_BOOK: begin
                // TODO
                next_state <= UPDATE_CACHE
            end
            UPDATE_CACHE: begin
                // TODO
                case (i_order_type)
                ADD: begin
                    if(i_trade_type) begin 
                        if(order_book_memory[write_pointer_array[i_stock_id]] >= best_bid_cache[(i_stock_id*3)+1]) begin
                            best_bid_cache[(i_stock_id*3)+1] <= order_book_memory[write_pointer_array[i_stock_id]]
                        end
                    end else begin
                        if(order_book_memory[write_pointer_array[i_stock_id]] <= best_ask_cache[(i_stock_id*3)+1]) begin
                            best_ask_cache[(i_stock_id*3)+1] <= order_book_memory[write_pointer_array[i_stock_id]]
                        end
                    end
                end
                CANCEL: begin 

                    
                    if(i_trade_type) begin
                        if(i_order_id == best_bid_cache[(i_stock_id*3) + 1]) begin
                            if(order_book_memory[write_pointer_array[search_pointer]] >= temp_max) begin
                                temp_max <= order_book_memory[write_pointer_array[i_stock_id]];
                                search_pointer <= (i_stock_id * BOOK_DEPTH) + search_pointer + 2'b11;
                            end

                        end
                    end
                end

                default: ;
            
            
                endcase
               

                
                next_state <= IDLE;
                // if the next state is IDLE, then:
                o_book_is_busy <= 0;

                // after all sequence of orders from the feed have been completed, FSM will go to update_Cache accepting state and datavalid flag is valid
                o_data_valid <= 1;

            end
        endcase
     end


assign o_best_bid = best_bid_cache[(i_stock_id*3)+1];
assign o_best_ask = best_ask_cache[(i_stock_id*3)+1];





endmodule