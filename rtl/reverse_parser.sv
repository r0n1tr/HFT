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
    input logic [REG_WIDTH - 1 : 0]    i_quantity, // from quantity estimation module
    //input logic [1:0]                  i_order_type,
    input logic                        i_trade_type,
    input logic                        i_book_is_busy,
    // input logic [63:0]                 i_stock_id,
    input logic                        i_data_valid,
    input logic [15:0]                 i_locate_code,
    input logic [15:0]                 i_tracking_number,
    input logic [47:0]                 i_timestamp,

    output logic [REG_WIDTH - 1 : 0]     o_reg_0,
    output logic [REG_WIDTH - 1 : 0]     o_reg_1,
    output logic [REG_WIDTH - 1 : 0]     o_reg_2,
    output logic [REG_WIDTH - 1 : 0]     o_reg_3,
    output logic [REG_WIDTH - 1 : 0]     o_reg_4,
    output logic [REG_WIDTH - 1 : 0]     o_reg_5,
    output logic [REG_WIDTH - 1 : 0]     o_reg_6,
    output logic [REG_WIDTH - 1 : 0]     o_reg_7,
    output logic [REG_WIDTH - 1 : 0]     o_reg_8,
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

        if(!i_data_valid) begin
            o_valid <= 0;
            // order_type
            o_reg_0 <=  {i_tracking_number[7:0], i_locate_code, 8'h41};

            //o_order_type <= ADD;
            // add order
            o_reg_1 <= {i_timestamp[24:0], i_tracking_number[15:8]};

            //timestamp -- need to figure out how to do realtime 
            o_reg_2 <= {i_order_id[7:0], i_timestamp[47:24]}; 
            //order number
            o_reg_3 <= i_order_id[39:8]; 

            // quantity/shares
            o_reg_4 <= {{i_trade_type}, i_order_id[63:40]};

            //stock symbol
            o_reg_5 <= i_quantity;
            o_reg_6 <= stock_id[31:0]
            o_reg_7 <= stock_id[63:32]
            // price from quote price module
            o_reg_ <= i_trade_type ? i_buy_price : i_sell_price;
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
    //may need to add real stock id for output, not too sure yet.
    always_comb begin
        case(i_stock_symbol)
            AAPL : stock_id = 64'h4141504c20202020;
            AMZN : stock_id = 64'h414d5a4e20202020;
            GOOGL : stock_id = 64'h474f4f474c202020; 
            MSFT : stock_id = 64'h4d53465420202020;
        endcase
    end

endmodule
