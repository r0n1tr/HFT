module risk_management
#(
    parameter DATA_WIDTH = 32
)
(
    input logic                             i_clk,
    input logic                             i_start,
    input logic                             i_signal, 
    input logic [15:0]                      i_quantity,
    input logic [DATA_WIDTH - 1 : 0]        i_position,
    input logic [DATA_WIDTH - 1 : 0]        i_fixed_risk_limit,
    output logic                            o_hold,
    output logic                            o_data_valid
);

    enum {
        BUY = 0,
        SELL = 1
    }

    always_ff @(posedge i_clk) begin 
        o_data_valid <= 0;
        if (i_start) begin
            case(i_signal)
                BUY: begin
                    if (i_position + i_quantity <= i_fixed_risk_limit) o_hold <= 0;
                    else o_hold <= 1;
                    o_data_valid <= 1;
                end
                SELL: begin
                    if (i_position - i_quantity >= -i_fixed_risk_limit) o_hold <= 0;
                    else o_hold <= 1;
                    o_data_valid <= 1;
                end
            endcase
        end
    end

endmodule
