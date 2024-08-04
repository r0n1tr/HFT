// module that returns the volatility^2 for spread and reference price calculations
// Var(X) = E(X^2) – (E(X))^2
module volatility_mem
#(
    parameter DATA_WIDTH = 32,
    parameter BUFFER_SIZE = 20,
    parameter NUM_STOCKS = 4
)
(
    input logic                                                 i_clk,
    input logic                                                 i_reset_n,
    input logic [$clog2(NUM_STOCKS * BUFFER_SIZE) - 1 : 0]      i_write_address,
    input logic [DATA_WIDTH - 1 : 0]                            i_best_ask,
    input logic [DATA_WIDTH - 1 : 0]                            i_best_bid,
    input logic [$clog2(NUM_STOCKS) - 1 : 0]                    i_stock_id,
    input logic                                                 i_valid,
    output logic [DATA_WIDTH - 1 : 0]                           o_volatility,
    output logic [DATA_WIDTH - 1 : 0]                           o_curr_price,
    output logic                                                o_data_valid
);  

    logic [DATA_WIDTH - 1 : 0]  buffer [(NUM_STOCKS*BUFFER_SIZE) - 1 : 0];
    logic [DATA_WIDTH - 1 : 0]  moving_sum [NUM_STOCKS- 1 : 0];
    logic [DATA_WIDTH - 1 : 0]  moving_square_sum[NUM_STOCKS - 1 : 0];

    logic [DATA_WIDTH - 1 : 0]  remove_reg[NUM_STOCKS - 1 : 0];

    always_ff @(posedge i_clk) begin
        if(!i_reset_n) begin
            for(int i = 0; i < NUM_STOCKS*BUFFER_SIZE; i++) begin
                buffer[i] = 0;
            end
        end
        else begin
            if (i_valid) begin
                buffer[i_write_address] <= (i_best_ask+i_best_bid) >>> 2;
                moving_sum[i_stock_id] <= moving_sum[i_stock_id] - remove_reg[i_stock_id] + (i_best_ask+i_best_bid) >>> 2;
                moving_square_sum[i_stock_id] <= moving_square_sum[i_stock_id] - (remove_reg[i_stock_id]**2) + (((i_best_ask+i_best_bid) >>> 2)**2);
                o_data_valid <= 1;
                o_curr_price <= (i_best_ask+i_best_bid) >>> 2;
            end
            else begin
                o_data_valid <= 0;
            end
        end
    end

    always_comb begin
        // store what we are overwriting in something a reg to calculate the removal's effect on the stats
        remove_reg[i_stock_id] = buffer[i_write_address];
    end

    assign o_volatility = (moving_square_sum/BUFFER_SIZE) - ((moving_sum/BUFFER_SIZE)**2); // TODO: replace with fixed point. not sure if this logic is entirely valid though - need to testbench


endmodule