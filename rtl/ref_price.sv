module ref_price
#(
    parameter DATA_WIDTH = 32,
    parameter MAX_INVENTORY_SIZE = 100000 // undecided on whether this should be a param on not
    parameter TERMINAL_TIME = 10000 // TODO: fill this out
    parameter RISK_FACTOR = 0.2 // TODO: confirm this too
)
(
    input logic                                         i_clk,
    input logic                                         i_reset_n,
    input logic [DATA_WIDTH - 1 : 0]                    i_curr_price,
    input logic [$clog2(MAX_INVENTORY_SIZE) - 1 : 0]    i_inventory_state,
    input logic [DATA_WIDTH - 1 : 0]                    i_curr_time, 
    input logic [DATA_WIDTH - 1 : 0]                    i_volatility,
    input logic                                         i_data_valid,
    output logic [DATA_WIDTH - 1 : 0]                   o_ref_price,
    output logic                                        o_data_valid
);

    always_ff @(posedge i_clk) begin
        if(!i_reset_n) begin
            o_ref_price <= 0;
            o_data_valid <= 0;
        end
        else begin
            if(i_data_valid) begin 
                o_data_valid <= i_curr_price - (i_inventory_state * RISK_FACTOR * i_volatility*(TERMINAL_TIME - i_curr_time));
                o_data_valid <= 1;
            end
            else begin
                o_ref_price <= 0;
                o_data_valid <= 0;
            end
        end
    end

endmodule