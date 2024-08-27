// TODO: need to add logic for when the outputs are valid - should be done when order is added (cache not updated) or after the cache is updated.
// trade_type: 1 = buy, 0 = sell
module order_book 
#(  parameter NUM_STOCKS = 4,
    parameter BOOK_DEPTH = 10, // number of orders we want to store per stock
    parameter REG_WIDTH = 32,
    parameter CACHE_DEPTH = 1
)
(

    input logic             i_clk,
    input logic             i_reset_n, //LOGIC HIGH
    input logic             i_trade_type, // whether it is buy or sell // logic high = buy, logic low = sell.
    input logic [1:0]       i_stock_id,
    input logic [1:0]       i_order_type, 
    input logic [15:0]      i_quantity, 
    input logic [31:0]      i_price, 
    input logic [31:0]      i_order_id,
    input logic             i_data_valid, // FROM PARSER
    input logic             i_trading_logic_ready, // FROM TRADING LOGICs
    input logic [15:0]      i_execute_order_quantity,
    input logic [63:0]      i_curr_time,
    output logic [31:0]     o_best_bid,
    output logic [31:0]     o_best_ask,
    output logic            o_book_is_busy, // can only read from the book (from trading logic) when book is not busy
    output logic            o_execute_order,
    output logic [31:0]     o_quantity,
    output logic [63:0]     o_curr_time,
    output logic            o_trade_type,
    output logic            o_data_valid // data is valid when high
);
    // order book array. Each trade takes up 3 32 bit wide registers.
    logic [REG_WIDTH - 1 : 0] order_book_memory_bid [BOOK_DEPTH*NUM_STOCKS*3 - 1 : 0]; // order book has BOOK_DEPTH*NUM_STOCKS*3 - 1 number of 32 bit wide registers to hold orders
    logic [REG_WIDTH - 1 : 0] order_book_memory_ask [BOOK_DEPTH*NUM_STOCKS*3 - 1 : 0]; 

    logic [31:0] reg1;
    // internal cache logic - basically 12 (with our params) rows, 3 for each stock id, 1 order takes up 3 rows.
    logic [REG_WIDTH - 1 : 0] best_bid_cache [CACHE_DEPTH*NUM_STOCKS*3 - 1 : 0];
    logic [REG_WIDTH - 1 : 0] best_ask_cache [CACHE_DEPTH*NUM_STOCKS*3 - 1 : 0];
    // 4 stores to store prev curr prices for each stock
    logic [REG_WIDTH - 1 : 0] curr_bid_price_cache [BOOK_DEPTH*NUM_STOCKS - 1 : 0]; //to store the previous curr price on cancellation of order.
    logic [REG_WIDTH - 1 : 0] curr_ask_price_cache [BOOK_DEPTH*NUM_STOCKS - 1 : 0];

    // internal pointer logic, to keep track of where to write a new trade into - we will just keep this as an array, which we can index via the stock id
    localparam ADDR_WIDTH = $clog2(BOOK_DEPTH*NUM_STOCKS*3);
    logic [ADDR_WIDTH - 1 : 0] write_pointer_array_ask [NUM_STOCKS - 1: 0];
    logic [ADDR_WIDTH - 1 : 0] write_pointer_array_bid [NUM_STOCKS - 1: 0];
    logic [$clog2(BOOK_DEPTH) - 1 : 0] num_trades_ask [NUM_STOCKS - 1 : 0];
    logic [$clog2(BOOK_DEPTH) - 1 : 0] num_trades_bid [NUM_STOCKS - 1 : 0];

    // storing address for cancel order
    logic which_book;
    logic [ADDR_WIDTH-1:0] cancel_register;
    logic [ADDR_WIDTH-1:0] counter;

    // for cancel order 
    logic [$clog2(BOOK_DEPTH)-1:0] search_pointer;
    logic [REG_WIDTH - 1 : 0] temp_max_reg1;
    logic [REG_WIDTH - 1 : 0] temp_max_price;
    logic [REG_WIDTH - 1 : 0] temp_max_order_id; 
    logic [REG_WIDTH - 1 : 0] temp_min_reg1;
    logic [REG_WIDTH - 1 : 0] temp_min_price;
    logic [REG_WIDTH - 1 : 0] temp_min_order_id; 

    logic [31:0] test_index;
    logic found;

    logic reg_execute_order;

    typedef enum logic [$clog2(NUM_STOCKS) - 1: 0] { 
        ADD = 0, 
        CANCEL = 1, 
        EXECUTE = 2
    } order_t; // for clarity when using a case statement

    // state logic for order book FSM
    typedef enum logic [2:0] { 
        IDLE,               //0
        ADD_ORDER,          //1
        CANCEL_ORDER,       //2
        EXECUTE_ORDER,      //3
        SHIFT_BOOK,         //4
        UPDATE_CACHE,       //5
        FINISH              //6
    } state_t; 

    state_t curr_state, next_state;

    always_comb begin 
        if(!i_trade_type) begin
            /* verilator lint_off WIDTH */
            write_pointer_array_bid[i_stock_id] = ((i_stock_id * BOOK_DEPTH) + ((num_trades_bid[i_stock_id])))*3;
            /* verilator lint_on WIDTH */
        end
        else begin
            /* verilator lint_off WIDTH */
            write_pointer_array_ask[i_stock_id] = ((i_stock_id * BOOK_DEPTH) + ((num_trades_ask[i_stock_id])))*3 ;
            /* verilator lint_on WIDTH */
        end
    end

    // reset logic 
    always_ff @(posedge i_clk) begin
        reg1 <= {12'b0, {i_stock_id}, {i_order_type}, {i_quantity}};
        if (!i_reset_n) begin
            temp_min_price <= 32'b11111111111111111111111111111111;
            for (int i = 0; i < BOOK_DEPTH*NUM_STOCKS*3; i++) begin
               order_book_memory_bid[i] = 32'b0;
               order_book_memory_ask[i] = 32'b0;
            end
            for(int j = 0; j < CACHE_DEPTH*NUM_STOCKS*3; j++) begin
                best_bid_cache[j] <= 32'b0;
                best_ask_cache[j] <= 32'b0;
            end
            for(int l = 0; l < CACHE_DEPTH*NUM_STOCKS; l++) begin
                curr_bid_price_cache[l] <= 32'b0;
                curr_ask_price_cache[l] <= 32'b0;
            end
            for(int k = 0; k < NUM_STOCKS; k++) begin
                // write_pointer_array_bid[k] <= 0;
                // write_pointer_array_ask[k] <= 0;
                num_trades_bid[k] <= 0;
                num_trades_ask[k] <= 0;
            end
            curr_state <= IDLE; 
        end
    end

     always_ff @(posedge i_clk) begin
        o_data_valid <= 0;
        o_book_is_busy <= 1; 
        o_execute_order <= 0;
        // curr_state <= next_state;
        found <= 0;
        case(curr_state)
            IDLE: begin //0
                if(i_data_valid) begin
                    case (i_order_type)
                    ADD: begin
                        o_book_is_busy <= 1;
                        curr_state <= ADD_ORDER;
                    end
                    CANCEL: begin
                        o_book_is_busy <= 1;
                        curr_state <= CANCEL_ORDER;
                    end
                    EXECUTE: begin
                        o_book_is_busy <= 1;
                        curr_state <= EXECUTE_ORDER; 
                    end
                    default: begin
                        o_book_is_busy <= 0;
                        curr_state <= IDLE;   
                    end
                    endcase
                end
                else begin
                    o_book_is_busy <= 0;
                    curr_state <= IDLE;
                end 
            end
            ADD_ORDER: begin //1
                if(!i_trade_type) begin
                    order_book_memory_bid[write_pointer_array_bid[i_stock_id]] <= reg1;
                    order_book_memory_bid[write_pointer_array_bid[i_stock_id] + 1] <= i_price;
                    order_book_memory_bid[write_pointer_array_bid[i_stock_id] + 2] <= i_order_id;
                    // for wrap around
                    num_trades_bid[i_stock_id] <= (num_trades_bid[i_stock_id] + 1) % BOOK_DEPTH;
                    curr_bid_price_cache[i_stock_id] <= i_price;
                    
                end else begin
                    order_book_memory_ask[write_pointer_array_ask[i_stock_id]] <= reg1;
                    order_book_memory_ask[write_pointer_array_ask[i_stock_id] + 1] <= i_price;
                    order_book_memory_ask[write_pointer_array_ask[i_stock_id] + 2] <= i_order_id;

                    num_trades_ask[i_stock_id] <= (num_trades_ask[i_stock_id] + 1) % BOOK_DEPTH;
                    curr_ask_price_cache[i_stock_id] <= i_price;
                    
                end
                
                curr_state <= UPDATE_CACHE;

            end
            CANCEL_ORDER: begin //2
                
                // test_index <= i_stock_id;
                if (order_book_memory_bid[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer) + 2] == i_order_id) begin
                    /* verilator lint_off WIDTH */
                    cancel_register <= (i_stock_id * BOOK_DEPTH) + ((search_pointer));
                    /* verilator lint_on WIDTH */
                    which_book <= 1;
                    curr_state <= SHIFT_BOOK;
                    search_pointer <= 0;
                    num_trades_bid[i_stock_id] <= (num_trades_bid[i_stock_id] == 0) ? (BOOK_DEPTH - 1) : (num_trades_bid[i_stock_id] - 1);
                end
                if (order_book_memory_ask[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer) + 2] == i_order_id) begin

                    /* verilator lint_off WIDTH */
                    cancel_register <= (i_stock_id * BOOK_DEPTH) + ((search_pointer));
                    /* verilator lint_on WIDTH */
                    which_book <= 0;
                    curr_state <= SHIFT_BOOK;
                    search_pointer <= 0;
                    num_trades_ask[i_stock_id] <= (num_trades_ask[i_stock_id] == 0) ? (BOOK_DEPTH - 1) : (num_trades_ask[i_stock_id] - 1);
                end
                search_pointer <= search_pointer + 1;

                // Not found means that we looked through all the orders but can't cancel, check if this is in the cache, if its the cached order, then we want to cancel it, if it isn't then we are attempting to cancel an "expired" order, in which case, do nothing?
                if (search_pointer == BOOK_DEPTH - 1) begin
                    if(best_bid_cache[(3*(i_stock_id*CACHE_DEPTH))+2] == i_order_id) begin
                        // execute has cancelled this order from the order book, but we have still kept it in cache, so now we need to find next best
                        found <= 1;
                        curr_state <= UPDATE_CACHE; 
                        search_pointer <= 0;
                    end 
                    else if (best_ask_cache[(3*(i_stock_id*CACHE_DEPTH))+2] == i_order_id) begin
                        curr_state <= UPDATE_CACHE; 
                        search_pointer <= 0;
                    end
                    else begin
                        // trying to cancel expired order, do nothing
                        curr_state <= FINISH;
                    end
                end

                
            end 
            EXECUTE_ORDER: begin //3
                test_index <= (3*i_stock_id * BOOK_DEPTH) + (3*search_pointer) + 2;
                if (order_book_memory_bid[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer) + 2] == i_order_id) begin
                    order_book_memory_bid[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer)][15:0] <= order_book_memory_bid[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer)][15:0] - i_quantity;
                    if(order_book_memory_bid[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer)][15:0] == i_quantity) begin
                        which_book <= 1;
                        /* verilator lint_off WIDTH */
                        cancel_register <= (i_stock_id * BOOK_DEPTH) + search_pointer;
                        /* verilator lint_on WIDTH */
                        curr_state <= SHIFT_BOOK;
                        num_trades_bid[i_stock_id] <= (num_trades_bid[i_stock_id] == 0) ? (BOOK_DEPTH - 1) : (num_trades_bid[i_stock_id] - 1);
                    end 
                    else begin
                        curr_state <= UPDATE_CACHE;
                    end

                end
                if (order_book_memory_ask[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer) + 2] == i_order_id) begin
                    order_book_memory_ask[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer)][15:0] <= order_book_memory_ask[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer)][15:0] - i_quantity;
                    if(order_book_memory_ask[(i_stock_id * BOOK_DEPTH) + (3*search_pointer)][15:0] == i_quantity) begin
                        which_book <= 0;
                        /* verilator lint_off WIDTH */
                        cancel_register <= (i_stock_id * BOOK_DEPTH) + search_pointer;
                        /* verilator lint_on WIDTH */
                        curr_state <= SHIFT_BOOK;
                        num_trades_ask[i_stock_id] <= (num_trades_ask[i_stock_id] == 0) ? (BOOK_DEPTH - 1) : (num_trades_ask[i_stock_id] - 1);
                    end
                    else begin
                        curr_state <= UPDATE_CACHE;
                    end
                end

                search_pointer <= search_pointer + 1;

                if (i_order_id[31:29] == 0) begin
                    reg_execute_order <= 1;
                end
                else begin
                    reg_execute_order <= 0;
                end

            end
            SHIFT_BOOK: begin //4

                if(which_book) begin
                    if ((cancel_register-(i_stock_id*BOOK_DEPTH)) < BOOK_DEPTH-1) begin // counter = cancelled trade number 
                        order_book_memory_bid[3*cancel_register] <= order_book_memory_bid[(3*cancel_register)+3];
                        order_book_memory_bid[(3*cancel_register)+1] <= order_book_memory_bid[(3*cancel_register)+4];
                        order_book_memory_bid[(3*cancel_register)+2] <= order_book_memory_bid[(3*cancel_register)+5];
                        if((cancel_register-(i_stock_id*BOOK_DEPTH)) ==  (BOOK_DEPTH - 2)) begin
                            order_book_memory_bid[3*i_stock_id*BOOK_DEPTH+((3*BOOK_DEPTH)-1)] <= 0;
                            order_book_memory_bid[3*i_stock_id*BOOK_DEPTH+((3*BOOK_DEPTH)-1)-2] <= 0;
                            order_book_memory_bid[3*i_stock_id*BOOK_DEPTH+((3*BOOK_DEPTH)-1)-1] <= 0;
                            
                        end
                        cancel_register <= cancel_register + 1;
                        curr_state <= SHIFT_BOOK;
                    end
                    else begin
                        curr_state <= UPDATE_CACHE;
                    end
                end
                else begin
                    if ((cancel_register-(i_stock_id*BOOK_DEPTH)) < BOOK_DEPTH-1) begin // counter = cancelled trade number 
                        order_book_memory_ask[3*cancel_register] <= order_book_memory_ask[(3*cancel_register)+3];
                        order_book_memory_ask[(3*cancel_register)+1] <= order_book_memory_ask[(3*cancel_register)+4];
                        order_book_memory_ask[(3*cancel_register)+2] <= order_book_memory_ask[(3*cancel_register)+5];
                        if((cancel_register-(i_stock_id*BOOK_DEPTH)) ==  (BOOK_DEPTH - 2)) begin
                            order_book_memory_ask[3*i_stock_id*BOOK_DEPTH+((3*BOOK_DEPTH)-1)] <= 0;
                            order_book_memory_ask[3*i_stock_id*BOOK_DEPTH+((3*BOOK_DEPTH)-1)-2] <= 0;
                            order_book_memory_ask[3*i_stock_id*BOOK_DEPTH+((3*BOOK_DEPTH)-1)-1] <= 0;
                        end
                        cancel_register <= cancel_register + 1;
                        curr_state <= SHIFT_BOOK;
                    end
                    else begin
                        curr_state <= UPDATE_CACHE;
                    end
                end

                search_pointer <= 0;
            end
            UPDATE_CACHE: begin //5
                case (i_order_type)
                ADD: begin
                    if(!i_trade_type) begin // 0 = buy, 1 = sell
                        if(i_price >= best_bid_cache[(i_stock_id*3)+1]) begin
                            best_bid_cache[(i_stock_id*3)] <= reg1;
                            best_bid_cache[(i_stock_id*3)+1] <= i_price;
                            best_bid_cache[(i_stock_id*3)+2] <= i_order_id;
                            
                        end
                    end else begin
                        if((i_price <= best_ask_cache[(i_stock_id*3)+1]) || (best_ask_cache[(i_stock_id*3)+1] == 0)) begin
                            best_ask_cache[(i_stock_id*3)] <= reg1;
                            best_ask_cache[(i_stock_id*3)+1] <= i_price;
                            best_ask_cache[(i_stock_id*3)+2] <= i_order_id;
                        end
                    end
                   
                    o_data_valid <= 1;
                    curr_state <= FINISH;
                    o_book_is_busy <= 0;
                end
                CANCEL: begin

                    if(!i_trade_type && (i_order_id == best_bid_cache[(i_stock_id*3) + 2])) begin 
                        // valid delete - update bid cache
                        if (order_book_memory_bid[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer) + 1] > temp_max_price) begin
                            temp_max_reg1 <= order_book_memory_bid[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer)];
                            temp_max_price <= order_book_memory_bid[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer) + 1];
                            temp_max_order_id <= order_book_memory_bid[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer) + 2];
                            curr_state <= UPDATE_CACHE; 
                        end
                        search_pointer <= search_pointer + 1;
                        if (search_pointer == BOOK_DEPTH - 1)  begin
                            // searched through all of them
                            best_bid_cache[(i_stock_id*3)] <= temp_max_reg1;
                            best_bid_cache[(i_stock_id*3)+1] <= temp_max_price;
                            best_bid_cache[(i_stock_id*3)+2] <= temp_max_order_id;
                            curr_state <= FINISH;
                        end
                    end 
                    // ask
                    else if ((i_trade_type && (i_order_id == best_ask_cache[(i_stock_id*3) + 2]))) begin
                        test_index <= (i_stock_id * BOOK_DEPTH) + (3*search_pointer);
                        if ((order_book_memory_ask[3*((i_stock_id * BOOK_DEPTH) + (3*search_pointer)) + 1] <= temp_min_price) && (order_book_memory_ask[3*((i_stock_id * BOOK_DEPTH) + (3*search_pointer)) + 1] != 0))begin
                            found <= 1;
                            temp_min_reg1 <= order_book_memory_ask[3*((i_stock_id * BOOK_DEPTH) + (3*search_pointer))];
                            temp_min_price <= order_book_memory_ask[3*((i_stock_id * BOOK_DEPTH) + (3*search_pointer)) + 1];
                            temp_min_order_id <= order_book_memory_ask[3*((i_stock_id * BOOK_DEPTH) + (3*search_pointer)) + 2];
                            curr_state <= UPDATE_CACHE;
                        end
                        search_pointer <= search_pointer + 1;
                        if (search_pointer == BOOK_DEPTH - 1)  begin
                            // searched through all of them
                            best_ask_cache[(i_stock_id*3)] <= temp_min_reg1;
                            best_ask_cache[(i_stock_id*3)+1] <= temp_min_price;
                            best_ask_cache[(i_stock_id*3)+2] <= temp_min_order_id;
                            curr_state <= FINISH;

                        end
                    end
                    else begin
                        // cancelled order is not the one in cache
                        curr_state <= FINISH;
                    end
                    
                end
                EXECUTE: curr_state <= FINISH; 
                default: ;
                endcase
                

            end
            FINISH: begin
                o_data_valid <= 1;
                o_book_is_busy <= 0;
                curr_state <= i_trading_logic_ready ? IDLE : FINISH;
                search_pointer <= 0;
                temp_min_price <= 32'b11111111111111111111111111111111;
                o_execute_order <= reg_execute_order ? 1 : 0;
                reg_execute_order <= 0;
                o_curr_time <= i_curr_time;
                o_trade_type <= ~which_book;
            end 
            // default: next_state <= curr_state; 
        endcase
     end

    always_ff @(posedge i_clk) begin
        o_best_bid <= best_bid_cache[(i_stock_id*3)+1];
        o_best_ask <= best_ask_cache[(i_stock_id*3)+1];
        o_quantity <= i_execute_order_quantity;
    end 

endmodule
