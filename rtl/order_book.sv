// TODO: need to add logic for when the outputs are valid - should be done when order is added (cache not updated) or after the cache is updated.
// trade_type: 1 = buy, 0 = sell
module order_book 
#(  parameter NUM_STOCKS = 4,
    parameter BOOK_DEPTH = 10, // number of orders we want to store per stock
    parameter REG_WIDTH = 32,
    parameter CACHE_DEPTH = 1
)
(
    // Testing signals:
    output logic      [31:0] tb_reg_1,
    output logic      [31:0] tb_reg_2,
    output logic      [31:0] tb_reg_3,   
    output logic      [31:0] tb_reg_4,
    output logic      [31:0] tb_reg_5,
    output logic      [31:0] tb_reg_6,
    output logic      [31:0] tb_reg_7,
    output logic      [31:0] tb_reg_8,
    output logic      [31:0] tb_reg_9,
    output logic      [31:0] tb_reg_10,
    output logic      [31:0] tb_reg_11,
    output logic      [31:0] tb_reg_12,
    output logic      [31:0] tb_reg_13,
    output logic      [31:0] tb_reg_14,
    output logic      [31:0] tb_reg_15,
    output logic      [31:0] tb_reg_16,
    output logic      [31:0] tb_reg_17,
    output logic      [31:0] tb_reg_18,
    output logic      [31:0] tb_reg_19,
    output logic      [31:0] tb_reg_20,
    output logic      [31:0] tb_reg_21,
    output logic      [31:0] tb_reg_22,
    output logic      [31:0] tb_reg_23,
    output logic      [31:0] tb_reg_24,
    output logic      [31:0] tb_reg_25,
    output logic      [31:0] tb_reg_26,
    output logic      [31:0] tb_reg_27,
    output logic      [31:0] tb_reg_28,
    output logic      [31:0] tb_reg_29,
    output logic      [31:0] tb_reg_30,

    input logic             i_clk,
    input logic             i_reset_n, //LOGIC HIGH
    input logic             i_trade_type, // whether it is buy or sell // logic high = buy, logic low = sell.
    input logic [1:0]       i_stock_id,
    input logic [1:0]       i_order_type, 
    input logic [15:0]      i_quantity, 
    input logic [31:0]      i_price, 
    input logic [31:0]      i_order_id,
    output logic [31:0]     o_curr_price,
    output logic [31:0]     o_best_bid,
    output logic [31:0]     o_best_ask,
    output logic            o_book_is_busy, // can only read from the book (from trading logic) when book is not busy
    output logic            o_data_valid // data is valid when high
);
    // order book array. Each trade takes up 3 32 bit wide registers.
    logic [REG_WIDTH - 1 : 0] order_book_memory_bid [BOOK_DEPTH*NUM_STOCKS*3 - 1 : 0]; // order book has BOOK_DEPTH*NUM_STOCKS*3 - 1 number of 32 bit wide registers to hold orders
    logic [REG_WIDTH - 1 : 0] order_book_memory_ask [BOOK_DEPTH*NUM_STOCKS*3 - 1 : 0]; 

    logic [31:0] reg1 = {12'b0, {i_stock_id}, {i_order_type}, {i_quantity}};
    // internal cache logic - basically 12 (with our params) rows, 3 for each stock id, 1 order takes up 3 rows.
    logic [REG_WIDTH - 1 : 0] best_bid_cache [CACHE_DEPTH*NUM_STOCKS*3 - 1 : 0];
    logic [REG_WIDTH - 1 : 0] best_ask_cache [CACHE_DEPTH*NUM_STOCKS*3 - 1 : 0];

    // storing address for cancel order
    logic which_book;
    logic [ADDR_WIDTH-1:0] cancel_register;

    // internal pointer logic, to keep track of where to write a new trade into - we will just keep this as an array, which we can index via the stock id
    localparam ADDR_WIDTH = $clog2(BOOK_DEPTH*NUM_STOCKS*3);
    logic [ADDR_WIDTH - 1 : 0] write_pointer_array_ask [NUM_STOCKS - 1: 0];
    logic [ADDR_WIDTH - 1 : 0] write_pointer_array_bid [NUM_STOCKS - 1: 0];
    logic [$clog2(BOOK_DEPTH) - 1 : 0] num_trades_ask [NUM_STOCKS - 1 : 0];
    logic [$clog2(BOOK_DEPTH) - 1 : 0] num_trades_bid [NUM_STOCKS - 1 : 0];

    // for cancel order 
    logic [$clog2(BOOK_DEPTH)-1:0] search_pointer;
    logic [REG_WIDTH - 1 : 0] temp_max_reg1;
    logic [REG_WIDTH - 1 : 0] temp_max_price;
    logic [REG_WIDTH - 1 : 0] temp_max_order_id; 


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
        REMOVE_ORDER,
        EXECUTE_ORDER,
        SHIFT_BOOK,
        UPDATE_CACHE
    } state_t; 

    state_t curr_state, next_state;

    // TESTING LOGIC:
    always_comb begin
        if(i_trade_type) begin
            tb_reg_1 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 0];
            tb_reg_2 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 1];
            tb_reg_3 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 2];
            tb_reg_4 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 3];
            tb_reg_5 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 4];
            tb_reg_6 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 5];
            tb_reg_7 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 6];
            tb_reg_8 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 7];
            tb_reg_9 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 8];
            tb_reg_10 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 9];
            tb_reg_11 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 10];
            tb_reg_12 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 11];
            tb_reg_13 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 12];
            tb_reg_14 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 13];
            tb_reg_15 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 14];
            tb_reg_16 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 15];
            tb_reg_17 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 16];
            tb_reg_18 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 17];
            tb_reg_19 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 18];
            tb_reg_20 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 19];
            tb_reg_21 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 20];
            tb_reg_22 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 21];
            tb_reg_23 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 22];
            tb_reg_24 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 23];
            tb_reg_25 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 24];
            tb_reg_26 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 25];
            tb_reg_27 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 26];
            tb_reg_28 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 27];
            tb_reg_29 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 28];
            tb_reg_30 = order_book_memory_bid[i_stock_id * BOOK_DEPTH + 29];
        end
        else begin
            tb_reg_1 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 0];
            tb_reg_2 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 1];
            tb_reg_3 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 2];
            tb_reg_4 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 3];
            tb_reg_5 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 4];
            tb_reg_6 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 5];
            tb_reg_7 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 6];
            tb_reg_8 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 7];
            tb_reg_9 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 8];
            tb_reg_10 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 9];
            tb_reg_11 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 10];
            tb_reg_12 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 11];
            tb_reg_13 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 12];
            tb_reg_14 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 13];
            tb_reg_15 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 14];
            tb_reg_16 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 15];
            tb_reg_17 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 16];
            tb_reg_18 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 17];
            tb_reg_19 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 18];
            tb_reg_20 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 19];
            tb_reg_21 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 20];
            tb_reg_22 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 21];
            tb_reg_23 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 22];
            tb_reg_24 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 23];
            tb_reg_25 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 24];
            tb_reg_26 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 25];
            tb_reg_27 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 26];
            tb_reg_28 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 27];
            tb_reg_29 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 28];
            tb_reg_30 = order_book_memory_ask[i_stock_id * BOOK_DEPTH + 29];
        end
    end



    always_ff @(posedge i_clk) begin
        if (!i_reset_n) begin
            // TODO
            for (int i = 0; i < BOOK_DEPTH*NUM_STOCKS*3; i++) begin
               order_book_memory_bid[i] = 32'b0;
               order_book_memory_ask[i] = 32'b0;
            end
            for(int j = 0; j < CACHE_DEPTH*NUM_STOCKS*3; j++) begin
                best_bid_cache[j] <= 32'b0;
                best_ask_cache[j] <= 32'b0;
            
            end
            for(int k = 0; k < NUM_STOCKS; k++) begin
                write_pointer_array_bid[k] <= 0;
                write_pointer_array_ask[k] <= 0;
                num_trades_ask[k] <= 0;
                num_trades_ask[k] <= 0;
                is_full_array[k] <= 1'b0;
            end

        end
    end

     always_ff @(posedge i_clk) begin
        // defaults
        o_data_valid <= 0;
        o_book_is_busy <= 1; 
        // o_curr_price <= i_price;
        // o_best_ask <= best_ask_cache[(i_stock_id*3) + 1];
        // o_best_bid <= best_bid_cache[(i_stock_id*3) + 1];
        curr_state <= next_state;
        case(curr_state)
            IDLE: begin
                
                case (i_order_type)
                ADD: begin
                    o_book_is_busy <= 1;
                    next_state <= ADD_ORDER;
                end
                CANCEL: begin
                    o_book_is_busy <= 1;
                    next_state <= CANCEL_ORDER;
                end
                EXECUTE: begin
                    o_book_is_busy <= 1;
                    next_state <= EXECUTE_ORDER; 
                end
                default: begin
                    o_book_is_busy <= 0;
                    next_state <= curr_state;   
                end
                endcase

            end
            ADD_ORDER: begin
                // o_curr_price <= i_price;
                if(i_trade_type) begin
                    order_book_memory_bid[write_pointer_array_bid[i_stock_id]] <= reg1;
                    order_book_memory_bid[write_pointer_array_bid[i_stock_id] + 1] <= i_price;
                    order_book_memory_bid[write_pointer_array_bid[i_stock_id] + 2] <= i_order_id;
                    // for wrap around
                    num_trades_bid[i_stock_id] <= (num_trades_bid[i_stock_id] + 1) % BOOK_DEPTH;
                    /* verilator lint_off WIDTH */
                    write_pointer_array_bid[i_stock_id] <= (i_stock_id * BOOK_DEPTH) + ((num_trades_bid[i_stock_id] + 1) * 3) ;
                    /* verilator lint_on WIDTH */
                end else begin
                    order_book_memory_ask[write_pointer_array_ask[i_stock_id]] <= reg1;
                    order_book_memory_ask[write_pointer_array_ask[i_stock_id] + 1] <= i_price;
                    order_book_memory_ask[write_pointer_array_ask[i_stock_id] + 2] <= i_order_id;
                    num_trades_ask[i_stock_id] <= (num_trades_ask[i_stock_id] + 1) % BOOK_DEPTH;
                    /* verilator lint_off WIDTH */
                    write_pointer_array_ask[i_stock_id] <= (i_stock_id * BOOK_DEPTH) + ((num_trades_ask[i_stock_id] + 1) * 3) ;
                    /* verilator lint_on WIDTH */
                end
                
                next_state <= UPDATE_CACHE;

            end
            CANCEL_ORDER: begin
                if (order_book_memory_bid[(i_stock_id * BOOK_DEPTH) + search_pointer + 2] == i_order_id) begin
                        /* verilator lint_off WIDTH */
                        cancel_register <= (i_stock_id * BOOK_DEPTH) + search_pointer;
                        /* verilator lint_on WIDTH */
                        which_book <= 1;
                        next_state <= SHIFT_BOOK;

                    end
                if (order_book_memory_ask[(i_stock_id * BOOK_DEPTH) + search_pointer + 2] == i_order_id) begin

                    /* verilator lint_off WIDTH */
                    cancel_register <= (i_stock_id * BOOK_DEPTH) + search_pointer;
                    /* verilator lint_on WIDTH */
                    which_book <= 0;
                    next_state <= SHIFT_BOOK;

                end

                search_pointer <= search_pointer + 1;
            end 
            EXECUTE_ORDER: begin
            // TODO
                if (order_book_memory_bid[(i_stock_id * BOOK_DEPTH) + search_pointer + 2] == i_order_id) begin
                    order_book_memory_bid[(i_stock_id * BOOK_DEPTH) + search_pointer][15:0] <= order_book_memory_bid[(i_stock_id * BOOK_DEPTH) + search_pointer][15:0] - i_quantity;
                    if(order_book_memory_bid[(i_stock_id * BOOK_DEPTH) + search_pointer][15:0] == i_quantity) begin
                        which_book <= 1;
                        /* verilator lint_off WIDTH */
                        cancel_register <= (i_stock_id * BOOK_DEPTH) + search_pointer;
                        /* verilator lint_on WIDTH */
                        next_state <= SHIFT_BOOK;
                    end 
                    else begin
                        next_state <= UPDATE_CACHE;
                    end

                end
                if (order_book_memory_ask[(i_stock_id * BOOK_DEPTH) + search_pointer + 2] == i_order_id) begin
                    order_book_memory_ask[(i_stock_id * BOOK_DEPTH) + search_pointer][15:0] <= order_book_memory_ask[(i_stock_id * BOOK_DEPTH) + search_pointer][15:0] - i_quantity;
                    if(order_book_memory_ask[(i_stock_id * BOOK_DEPTH) + search_pointer][15:0] == i_quantity) begin
                        which_book <= 0;
                        /* verilator lint_off WIDTH */
                        cancel_register <= (i_stock_id * BOOK_DEPTH) + search_pointer;
                        /* verilator lint_on WIDTH */
                        next_state <= SHIFT_BOOK;
                    end
                    else begin
                        next_state <= UPDATE_CACHE;
                    end
                end

                search_pointer <= search_pointer + 1;
                // next_state <= UPDATE_CACHE;
            end
            SHIFT_BOOK: begin
                if(which_book) begin
                    if (cancel_register < ((i_stock_id*BOOK_DEPTH + BOOK_DEPTH*3) - 3)) begin // counter = cancelled trade number 
                    order_book_memory_bid[cancel_register] <= order_book_memory_bid[cancel_register+3];
                    order_book_memory_bid[cancel_register+1] <= order_book_memory_bid[cancel_register+4];
                    order_book_memory_bid[cancel_register+2] <= order_book_memory_bid[cancel_register+5];
                    cancel_register <= cancel_register + 3;
                    end
                    next_state <= UPDATE_CACHE;
                end
                else begin
                    if (cancel_register < ((i_stock_id*BOOK_DEPTH + BOOK_DEPTH*3) - 3)) begin // counter = cancelled trade number 
                    order_book_memory_ask[cancel_register] <= order_book_memory_ask[cancel_register+3];
                    order_book_memory_ask[cancel_register+1] <= order_book_memory_ask[cancel_register+4];
                    order_book_memory_ask[cancel_register+2] <= order_book_memory_ask[cancel_register+5]; 
                    cancel_register <= cancel_register + 3;
                    end
                    next_state <= UPDATE_CACHE;
                end
            end
            UPDATE_CACHE: begin
                // TODO
                case (i_order_type)
                ADD: begin
                    if(i_trade_type) begin 
                        if(i_price >= best_bid_cache[(i_stock_id*3)+1]) begin
                            best_bid_cache[(i_stock_id*3)] <= reg1;
                            best_bid_cache[(i_stock_id*3)+1] <= i_price;
                            best_bid_cache[(i_stock_id*3)+2] <= i_order_id;
                            
                        end
                    end else begin
                        if(i_price <= best_ask_cache[(i_stock_id*3)+1]) begin
                            best_ask_cache[(i_stock_id*3)] <= reg1;
                            best_ask_cache[(i_stock_id*3)+1] <= i_price;
                            best_ask_cache[(i_stock_id*3)+2] <= i_order_id;
                        end
                    end
                    o_data_valid <= 1;
                    next_state <= IDLE;
                    o_book_is_busy <= 0;
                end
                CANCEL: begin

                    if(i_trade_type && (i_order_id == best_bid_cache[(i_stock_id*3) + 2])) begin 
                        // valid delete - update bid cache
                        if (order_book_memory_bid[(i_stock_id * BOOK_DEPTH) + search_pointer + 1] > temp_max_price) begin
                            temp_max_reg1 <= order_book_memory_bid[(i_stock_id * BOOK_DEPTH) + search_pointer];
                            temp_max_price <= order_book_memory_bid[(i_stock_id * BOOK_DEPTH) + search_pointer + 1];
                            temp_max_order_id <= order_book_memory_bid[(i_stock_id * BOOK_DEPTH) + search_pointer + 2];
                            next_state <= UPDATE_CACHE; 
                        end
                        search_pointer <= search_pointer + 1;
                        if (search_pointer == BOOK_DEPTH - 1)  begin
                            // searched through all of them
                            best_bid_cache[(i_stock_id*3)] <= temp_max_reg1;
                            best_bid_cache[(i_stock_id*3)+1] <= temp_max_price;
                            best_bid_cache[(i_stock_id*3)+2] <= temp_max_order_id;
                            next_state <= IDLE;
                            o_data_valid <= 1;
                            o_book_is_busy <= 0;
                        end
                    end 
                    // ask
                    else if ((i_trade_type && (i_order_id == best_ask_cache[(i_stock_id*3) + 2]))) begin
                        if (order_book_memory_ask[(i_stock_id * BOOK_DEPTH) + search_pointer + 1] > temp_max_price) begin
                            temp_max_reg1 <= order_book_memory_ask[(i_stock_id * BOOK_DEPTH) + search_pointer];
                            temp_max_price <= order_book_memory_ask[(i_stock_id * BOOK_DEPTH) + search_pointer + 1];
                            temp_max_order_id <= order_book_memory_ask[(i_stock_id * BOOK_DEPTH) + search_pointer + 2];
                            next_state <= UPDATE_CACHE;
                        end
                        search_pointer <= search_pointer + 1;
                        if (search_pointer == BOOK_DEPTH - 1)  begin
                            // searched through all of them
                            best_ask_cache[(i_stock_id*3)] <= temp_max_reg1;
                            best_ask_cache[(i_stock_id*3)+1] <= temp_max_price;
                            best_ask_cache[(i_stock_id*3)+2] <= temp_max_order_id;
                            next_state <= IDLE;
                            o_data_valid <= 1;
                            o_book_is_busy <= 0;
                        end
                    end
                end
                default: ;
                endcase
                
                // next_state <= IDLE;
                // if the next state is IDLE, then:
                //o_book_is_busy <= 0;

                // after all sequence of orders from the feed have been completed, FSM will go to update_Cache accepting state and datavalid flag is valid
                // o_data_valid <= 1;

            end
            default: next_state <= curr_state; 
        endcase
     end

assign o_best_bid = best_bid_cache[(i_stock_id*3)+1];
assign o_best_ask = best_ask_cache[(i_stock_id*3)+1];
assign o_curr_price = i_price;

endmodule
