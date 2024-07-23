module parser
#(
    parameter REG_WIDTH = 32
)
(
    input logic                         i_clk, 
    input logic [REG_WIDTH - 1 : 0]     i_reg_1,
    input logic [REG_WIDTH - 1 : 0]     i_reg_2,
    input logic [REG_WIDTH - 1 : 0]     i_reg_3,
    output logic [1:0]                  o_stock_symbol,
    output logic [REG_WIDTH - 1 : 0]    o_order_id,
    output logic [REG_WIDTH - 1 : 0]    o_price,
    output logic [15:0]                 o_quantity,
    output logic [1:0]                  o_order_type
)

    always_ff @(posedge i_clk) begin
        // TODO: complete based on ITCH structure
        o_stock_symbol <= ;
        o_order_id <= ;
        o_price <= ;
        o_quantity <= ;
        o_order_type <= ;   
    end

endmodule
