// this module returns the state of the inventory via a normalised position which is required in order price and quantity estimation, so we need to have some kind of shared memory. 
module inventory
#(
    parameter FP_WORD_SIZE = 64,
    parameter DATA_WIDTH = 32,
    parameter NUM_STOCKS = 4
)
(
    input logic                                 i_clk,
    input logic                                 i_reset_n,
    input logic [$clog2(NUM_STOCKS) - 1 : 0 ]   i_stock_id,
    input logic [FP_WORD_SIZE - 1 : 0]          i_max_inventory_reciprocal, // keep this the same for all stocks for simplicity
    input logic [DATA_WIDTH - 1 : 0]            i_execute_order_quantity, // When we have a execute order, we need to re adjust the normalised inventory, this needs to happen during the culculation of volatility 
    input logic                                 i_execute_order,
    input logic                                 i_execute_order_side, // 0: buy, 1: sell
    
    output logic signed [FP_WORD_SIZE - 1 : 0]  o_norm_inventory // output inventory
);

    logic signed [2*FP_WORD_SIZE - 1 : 0]         norm_inventory [NUM_STOCKS - 1 : 0];
    logic signed [FP_WORD_SIZE - 1 : 0]           temp1;
    logic signed [FP_WORD_SIZE - 1 : 0]           temp2;
    logic signed [FP_WORD_SIZE - 1 : 0]           temp3;
    logic signed [FP_WORD_SIZE - 1 : 0]           temp4;

    always_ff @(posedge i_clk) begin
        if(!i_reset_n) begin
            for(int i = 0; i < NUM_STOCKS; i++) begin
                norm_inventory[i] <= 0;
            end
        end
        else begin
            if (i_execute_order) begin
                // temp1 <= norm_inventory[i_stock_id][95:32];
                norm_inventory[i_stock_id] <= i_execute_order_side ? (norm_inventory[i_stock_id] - (({i_execute_order_quantity, {(DATA_WIDTH){1'b0}}})*i_max_inventory_reciprocal)) : (norm_inventory[i_stock_id] + (({i_execute_order_quantity, {(DATA_WIDTH){1'b0}}})*i_max_inventory_reciprocal));
            end
            else begin 
                norm_inventory[i_stock_id] <= norm_inventory[i_stock_id];
            end
        end
    end

    assign o_norm_inventory = norm_inventory[i_stock_id][95:32];
    assign temp1 = norm_inventory[0][95:32];
    assign temp2 = norm_inventory[1][95:32];
    assign temp3 = norm_inventory[2][95:32];
    assign temp4 = norm_inventory[3][95:32];

    // always_ff @(posedge i_clk) begin
    //     o_norm_inventory <= i_ren ? norm_inventory[i_stock_id][95:32] : 0;
    // end

endmodule