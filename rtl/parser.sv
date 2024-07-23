/*
ITCH Format:
Data Type           Byte Size       Type            Value Meaning                               Register Number
Message             1               8’hA            Add order                                   1
Timestamp           4               32’h0300        Time that order happened                    2
Order number        4               32’h03BA        Unique value to distinguish order           3
Buy or sell         1/8             1’b1            A Buy order                                 1
Shares              4               32’h01BB        The total number of shares                  4
Stock Symbol        8               64”h0AAB        2341 Which stock the order concerns         5, 6    
Price               4               32’hBABB        The price offered to buy                    7
*/
module parser
#(
    parameter REG_WIDTH = 32
)
(
    input logic                         i_clk, 
    input logic [REG_WIDTH - 1 : 0]     i_reg_1,
    input logic [REG_WIDTH - 1 : 0]     i_reg_2,
    input logic [REG_WIDTH - 1 : 0]     i_reg_3,
    input logic [REG_WIDTH - 1 : 0]     i_reg_4,
    input logic [REG_WIDTH - 1 : 0]     i_reg_5,
    input logic [REG_WIDTH - 1 : 0]     i_reg_6,
    input logic [REG_WIDTH - 1 : 0]     i_reg_7,
    output logic [1:0]                  o_stock_symbol,
    output logic [REG_WIDTH - 1 : 0]    o_order_id,
    output logic [REG_WIDTH - 1 : 0]    o_price,
    output logic [15:0]                 o_quantity,
    output logic [1:0]                  o_order_type,
    output logic                        o_trade_type
);

    always_ff @(posedge i_clk) begin
        o_stock_symbol  <= i_reg_5[1:0];
        o_order_id      <= i_reg_3;
        o_price         <= i_reg_7;
        o_quantity      <= i_reg_4[15:0];
        o_order_type    <= i_reg_1[1:0];  
        o_trade_type    <= i_reg_1[16]; 
    end

endmodule
