// Control where to write data into the volatility buff
module volatility_ctrl
#(
    parameter NUM_STOCKS = 4,
    parameter BUFFER_SIZE = 20,
    parameter DATA_WIDTH = 32
)
(
    input logic                                             i_clk,
    input logic                                             i_reset_n,
    input logic [$clog2(NUM_STOCKS) - 1 : 0]                i_stock_id,
    input logic                                             i_data_valid,
    input logic [DATA_WIDTH - 1 : 0]                        i_buffer_size,
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
                write_address[i] <= i_buffer_size * i;
                /* verilator lint_on WIDTH */
            end
            o_addr_valid <= 0;
        end
    end

    always_comb begin
        if(i_data_valid) begin
            write_address_next[i_stock_id] = (i_buffer_size*i_stock_id)+((write_address[i_stock_id])%i_buffer_size); 
        end
        else begin
            write_address_next[i_stock_id] = write_address[i_stock_id];
        end
    end

    always_ff @(posedge i_clk) begin
        if(i_data_valid) begin
            write_address[i_stock_id] <= write_address_next[i_stock_id] + 1;
            o_write_address <= write_address_next[i_stock_id];
            o_addr_valid <= 1;
        end 
        else begin
            o_addr_valid <= 0; 
            write_address[i_stock_id] <= write_address[i_stock_id];
        end
    end

endmodule
