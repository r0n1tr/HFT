// Control where to write data into the volatility buff
module volatility_ctrl
#(
    parameter NUM_STOCKS = 4,
    parameter BUFFER_SIZE = 20
)
(
    input logic                                             i_clk,
    input logic                                             i_reset_n,
    input logic [$clog2(NUM_STOCKS) - 1 : 0]                i_stock_id,
    input logic                                             i_data_valid,
    output logic [$clog2(NUM_STOCKS*BUFFER_SIZE) - 1 : 0]   o_write_address,
    output logic                                            o_addr_valid
);

    // need to have 4 different buffers, one for each stock - might have this as a separate module, might make this module just control where to write to

    logic [$clog2(NUM_STOCKS*BUFFER_SIZE) - 1 : 0]          write_address [NUM_STOCKS - 1 : 0];
    logic [$clog2(NUM_STOCKS*BUFFER_SIZE) - 1 : 0]          write_address_next [NUM_STOCKS - 1 : 0];

    always_ff @(posedge i_clk) begin 
        if (!i_reset_n) begin
            for (int i = 0; i < NUM_STOCKS; i++) begin
                /* verilator lint_off WIDTH */
                write_address[i] <= BUFFER_SIZE * i;
                /* verilator lint_on WIDTH */
            end
        end
        else begin
            write_address[i_stock_id] <= write_address_next[i_stock_id];
            o_addr_valid <= i_data_valid ? 1 : 0;
        end
    end

    always_comb begin
        if(i_data_valid) write_address_next[i_stock_id] = (BUFFER_SIZE*i_stock_id)+(write_address[i_stock_id] + 1)%10; 
        else write_address_next[i_stock_id] = write_address[i_stock_id];
    end

    assign o_write_address = write_address[i_stock_id];

endmodule
