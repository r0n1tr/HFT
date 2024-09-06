// module that returns the volatility^2 for spread and reference price calculations
// Var(X) = E(X^2) – (E(X))^2
// For this, all integer data is 64 bits, so FP: Q64.32 - so FP input needs to be padded with 32'b0
module volatility_mem
#(
    parameter FP_WORD_SIZE = 64,
    parameter DATA_WIDTH = 32,
    parameter BUFFER_SIZE = 32,
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
    // input logic [DATA_WIDTH - 1 : 0]                            i_buffer_size,
    input logic [FP_WORD_SIZE - 1 : 0]                          i_buffer_size_reciprocal,
    output logic [FP_WORD_SIZE - 1 : 0]                         o_volatility,
    output logic [DATA_WIDTH - 1 : 0]                           o_curr_price,
    output logic                                                o_buffer_full,
    output logic                                                o_data_valid
);  

    logic [DATA_WIDTH - 1 : 0]  buffer [(NUM_STOCKS*BUFFER_SIZE) - 1 : 0];
    logic [DATA_WIDTH - 1 : 0]  moving_sum [NUM_STOCKS- 1 : 0];
    logic [2*DATA_WIDTH - 1 : 0]  moving_square_sum[NUM_STOCKS - 1 : 0]; // need to be made bigger

    logic [DATA_WIDTH - 1 : 0]  remove_reg[NUM_STOCKS - 1 : 0];

    logic full_reg[NUM_STOCKS - 1 : 0];


    // logic [DATA_WIDTH - 1 : 0]  moving_sum_t;
    // logic [2*DATA_WIDTH - 1 : 0]  moving_square_sum_t;
    // logic [DATA_WIDTH - 1 : 0]  remove_reg_t;
    // logic [FP_WORD_SIZE - 1 : 0]  o_volatility_t;
    logic [3*FP_WORD_SIZE - 1 : 0]  mean_squared;
    // logic [FP_WORD_SIZE - 1 : 0]  mean;
    logic [6*FP_WORD_SIZE - 1 : 0]  squared_mean;
    // logic [FP_WORD_SIZE - 1 : 0]  term4;
    // logic [95: 0]  term5;
    // logic [FP_WORD_SIZE - 1 : 0]  term6;
    // logic [FP_WORD_SIZE - 1 : 0]  term7;

    // logic flag;

    // logic [DATA_WIDTH-1:0]    term1;
    // logic [95:0]    term2;
    // logic [63:0]    term3;

    // logic [95:0]    temp1;
    // logic [95:0]    temp2;

    always_ff @(posedge i_clk) begin
        if(!i_reset_n) begin
            for(int i = 0; i < NUM_STOCKS*BUFFER_SIZE; i++) begin
                buffer[i] <= 0;
            end
            for (int j = 0; j < NUM_STOCKS; j++) begin
                moving_sum[j] <= 0;
                moving_square_sum[j] <= 0;
                remove_reg[j] <= 0;
                full_reg[j] <= 0;
            end
            o_data_valid <= 0;
            o_curr_price <= 0;
            // flag <= 0;
        end
        else begin
            if (i_valid) begin
                // flag <= 0;
                buffer[i_write_address] <= ((i_best_ask+i_best_bid) >>> 1);
                moving_sum[i_stock_id] <= moving_sum[i_stock_id] - remove_reg[i_stock_id] + ((i_best_ask+i_best_bid) >>> 1);
                moving_square_sum[i_stock_id] <= moving_square_sum[i_stock_id] - (remove_reg[i_stock_id]**2) + (((i_best_ask+i_best_bid) >>> 1)**2);
                o_data_valid <= 1;
                if (i_best_ask == 0) begin
                    o_curr_price <= i_best_bid;
                end 
                else if (i_best_bid == 0) begin
                    o_curr_price <= i_best_bid;
                end
                else begin
                    o_curr_price <= ((i_best_ask+i_best_bid) >>> 1);
                end
                // term1 <= i_write_address - BUFFER_SIZE + 1;
                if(((i_write_address-BUFFER_SIZE+1) % BUFFER_SIZE) == 0) begin
                    // buffer is full
                    o_buffer_full <= 1;
                    full_reg[i_stock_id] <= 1;
                end
                else begin
                    o_buffer_full <= full_reg[i_stock_id];
                end
            end
            else begin
                o_data_valid <= 0;
                // flag <= 1;
                o_curr_price <= 0;
            end
        end
    end

    always_comb begin
        if(i_valid) remove_reg[i_stock_id] = buffer[i_write_address];
        else remove_reg[i_stock_id] = 0;
    end



    always_comb begin 
        // E(X)^2
        // temp1 = {moving_square_sum[i_stock_id], (32'b0)};
        // temp2 = {(32'b0), (i_buffer_size_reciprocal)};
        mean_squared = ({moving_square_sum[i_stock_id], (32'b0)}) * ({(32'b0), (i_buffer_size_reciprocal)}); // (96 bit * 96 bit - results in 192 bit number - select middle 96.)
        
        // E(X)
        // mean = moving_sum[i_stock_id]>>>division;
        //(E(X))^2
        squared_mean = ({moving_sum[i_stock_id], (32'b0)}*({(32'b0), (i_buffer_size_reciprocal)}))*({moving_sum[i_stock_id], (32'b0)}*({(32'b0), (i_buffer_size_reciprocal)})); // results in 384 bit number

        // term2 = squared_mean[239:144];
        // term3 = mean_squared[109:48];
        // term5 = (mean_squared[143:48]-squared_mean[239:144]);
        
        // o_volatility_t = term6 - term7;
    end

    // assign term1 = buffer[95];
    // assign moving_square_sum_t = moving_square_sum[i_stock_id];
    // assign moving_sum_t = moving_sum[i_stock_id];
    // assign remove_reg_t = remove_reg[i_stock_id];
    // assign term1 = mean_squared[127:32];
    // assign term2 = squared_mean[191:96];
    // assign term1 = moving_sum[i_stock_id];
    assign o_volatility = mean_squared[127:32]-squared_mean[191:96];
    // assign o_volatility = mean_squared[95:32]-squared_mean[159:96];
    // assign term5 = mean_squared[127:32]-squared_mean[191:96];
endmodule
