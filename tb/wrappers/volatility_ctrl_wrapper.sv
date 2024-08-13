`include "../rtl/volatility_ctrl.sv"
`timescale 1ns/1ps
module volatility_ctrl_wrapper
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

    volatility_ctrl volatility_ctrl
    (
        .i_clk(i_clk),
        .i_reset_n(i_reset_n),
        .i_stock_id(i_stock_id),
        .i_data_valid(i_data_valid),
        .i_buffer_size(i_buffer_size),
        .o_write_address(o_write_address),
        .o_addr_valid(o_addr_valid)
    );

    initial
    begin
        $dumpfile("test.vcd");
        $dumpvars(0, volatility_ctrl_wrapper);
    end

endmodule