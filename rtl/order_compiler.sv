module order_compiler
#(
    parameter DATA_WIDTH = 32
)
(
    input logic                             i_clk,
    input logic                             i_reset_n,
    input logic [DATA_WIDTH - 1 : 0]        i_mean,
    input logic [DATA_WIDTH - 1 : 0]        i_stddev,
    input logic [DATA_WIDTH - 1 : 0]        i_threshold,
    input logic [DATA_WIDTH - 1 : 0]        i_best_bid,
    input logic [DATA_WIDTH - 1 : 0]        i_best_ask,
    input logic [DATA_WIDTH - 1 : 0]        i_fixed_risk_limit,
    input logic [15:0]                      i_base_quantity,
    input logic [DATA_WIDTH - 1 : 0]        i_current_price,
    input logic [DATA_WIDTH - 1 : 0]        i_position,
    input logic [1:0]                       i_stock_id,
    output logic [DATA_WIDTH - 1 : 0]       o_order_reg_1,
    output logic [DATA_WIDTH - 1 : 0]       o_order_reg_2,
    output logic                            o_data_valid,
);

    logic [15:0]                            quantity;
    logic                                   buy_or_sell;
    logic [DATA_WIDTH - 1 : 0]              price;       
    logic                                   hold;
    logic                                   risk_data_valid;
    logic                                   start_risk_management;
    logic                                   risk_hold;

    typedef enum logic { 
        BUY = 0,
        SELL = 1,
     } trade_t;                           

    always_ff @(posedge i_clk) begin 
        if (i_current_price > i_mean + (i_threshold * i_stddev)) begin 
            buy_or_sell <= BUY;
            hold <= 0;
        end 
        else if (i_current_price > i_mean - (i_threshold * i_stddev)) begin
            buy_or_sell <= SELL;
            hold <= 0;
        end 
        else begin
            hold <= 1
        end
        price <= buy_or_sell ? i_best_ask : i_best_bid;
        quantity <= i_fixed_risk_limit / (i_stddev * i_base_quantity);
        start_risk_management <= 1;
    end

    assign o_order_reg_1 = {12'b0, i_stock_id, (risk_hold | hold), buy_or_sell, quantity};
    assign o_order_reg_2 = price;
    assign o_data_valid = risk_data_valid; // only valid when we have evaulted risk.

    risk_management riskManagement
    (
        .i_clk(i_clk),
        .i_start(start_risk_management),
        .i_signal(buy_or_sell),
        .i_quantity(quantity),
        .i_position(i_position),
        .i_fixed_risk_limit(i_fixed_risk_limit),
        .o_hold(risk_hold)
        .o_data_valid(risk_data_valid)
    )

endmodule
