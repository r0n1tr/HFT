// ADD
// # Bytes:      Bits:       reg:                                Bitreglength    Message:
// #     1       0-7:        reg0[7:0]                           8               "A" for add order 
// #     2       8-23:       reg0[23:8]                          16              Locate code identifying the security - a random number associated with a specific stock, new every day
// #     2       24-39:      reg1[7:0] reg0[31:24]               16              Internal tracking number
// #     6       40-87:      reg2[23:0] reg1[31:8]               48              Timestamp - nanoseconds since midnight - we will just do seconds since start of trading day
// #     8       88-151:     reg4[23:0] reg3[31:0] reg2[31:24]   64              Order ID
// #     1       152-159:    reg4[31:24]                         8               Buy or sell indicator - 0 or 1
// #     4       160-191:    reg5[31:0]                          32              Number of shares / order quantity
// #     8       192-255:    reg7[31:0] reg6[31:0]               64              Stock ID
// #     4       255-287:    reg8[31:0]                          32              Price

// CANCEL Order Format - It's actually DELETE that we are doing according to documentation
//         Bytes:     Bits:          reg:                                       Message:
//         1           0-7:          reg0[7:0]                                   "D" for delete order
//         2           8-23:         reg0[23:8]                                  Locate Code for the Stock
//         2           24-39:        reg1[7:0] reg0[31:24]                       Internal tracking number 
//         6           40-87:        reg2[23:0] reg1[31:8]                       Timestamp
//         8           88-151:       reg4[23:0] reg3[31:0] reg2[31:24]           Order ID
//         8           152-215:      reg6[23:0], reg5[31:0], reg4[31:24]         Stock ID - Not part of documentation, but we need this because of how we implemented the order book cancel function
//                     216-287:                                                  0s for 32 bit register allignment


// EXECUTE Order Format - 
//         Bytes:      Bits:    REG:                                             Message:
//         1           0-7:     reg0[7:0]                                        "E" for execute order
//         2           8-23:      reg0[23:8]                                     Locate Code for the Stock
//         2           24-39:     reg1[7:0] reg0[31:24]                          Internal tracking number 
//         6           40-87:     reg2[23:0] reg1[31:8]                          Timestamp
//         8           88-151:    reg4[23:0] reg3[31:0] reg2[31:24]              Order ID
//         4           152-183:   reg5[23:0], reg4[31:24]                        Number of shares
//         8           184-247:   reg7[23:0], reg6[31:0], reg5[31:24]            Stock ID - Not part of documentation, but we need this because of how we implemented the order book execute function
//                     248-287:                                                  0s for 32 bit register allignment
 
module parser

#(
    parameter REG_WIDTH = 32,
    parameter FP_WORD_SIZE = 64
)
(
    input logic                         i_clk, 
    input logic                         i_data_valid,
    input logic                         i_book_is_busy,
    input logic [REG_WIDTH - 1 : 0]     i_reg_0, // order type - add cancel etc.
    input logic [REG_WIDTH - 1 : 0]     i_reg_1,
    input logic [REG_WIDTH - 1 : 0]     i_reg_2,
    input logic [REG_WIDTH - 1 : 0]     i_reg_3,
    input logic [REG_WIDTH - 1 : 0]     i_reg_4,
    input logic [REG_WIDTH - 1 : 0]     i_reg_5,
    input logic [REG_WIDTH - 1 : 0]     i_reg_6,
    input logic [REG_WIDTH - 1 : 0]     i_reg_7,
    input logic [REG_WIDTH - 1 : 0]     i_reg_8,
    
    output logic [1:0]                  o_stock_symbol,
    output logic [REG_WIDTH - 1 : 0]    o_order_id,
    output logic [REG_WIDTH - 1 : 0]    o_price,
    output logic [REG_WIDTH - 1 : 0]    o_quantity,
    output logic [1:0]                  o_order_type,
    output logic                        o_trade_type,
    output logic [63 : 0]               o_curr_time,
    output logic [15:0]                 o_locate_code,
    output logic [15:0]                 o_tracking_number,
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
        case(i_reg_0[7:0])
            8'h41:
                i_stock_id = {i_reg_7, i_reg_6};
            8'h58:
                i_stock_id = {i_reg_6[23:0], i_reg_5, i_reg_4[31:24]};
            8'h45:
                i_stock_id = {i_reg_7[23:0], i_reg_6[31:0], i_reg_5[31:24]};
            default:
                i_stock_id = 64'b0;
        endcase
        o_locate_code = i_reg_0[23:8];
        o_tracking_number = {i_reg_1[7:0], i_reg_0[31:24]};
    end

    logic [1:0] stock_id;

    always_ff @(posedge i_clk) begin

        if(i_data_valid) begin
            o_valid <= 1;
            case(i_reg_0[7:0])
                8'h41: begin
                    o_order_type <= ADD;
                    o_stock_symbol <= stock_id; 
                    o_curr_time <= {i_reg_2[23:0], i_reg_1[31:8]};
                    o_order_id <= {i_reg_4[23:0], i_reg_3, i_reg_2[31:24]};

                    o_trade_type <= i_reg_4[31:24] ? SELL : BUY;
                    o_quantity <= i_reg_5;
                    o_price <= {i_reg_8};
                end
                8'h58: begin
                    o_order_type <= CANCEL;
                    o_stock_symbol <= stock_id;
                    o_curr_time <= {i_reg_2[23:0], i_reg_1[31:8]};
                    o_order_id <= {i_reg_4[23:0], i_reg_3, i_reg_2[31:24]};
                    
                    o_price <= 0;
                    o_quantity <= 0;
                    o_trade_type <= 0;
                end
                8'h45: begin 
                    o_order_type <= EXECUTE;
                    o_stock_symbol <= stock_id;
                    o_curr_time <= {i_reg_2[23:0], i_reg_1[31:8]};
                    o_order_id <= {i_reg_4[23:0], i_reg_3, i_reg_2[31:24]};
                    o_quantity <= {i_reg_5[23:0], i_reg_4[31:24]};

                    o_trade_type <= 0;
                    o_price <= 0;
                end
                default: begin 
                    o_order_type <= 0;
                    o_stock_symbol <= 0;
                    o_order_id <= 0;
                    o_price <= 0;
                    o_quantity <= 0;
                    o_trade_type <= 0;
                    o_curr_time <= 48'b0;
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
