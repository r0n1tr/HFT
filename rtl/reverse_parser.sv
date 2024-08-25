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
module reverse_parser
#(
    parameter REG_WIDTH = 32
)
(
    input logic                         i_clk, 

    input logic [1:0]                  i_stock_symbol,
    //input logic [REG_WIDTH - 1 : 0]    i_order_id,
    input logic [REG_WIDTH - 1 : 0]    i_buy_price,
    input logic [REG_WIDTH - 1 : 0]    i_sell_price, // 
    input logic [15:0]                 i_quantity, // from quantity estimation module
    //input logic [1:0]                  i_order_type,
    input logic                        i_trade_type,
    input logic                        i_book_is_busy,
    // input logic [63:0]                 i_stock_id,
    input logic                        i_data_valid,

    
    output logic [REG_WIDTH - 1 : 0]     o_reg_1,
    output logic [REG_WIDTH - 1 : 0]     o_reg_2,
    output logic [REG_WIDTH - 1 : 0]     o_reg_3,
    output logic [REG_WIDTH - 1 : 0]     o_reg_4,
    output logic [REG_WIDTH - 1 : 0]     o_reg_5,
    output logic [REG_WIDTH - 1 : 0]     o_reg_6,
    output logic [REG_WIDTH - 1 : 0]     o_reg_7,
    output logic                         o_valid

);

    typedef enum logic [1:0] { 
        ADD = 0,
        CANCEL = 1,
        EXECUTE = 2
    } i_order_type;

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


    // always_comb begin
    //     {o_reg_4[15:0], o_reg_5, o_reg_6[31:16]} = i_stock_id;
    // end


    always_ff @(posedge i_clk) begin

        if(i_data_valid) begin
            o_valid <= 1;
            //o_order_type <= ADD;
            // add order
            o_reg_1 <= {{8'hA}, i_trade_type};

            //timestamp -- need to figure out how to do realtime 
            o_reg_2 <= 32'h0300; // insert realtime but for now hardcoded

            //order number
            o_reg_3 <= 32'h03BA; //again have to figure out how to randomly generate unique ref

            // quantity/shares
            o_reg_4 <= {{15'b0}, i_quantity};

            //stock symbol
            case (i_stock_symbol)
                00: begin
                    o_reg_5 <= 32'h4141504c;
                    o_reg_6 <= 32'h20202020;
                end 
                01: begin
                    o_reg_5 <= 32'h414d5a4e;
                    o_reg_6 <= 32'h20202020;
                end    
                10: begin
                    o_reg_5 <= 32'h474f4f47;
                    o_reg_6 <= 32'h4c202020;
                end
                11: begin
                    o_reg_5 <= 32'h4d534654;
                    o_reg_6 <= 32'h20202020;
                end
            default: begin
                    o_reg_5 <= 32'h0;
                    o_reg_6 <= 32'h0;
            end
            endcase

            // price from quote price module
            o_reg_7 <= i_trade_type ? i_buy_price : i_sell_price;
        end
        else begin
            o_valid <= 0;
            o_reg_1 <= 0;
            o_reg_2 <= 0;
            o_reg_3 <= 0;
            o_reg_4 <= 0;
            o_reg_5 <= 0;
            o_reg_6 <= 0;
            o_reg_7 <= 0;
        end
    end

    // always_comb begin
    //     case(i_stock_id)
    //         64'h4141504c20202020 : stock_id = AAPL;
    //         64'h414d5a4e20202020 : stock_id = AMZN;
    //         64'h474f4f474c202020 : stock_id = GOOGL;
    //         64'h4d53465420202020 : stock_id = MSFT;
    //     endcase
    // end

endmodule
