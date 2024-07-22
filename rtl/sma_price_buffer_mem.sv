// This module simply writes data to the correct location, before it writes, we need to remember what value we are overwriting and adjust the mean and sd accordingly. These outputs are fed into a "moving stats" module.
module sma_price_buffer_mem
#(
    parameter NUM_STOCKS = 4,
    parameter BUFFER_SIZE = 64,
    parameter DATA_WIDTH = 32,
    localparam ADDR_WIDTH = $clog2(BUFFER_SIZE * NUM_STOCKS)
)
(
    input logic                                     i_clk,
    input logic                                     i_write_en,
    input logic [ADDR_WIDTH - 1 : 0]                i_write_addr,
    input logic [DATA_WIDTH - 1 : 0]                i_write_data,
    output logic                                    o_is_busy,
    output logic [DATA_WIDTH - 1 : 0]               o_outgoing_price,
    output logic [DATA_WIDTH - 1 : 0]               o_incoming_price,

)

    logic [DATA_WIDTH - 1 : 0] sma_buffer [NUM_STOCKS * BUFFER_SIZE];

    always_ff @(posedge i_clk) begin // TODO: fix this so that it behaves more like a shift register
        if (i_write_en) sma_buffer[i_write_addr] <= i_write_data;
    end

    assign o_incoming_price = i_write_data;
    
    
endmodule