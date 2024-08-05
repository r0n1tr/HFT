// this module returns the state of the inventory via a normalised position which is required in order price and quantity estimation, so we need to have some kind of shared memory. 
module inventory
#(
    parameter DATA_WIDTH = 32,
    parameter INVENTORY_BOUND = 100000, // TODO:complete this, might be different bounds for different stocks, but keep it simple for now.
    parameter NUM_STOCKS = 4
)
(
    input logic                                 i_clk,
    input logic                                 i_reset_n,
    input logic [$clog2(NUM_STOCKS) - 1 : 0 ]   i_stock_id,
    input logic [DATA_WIDTH - 1 : 0]            i_buy_quantity,
    input logic [DATA_WIDTH - 1 : 0]            i_ask_quantity,
    input logic                                 i_data_valid,
    input logic                                 i_ren,
    output logic signed [DATA_WIDTH - 1 : 0]    o_norm_position
);

    logic signed [DATA_WIDTH - 1 : 0]           norm_position [NUM_STOCKS - 1 : 0];

    always_ff @(posedge i_clk) begin
        if(!i_reset_n) begin
            for(int i = 0; i < NUM_STOCKS; i++) begin
                norm_position[i] <= 0;
            end
        end
        else begin
            if(i_data_valid) begin
                norm_position[i_stock_id] <= norm_position[i_stock_id] + (i_buy_quantity - i_ask_quantity)/INVENTORY_BOUND; // TODO: convert to fixed point.
            end
        end
    end

    assign o_norm_position = i_ren ? norm_position[i_stock_id] : 0;


endmodule