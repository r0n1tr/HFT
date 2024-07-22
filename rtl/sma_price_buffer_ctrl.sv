// This module just provides the address to the buffer and provides control signals based on the address.
module sma_price_buffer_ctrl
#(
    parameter BUFFER_SIZE = 64, // easier to keep this as a power of 2 - shifitng to get mean but not that deep
    parameter NUM_STOCKS = 4,
    parameter PRICE_WIDTH = 32,
    localparam ADDR_WIDTH = $clog2(BUFFER_SIZE*NUM_STOCKS)
)
(
    input logic                             i_clk,
    input logic                             i_reset_n,
    input logic                             i_write_en,
    input logic [1:0]                       i_stock_id,
    input logic                             i_mem_is_busy, // TODO, make use of this
    output logic [ADDR_WIDTH - 1 : 0]       o_wr_addr,
    output logic                            o_is_buffer_full,
    output logic                            o_index,
)

    logic [$clog2(BUFFER_SIZE) - 1 : 0] index_array [$clog2(NUM_STOCKS) - 1 : 0]; 

    logic [ADDR_WIDTH - 1 : 0] wr_addr_array [$clog2(NUM_STOCKS) - 1 : 0]; 

    logic [ADDR_WIDTH - 1 : 0] wr_addr_array_next [$clog2(NUM_STOCKS) - 1 : 0];

    logic is_buffer_full_array [$clog2(NUM_STOCKS) - 1 : 0];

    always_ff @(posedge i_clk) begin
        if(!i_reset_n) begin
            for (int i = 0; i < NUM_STOCKS; i++) begin
                index_array[i] = 0;
                wr_addr_array[i] = 0;
                wr_addr_array_next[i] = 0;
            end
        end
        else begin
            wr_addr_array[i_stock_id] <= wr_addr_array_next[i_stock_id];
            index_array[i_stock_id] <= index_array[i_stock_id] + 1;
            if(index_array[i_stock_id] == BUFFER_SIZE - 1) is_buffer_full_array[i_stock_id] <= 1;
        end
    end

    always_comb begin
        // logic for next
        if (i_write_en) wr_addr_array_next[i_stock_id] = i_stock_id * BUFFER_SIZE + (index_array[i_stock_id] % BUFFER_SIZE);
        else wr_addr_array_next[i_stock_id] = wr_addr_array[i_stock_id];
    end

    assign o_wr_addr = wr_addr_array[i_stock_id];
    assign o_is_buffer_full = is_buffer_full_array[i_stock_id];
    assign o_index = index_array[i_stock_id];

endmodule
