/*
ITCH Format:
Data Type           Byte Size       Type            Value Meaning                               Register Number
Message             1               8’hA            Add order                                   1
Timestamp           4               32’h0300        Time that order happened                    2
Order number        4               32’h03BA        Unique value to distinguish order           3
Buy or sell         1/8             1’b1            A Buy order                                 1
Shares              4               32’h01BB        The total number of shares                  4
Stock Symbol        8               64'h0AAB        2341 Which stock the order concerns         5, 6    
Price               4               32’hBABB        The price offered to buy                    7
*/
module parser
#(
    parameter REG_WIDTH = 32
)
(
    input logic                         i_clk, 
    input logic                         i_book_is_busy,
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
    output logic                        o_trade_type,
    output logic                        o_valid
);

    typedef enum logic [1:0] { 
        ADD = 0,
        CANCEL = 1,
        EXECUTE = 2
     } order_t;

    typedef enum logic { 
        BUY = 0,
        SELL = 1
    } trade_t;

    typedef enum logic [1:0] { 
        AAPL = 0,
        AMZN = 1,
        GOOGL = 2,
        MSFT = 3
    } stock_t;

    logic [63:0] i_stock_id;

    always_comb begin
        i_stock_id = {i_reg_4[15:0], i_reg_5, i_reg_6[31:16]};
    end

    logic [1:0] stock_id;

    always_ff @(posedge i_clk) begin

        if(!i_book_is_busy) begin
            o_valid <= 1;
            case(i_reg_1[31:24])
                8'h41: begin
                    o_order_type <= ADD;
                    o_stock_symbol <= stock_id;
                    o_order_id <= {i_reg_2[23:0], i_reg_3[31:24]};
                    o_price <= {i_reg_6[15:0], i_reg_7[31:16]};
                    o_quantity <= i_reg_4[31:16];
                    o_trade_type <= i_reg_3[16] ? BUY : SELL;
                end
                8'h58: begin
                    o_order_type <= CANCEL;
                    o_stock_symbol <= 0;
                    o_order_id <= {i_reg_2[23:0], i_reg_3[31:24]};
                    o_price <= 0;
                    o_quantity <= 0;
                    o_trade_type <= 0;
                end
                8'h45: begin 
                    o_order_type <= EXECUTE;
                    o_stock_symbol <= 0;
                    o_order_id <= {i_reg_2[23:0], i_reg_3[31:24]};
                    o_price <= 0;
                    o_quantity <= {i_reg_3[7:0], i_reg_4[31:24]};
                    o_trade_type <= 0;
                end
                default: begin 
                    o_order_type <= 0;
                    o_stock_symbol <= 0;
                    o_order_id <= 0;
                    o_price <= 0;
                    o_quantity <= 0;
                    o_trade_type <= 0;
                end
            endcase
        end
        else begin
            o_valid <= 0;
        end
    end

    always_comb begin
        case(i_stock_id)
            64'h4141504c20202020 : stock_id = AAPL;
            64'h414d5a4e20202020 : stock_id = AMZN;
            64'h474f4f474c202020 : stock_id = GOOGL;
            64'h4d53465420202020 : stock_id = MSFT;
        endcase
    end

endmodule
