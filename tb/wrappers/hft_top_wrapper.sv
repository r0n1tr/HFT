`include "../rtl/hft_top.sv"
`timescale 1ns/1ps

module hft_top_wrapper
#(
    parameter NUM_STOCKS = 4,
    parameter DATA_WIDTH = 32,
    parameter FP_WORD_SIZE = 64,
    parameter BUFFER_SIZE = 32,
    parameter REG_WIDTH = 32
)
(
    input logic                          i_clk,
    input logic                          i_reset_n,
    input logic                          i_book_is_busy,
    input logic [REG_WIDTH - 1 : 0]      i_reg_1,
    input logic [REG_WIDTH - 1 : 0]      i_reg_2,
    input logic [REG_WIDTH - 1 : 0]      i_reg_3,
    input logic [REG_WIDTH - 1 : 0]      i_reg_4,
    input logic [REG_WIDTH - 1 : 0]      i_reg_5,
    input logic [REG_WIDTH - 1 : 0]      i_reg_6,
    input logic [REG_WIDTH - 1 : 0]      i_reg_7,
    input logic [REG_WIDTH - 1 : 0]      i_reg_8,

    output logic [REG_WIDTH - 1 : 0]     o_reg_1,
    output logic [REG_WIDTH - 1 : 0]     o_reg_2,
    output logic [REG_WIDTH - 1 : 0]     o_reg_3,
    output logic [REG_WIDTH - 1 : 0]     o_reg_4,
    output logic [REG_WIDTH - 1 : 0]     o_reg_5,
    output logic [REG_WIDTH - 1 : 0]     o_reg_6,
    output logic [REG_WIDTH - 1 : 0]     o_reg_7,
    output logic                         o_valid
);

    hft_top hft_top (
        .i_clk(i_clk),
        .i_reg_1(i_reg_1),
        .i_reg_2(i_reg_2),
        .i_reg_3(i_reg_3),
        .i_reg_4(i_reg_4),
        .i_reg_1(i_reg_5),
        .i_reg_5(i_reg_6),
        .i_reg_6(i_reg_7),
        .i_reg_7(i_reg_8),

        .i_reg_1(i_reg_1),
        .i_reg_2(i_reg_2),
        .i_reg_3(i_reg_3),
        .i_reg_4(i_reg_4),
        .i_reg_5(i_reg_5),
        .i_reg_6(i_reg_6),
        .i_reg_7(i_reg_7),
        .o_valid(o_valid)
    )

    initial
    begin
        $dumpfile("hft_top.vcd");
        $dumpvars;
    end

endmodule