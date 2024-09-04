module reverse_parser
#(
    parameter REG_WIDTH = 32
)
(
    input logic                         i_clk, 

    input logic [1:0]                  i_stock_symbol,
    input logic [REG_WIDTH - 1 : 0]    i_order_id,
    input logic [REG_WIDTH - 1 : 0]    i_buy_price,
    input logic [REG_WIDTH - 1 : 0]    i_sell_price, 
    input logic [REG_WIDTH - 1 : 0]    i_quantity,
    input logic                        i_trade_type,
    input logic                        i_book_is_busy,
    input logic                        i_data_valid,
    input logic [15:0]                 i_locate_code,
    input logic [15:0]                 i_tracking_number,
    input logic [47:0]                 i_timestamp,

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

    logic [61:0] counter = 0; 
    logic [63:0] stock_id;

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
            // order_type
            o_reg_0_b <=  {i_tracking_number[7:0], i_locate_code, 8'h41};
            o_reg_0_s <=  {i_tracking_number[7:0], i_locate_code, 8'h41};

            //o_order_type <= ADD;
            // add order
            o_reg_1_b <= {i_timestamp[23:0], i_tracking_number[15:8]};
            o_reg_1_s <= {i_timestamp[23:0], i_tracking_number[15:8]};

            //timestamp -- need to figure out how to do realtime 
            o_reg_2_b <= {{counter[7:0]}, {i_timestamp[47:24]}};
            o_reg_2_s <= {{counter[7:0]}, {i_timestamp[47:24]}}; 
            //order number
            o_reg_3_b <= {counter[39:8]};
            o_reg_3_s <= {counter[39:8]};

            // quantity/shares
            o_reg_4_b <= {7'b0, i_trade_type, 2'b00, counter[61:40]};
            o_reg_4_s <= {7'b0, i_trade_type, 2'b01, counter[61:40]};

            counter <= counter + 1; 
            //stock symbol
            o_reg_5_b <= i_quantity;
            o_reg_5_s <= i_quantity;

            o_reg_6_b <= stock_id[31:0];
            o_reg_6_s <= stock_id[31:0];

            o_reg_7_b <= stock_id[63:32];
            o_reg_7_s <= stock_id[63:32];

            // price from quote price module
            o_reg_8_b <= i_buy_price;
            o_reg_8_s <= i_sell_price;
        end
        else begin
            o_valid <= 0;
            o_reg_0_b <= 0;
            o_reg_1_b <= 0;
            o_reg_2_b <= 0;
            o_reg_3_b <= 0;
            o_reg_4_b <= 0;
            o_reg_5_b <= 0;
            o_reg_6_b <= 0;
            o_reg_7_b <= 0;
            o_reg_8_b <= 0;

            o_reg_0_s <= 0;
            o_reg_1_s <= 0;
            o_reg_2_s <= 0;
            o_reg_3_s <= 0;
            o_reg_4_s <= 0;
            o_reg_5_s <= 0;
            o_reg_6_s <= 0;
            o_reg_7_s <= 0;
            o_reg_8_s <= 0;
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
