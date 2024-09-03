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
    input logic [REG_WIDTH - 1 : 0]      i_reg_0,
    input logic [REG_WIDTH - 1 : 0]      i_reg_1,
    input logic [REG_WIDTH - 1 : 0]      i_reg_2,
    input logic [REG_WIDTH - 1 : 0]      i_reg_3,
    input logic [REG_WIDTH - 1 : 0]      i_reg_4,
    input logic [REG_WIDTH - 1 : 0]      i_reg_5,
    input logic [REG_WIDTH - 1 : 0]      i_reg_6,
    input logic [REG_WIDTH - 1 : 0]      i_reg_7,
    input logic [REG_WIDTH - 1 : 0]      i_reg_8,

    output logic [REG_WIDTH - 1 : 0]     o_reg_0_b,
    output logic [REG_WIDTH - 1 : 0]     o_reg_1_b,
    output logic [REG_WIDTH - 1 : 0]     o_reg_2_b,
    output logic [REG_WIDTH - 1 : 0]     o_reg_3_b,
    output logic [REG_WIDTH - 1 : 0]     o_reg_4_b,
    output logic [REG_WIDTH - 1 : 0]     o_reg_5_b,
    output logic [REG_WIDTH - 1 : 0]     o_reg_6_b,
    output logic [REG_WIDTH - 1 : 0]     o_reg_7_b,
    output logic [REG_WIDTH - 1 : 0]     o_reg_8_b,

    output logic [REG_WIDTH - 1 : 0]     o_reg_0_s,
    output logic [REG_WIDTH - 1 : 0]     o_reg_1_s,
    output logic [REG_WIDTH - 1 : 0]     o_reg_2_s,
    output logic [REG_WIDTH - 1 : 0]     o_reg_3_s,
    output logic [REG_WIDTH - 1 : 0]     o_reg_4_s,
    output logic [REG_WIDTH - 1 : 0]     o_reg_5_s,
    output logic [REG_WIDTH - 1 : 0]     o_reg_6_s,
    output logic [REG_WIDTH - 1 : 0]     o_reg_7_s,
    output logic [REG_WIDTH - 1 : 0]     o_reg_8_s,
    output logic                         o_valid
);

    hft_top hft_top (
        .i_clk(i_clk),
        .i_reg_0(i_reg_0),
        .i_reg_1(i_reg_1),
        .i_reg_2(i_reg_2),
        .i_reg_3(i_reg_3),
        .i_reg_4(i_reg_4),
        .i_reg_5(i_reg_5),
        .i_reg_6(i_reg_6),
        .i_reg_7(i_reg_7),
        .i_reg_8(i_reg_8),

        .o_reg_0_b(o_reg_0_b),
        .o_reg_1_b(o_reg_1_b),
        .o_reg_2_b(o_reg_2_b),
        .o_reg_3_b(o_reg_3_b),
        .o_reg_4_b(o_reg_4_b),
        .o_reg_5_b(o_reg_5_b),
        .o_reg_6_b(o_reg_6_b),
        .o_reg_7_b(o_reg_7_b),
        .o_reg_8_b(o_reg_8_b),

        .o_reg_0_s(o_reg_0_s),
        .o_reg_1_s(o_reg_1_s),
        .o_reg_2_s(o_reg_2_s),
        .o_reg_3_s(o_reg_3_s),
        .o_reg_4_s(o_reg_4_s),
        .o_reg_5_s(o_reg_5_s),
        .o_reg_6_s(o_reg_6_s),
        .o_reg_7_s(o_reg_7_s),
        .o_reg_8_s(o_reg_8_s),
        .o_valid(o_valid)
    );

    initial
    begin
        $dumpfile("hft_top.vcd");
        $dumpvars;
    end

endmodule