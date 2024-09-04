// TODO: need to add logic for when the outputs are valid - should be done when order is added (cache not updated) or after the cache is updated.
// trade_type: 1 = buy, 0 = sell
module order_book 
#(  parameter NUM_STOCKS = 4,
    parameter BOOK_DEPTH = 10, // number of orders we want to store per stock
    parameter REG_WIDTH = 32,
    parameter CACHE_DEPTH = 1
)
(

    // Testing signals:
    output logic      [31:0] tb_reg_1,
    output logic      [31:0] tb_reg_2,
    output logic      [31:0] tb_reg_3,   
    output logic      [31:0] tb_reg_4,
    output logic      [31:0] tb_reg_5,
    output logic      [31:0] tb_reg_6,
    output logic      [31:0] tb_reg_7,
    output logic      [31:0] tb_reg_8,
    output logic      [31:0] tb_reg_9,
    output logic      [31:0] tb_reg_10,
    output logic      [31:0] tb_reg_11,
    output logic      [31:0] tb_reg_12,
    output logic      [31:0] tb_reg_13,
    output logic      [31:0] tb_reg_14,
    output logic      [31:0] tb_reg_15,
    output logic      [31:0] tb_reg_16,
    output logic      [31:0] tb_reg_17,
    output logic      [31:0] tb_reg_18,
    output logic      [31:0] tb_reg_19,
    output logic      [31:0] tb_reg_20,
    output logic      [31:0] tb_reg_21,
    output logic      [31:0] tb_reg_22,
    output logic      [31:0] tb_reg_23,
    output logic      [31:0] tb_reg_24,
    output logic      [31:0] tb_reg_25,
    output logic      [31:0] tb_reg_26,
    output logic      [31:0] tb_reg_27,
    output logic      [31:0] tb_reg_28,
    output logic      [31:0] tb_reg_29,
    output logic      [31:0] tb_reg_30,
    output logic      [31:0] tb_reg_31,
    output logic      [31:0] tb_reg_32,
    output logic      [31:0] tb_reg_33,   
    output logic      [31:0] tb_reg_34,
    output logic      [31:0] tb_reg_35,
    output logic      [31:0] tb_reg_36,
    output logic      [31:0] tb_reg_37,
    output logic      [31:0] tb_reg_38,
    output logic      [31:0] tb_reg_39,
    output logic      [31:0] tb_reg_40,
    output logic      [31:0] tb_reg_41,
    output logic      [31:0] tb_reg_42,
    output logic      [31:0] tb_reg_43,
    output logic      [31:0] tb_reg_44,
    output logic      [31:0] tb_reg_45,
    output logic      [31:0] tb_reg_46,
    output logic      [31:0] tb_reg_47,
    output logic      [31:0] tb_reg_48,
    output logic      [31:0] tb_reg_49,
    output logic      [31:0] tb_reg_50,
    output logic      [31:0] tb_reg_51,
    output logic      [31:0] tb_reg_52,
    output logic      [31:0] tb_reg_53,
    output logic      [31:0] tb_reg_54,
    output logic      [31:0] tb_reg_55,
    output logic      [31:0] tb_reg_56,
    output logic      [31:0] tb_reg_57,
    output logic      [31:0] tb_reg_58,
    output logic      [31:0] tb_reg_59,
    output logic      [31:0] tb_reg_60,
    output logic      [31:0] tb_reg_61,
    output logic      [31:0] tb_reg_62,
    output logic      [31:0] tb_reg_63,   
    output logic      [31:0] tb_reg_64,
    output logic      [31:0] tb_reg_65,
    output logic      [31:0] tb_reg_66,
    output logic      [31:0] tb_reg_67,
    output logic      [31:0] tb_reg_68,
    output logic      [31:0] tb_reg_69,
    output logic      [31:0] tb_reg_70,
    output logic      [31:0] tb_reg_71,
    output logic      [31:0] tb_reg_72,
    output logic      [31:0] tb_reg_73,
    output logic      [31:0] tb_reg_74,
    output logic      [31:0] tb_reg_75,
    output logic      [31:0] tb_reg_76,
    output logic      [31:0] tb_reg_77,
    output logic      [31:0] tb_reg_78,
    output logic      [31:0] tb_reg_79,
    output logic      [31:0] tb_reg_80,
    output logic      [31:0] tb_reg_81,
    output logic      [31:0] tb_reg_82,
    output logic      [31:0] tb_reg_83,
    output logic      [31:0] tb_reg_84,
    output logic      [31:0] tb_reg_85,
    output logic      [31:0] tb_reg_86,
    output logic      [31:0] tb_reg_87,
    output logic      [31:0] tb_reg_88,
    output logic      [31:0] tb_reg_89,
    output logic      [31:0] tb_reg_90,
    output logic      [31:0] tb_reg_91,
    output logic      [31:0] tb_reg_92,
    output logic      [31:0] tb_reg_93,   
    output logic      [31:0] tb_reg_94,
    output logic      [31:0] tb_reg_95,
    output logic      [31:0] tb_reg_96,
    output logic      [31:0] tb_reg_97,
    output logic      [31:0] tb_reg_98,
    output logic      [31:0] tb_reg_99,
    output logic      [31:0] tb_reg_100,
    output logic      [31:0] tb_reg_101,
    output logic      [31:0] tb_reg_102,
    output logic      [31:0] tb_reg_103,
    output logic      [31:0] tb_reg_104,
    output logic      [31:0] tb_reg_105,
    output logic      [31:0] tb_reg_106,
    output logic      [31:0] tb_reg_107,
    output logic      [31:0] tb_reg_108,
    output logic      [31:0] tb_reg_109,
    output logic      [31:0] tb_reg_110,
    output logic      [31:0] tb_reg_111,
    output logic      [31:0] tb_reg_112,
    output logic      [31:0] tb_reg_113,
    output logic      [31:0] tb_reg_114,
    output logic      [31:0] tb_reg_115,
    output logic      [31:0] tb_reg_116,
    output logic      [31:0] tb_reg_117,
    output logic      [31:0] tb_reg_118,
    output logic      [31:0] tb_reg_119,
    output logic      [31:0] tb_reg_120,
    input logic       [1:0]  tb_stock_id,
    input logic              tb_test_count_reset_n,
    output logic      [31:0] tb_test_count,

    input logic             i_clk,
    input logic             i_reset_n, //LOGIC HIGH
    input logic             i_trade_type, // whether it is buy or sell // logic high = buy, logic low = sell.
    input logic [1:0]       i_stock_id,
    input logic [1:0]       i_order_type, 
    input logic [15:0]      i_quantity, 
    input logic [31:0]      i_price, 
    input logic [31:0]      i_order_id,
    input logic             i_data_valid, // FROM PARSER
    input logic [31:0]      i_execute_order_quantity,
    input logic [63:0]      i_curr_time,
    output logic [31:0]     o_best_bid,
    output logic [31:0]     o_best_ask,
    output logic            o_book_is_busy, // can only read from the book (from trading logic) when book is not busy
    output logic            o_execute_order,
    output logic [31:0]     o_quantity,
    output logic [63:0]     o_curr_time,
    output logic            o_trade_type,
    output logic            o_data_valid // data is valid when high
);
    // order book array. Each trade takes up 3 32 bit wide registers.
    logic [REG_WIDTH - 1 : 0] order_book_memory_bid [BOOK_DEPTH*NUM_STOCKS*3 - 1 : 0]; // order book has BOOK_DEPTH*NUM_STOCKS*3 - 1 number of 32 bit wide registers to hold orders
    logic [REG_WIDTH - 1 : 0] order_book_memory_ask [BOOK_DEPTH*NUM_STOCKS*3 - 1 : 0]; 

    logic [31:0] reg1;
    // internal cache logic - basically 12 (with our params) rows, 3 for each stock id, 1 order takes up 3 rows.
    logic [REG_WIDTH - 1 : 0] best_bid_cache [CACHE_DEPTH*NUM_STOCKS*3 - 1 : 0];
    logic [REG_WIDTH - 1 : 0] best_ask_cache [CACHE_DEPTH*NUM_STOCKS*3 - 1 : 0];
    // 4 stores to store prev curr prices for each stock
    logic [REG_WIDTH - 1 : 0] curr_bid_price_cache [BOOK_DEPTH*NUM_STOCKS - 1 : 0]; //to store the previous curr price on cancellation of order.
    logic [REG_WIDTH - 1 : 0] curr_ask_price_cache [BOOK_DEPTH*NUM_STOCKS - 1 : 0];

    // internal pointer logic, to keep track of where to write a new trade into - we will just keep this as an array, which we can index via the stock id
    localparam ADDR_WIDTH = $clog2(BOOK_DEPTH*NUM_STOCKS*3);
    logic [ADDR_WIDTH - 1 : 0] write_pointer_array_ask [NUM_STOCKS - 1: 0];
    logic [ADDR_WIDTH - 1 : 0] write_pointer_array_bid [NUM_STOCKS - 1: 0];
    logic [$clog2(BOOK_DEPTH) - 1 : 0] num_trades_ask [NUM_STOCKS - 1 : 0];
    logic [$clog2(BOOK_DEPTH) - 1 : 0] num_trades_bid [NUM_STOCKS - 1 : 0];

    // storing address for cancel order
    logic which_book;
    logic [ADDR_WIDTH-1:0] cancel_register;
    logic [ADDR_WIDTH-1:0] counter;

    // for cancel order 
    logic [$clog2(BOOK_DEPTH)-1:0] search_pointer;
    logic [REG_WIDTH - 1 : 0] temp_max_reg1;
    logic [REG_WIDTH - 1 : 0] temp_max_price;
    logic [REG_WIDTH - 1 : 0] temp_max_order_id; 
    logic [REG_WIDTH - 1 : 0] temp_min_reg1;
    logic [REG_WIDTH - 1 : 0] temp_min_price;
    logic [REG_WIDTH - 1 : 0] temp_min_order_id; 

    logic [31:0] test_index = 0;
    logic found;

    logic reg_execute_order = 0;

    logic [1:0] reg_order_type;

    typedef enum logic [$clog2(NUM_STOCKS) - 1: 0] { 
        ADD = 0, 
        CANCEL = 1, 
        EXECUTE = 2
    } order_t; // for clarity when using a case statement

    // state logic for order book FSM
    typedef enum logic [2:0] { 
        IDLE,               //0
        ADD_ORDER,          //1
        CANCEL_ORDER,       //2
        EXECUTE_ORDER,      //3
        SHIFT_BOOK,         //4
        UPDATE_CACHE,       //5
        FINISH              //6
    } state_t; 

    state_t curr_state, next_state;

    always_comb begin
        if(!i_trade_type) begin
            tb_reg_1 = order_book_memory_bid[0];
            tb_reg_2 = order_book_memory_bid[1];
            tb_reg_3 = order_book_memory_bid[2];
            tb_reg_4 = order_book_memory_bid[3];
            tb_reg_5 = order_book_memory_bid[4];
            tb_reg_6 = order_book_memory_bid[5];
            tb_reg_7 = order_book_memory_bid[6];
            tb_reg_8 = order_book_memory_bid[7];
            tb_reg_9 = order_book_memory_bid[8];
            tb_reg_10 = order_book_memory_bid[9];
            tb_reg_11 = order_book_memory_bid[10];
            tb_reg_12 = order_book_memory_bid[11];
            tb_reg_13 = order_book_memory_bid[12];
            tb_reg_14 = order_book_memory_bid[13];
            tb_reg_15 = order_book_memory_bid[14];
            tb_reg_16 = order_book_memory_bid[15];
            tb_reg_17 = order_book_memory_bid[16];
            tb_reg_18 = order_book_memory_bid[17];
            tb_reg_19 = order_book_memory_bid[18];
            tb_reg_20 = order_book_memory_bid[19];
            tb_reg_21 = order_book_memory_bid[20];
            tb_reg_22 = order_book_memory_bid[21];
            tb_reg_23 = order_book_memory_bid[22];
            tb_reg_24 = order_book_memory_bid[23];
            tb_reg_25 = order_book_memory_bid[24];
            tb_reg_26 = order_book_memory_bid[25];
            tb_reg_27 = order_book_memory_bid[26];
            tb_reg_28 = order_book_memory_bid[27];
            tb_reg_29 = order_book_memory_bid[28];
            tb_reg_30 = order_book_memory_bid[29];
            tb_reg_31 = order_book_memory_bid[30]; 
            tb_reg_32 = order_book_memory_bid[31]; 
            tb_reg_33 = order_book_memory_bid[32]; 
            tb_reg_34 = order_book_memory_bid[33]; 
            tb_reg_35 = order_book_memory_bid[34];
            tb_reg_36 = order_book_memory_bid[35];
            tb_reg_37 = order_book_memory_bid[36];
            tb_reg_38 = order_book_memory_bid[37];
            tb_reg_39 = order_book_memory_bid[38];
            tb_reg_40 = order_book_memory_bid[39];
            tb_reg_41 = order_book_memory_bid[40];
            tb_reg_42 = order_book_memory_bid[41];
            tb_reg_43 = order_book_memory_bid[42];
            tb_reg_44 = order_book_memory_bid[43];
            tb_reg_45 = order_book_memory_bid[44];
            tb_reg_46 = order_book_memory_bid[45];
            tb_reg_47 = order_book_memory_bid[46];
            tb_reg_48 = order_book_memory_bid[47];
            tb_reg_49 = order_book_memory_bid[48];
            tb_reg_50 = order_book_memory_bid[49];
            tb_reg_51 = order_book_memory_bid[50];
            tb_reg_52 = order_book_memory_bid[51];
            tb_reg_53 = order_book_memory_bid[52];
            tb_reg_54 = order_book_memory_bid[53];
            tb_reg_55 = order_book_memory_bid[54];
            tb_reg_56 = order_book_memory_bid[55];
            tb_reg_57 = order_book_memory_bid[56];
            tb_reg_58 = order_book_memory_bid[57];
            tb_reg_59 = order_book_memory_bid[58];
            tb_reg_60 = order_book_memory_bid[59];
            tb_reg_61 = order_book_memory_bid[60];
            tb_reg_62 = order_book_memory_bid[61];
            tb_reg_63 = order_book_memory_bid[62];
            tb_reg_64 = order_book_memory_bid[63];
            tb_reg_65 = order_book_memory_bid[64];
            tb_reg_66 = order_book_memory_bid[65];
            tb_reg_67 = order_book_memory_bid[66];
            tb_reg_68 = order_book_memory_bid[67];
            tb_reg_69 = order_book_memory_bid[68];
            tb_reg_70 = order_book_memory_bid[69];
            tb_reg_71 = order_book_memory_bid[70];
            tb_reg_72 = order_book_memory_bid[71];
            tb_reg_73 = order_book_memory_bid[72];
            tb_reg_74 = order_book_memory_bid[73];
            tb_reg_75 = order_book_memory_bid[74];
            tb_reg_76 = order_book_memory_bid[75];
            tb_reg_77 = order_book_memory_bid[76];
            tb_reg_78 = order_book_memory_bid[77];
            tb_reg_79 = order_book_memory_bid[78];
            tb_reg_80 = order_book_memory_bid[79];
            tb_reg_81 = order_book_memory_bid[80];
            tb_reg_82 = order_book_memory_bid[81];
            tb_reg_83 = order_book_memory_bid[82];
            tb_reg_84 = order_book_memory_bid[83];
            tb_reg_85 = order_book_memory_bid[84];
            tb_reg_86 = order_book_memory_bid[85];
            tb_reg_87 = order_book_memory_bid[86];
            tb_reg_88 = order_book_memory_bid[87];
            tb_reg_89 = order_book_memory_bid[88];
            tb_reg_90 = order_book_memory_bid[89];
            tb_reg_91 = order_book_memory_bid[90];
            tb_reg_92 = order_book_memory_bid[91];
            tb_reg_93 = order_book_memory_bid[92];
            tb_reg_94 = order_book_memory_bid[93];
            tb_reg_95 = order_book_memory_bid[94];
            tb_reg_96 = order_book_memory_bid[95];
            tb_reg_97 = order_book_memory_bid[96];
            tb_reg_98 = order_book_memory_bid[97];
            tb_reg_99 = order_book_memory_bid[98];
            tb_reg_100 = order_book_memory_bid[99];
            tb_reg_101 = order_book_memory_bid[100];
            tb_reg_102 = order_book_memory_bid[101];
            tb_reg_103 = order_book_memory_bid[102];
            tb_reg_104 = order_book_memory_bid[103];
            tb_reg_105 = order_book_memory_bid[104];
            tb_reg_106 = order_book_memory_bid[105];
            tb_reg_107 = order_book_memory_bid[106];
            tb_reg_108 = order_book_memory_bid[107];
            tb_reg_109 = order_book_memory_bid[108];
            tb_reg_110 = order_book_memory_bid[109];
            tb_reg_111 = order_book_memory_bid[110];
            tb_reg_112 = order_book_memory_bid[111];
            tb_reg_113 = order_book_memory_bid[112];
            tb_reg_114 = order_book_memory_bid[113];
            tb_reg_115 = order_book_memory_bid[114];
            tb_reg_116 = order_book_memory_bid[115];
            tb_reg_117 = order_book_memory_bid[116];
            tb_reg_118 = order_book_memory_bid[117];
            tb_reg_119 = order_book_memory_bid[118];
            tb_reg_120 = order_book_memory_bid[119];
        end
        else begin
            tb_reg_1 = order_book_memory_ask[0];
            tb_reg_2 = order_book_memory_ask[1];
            tb_reg_3 = order_book_memory_ask[2];
            tb_reg_4 = order_book_memory_ask[3];
            tb_reg_5 = order_book_memory_ask[4];
            tb_reg_6 = order_book_memory_ask[5];
            tb_reg_7 = order_book_memory_ask[6];
            tb_reg_8 = order_book_memory_ask[7];
            tb_reg_9 = order_book_memory_ask[8];
            tb_reg_10 = order_book_memory_ask[9];
            tb_reg_11 = order_book_memory_ask[10];
            tb_reg_12 = order_book_memory_ask[11];
            tb_reg_13 = order_book_memory_ask[12];
            tb_reg_14 = order_book_memory_ask[13];
            tb_reg_15 = order_book_memory_ask[14];
            tb_reg_16 = order_book_memory_ask[15];
            tb_reg_17 = order_book_memory_ask[16];
            tb_reg_18 = order_book_memory_ask[17];
            tb_reg_19 = order_book_memory_ask[18];
            tb_reg_20 = order_book_memory_ask[19];
            tb_reg_21 = order_book_memory_ask[20];
            tb_reg_22 = order_book_memory_ask[21];
            tb_reg_23 = order_book_memory_ask[22];
            tb_reg_24 = order_book_memory_ask[23];
            tb_reg_25 = order_book_memory_ask[24];
            tb_reg_26 = order_book_memory_ask[25];
            tb_reg_27 = order_book_memory_ask[26];
            tb_reg_28 = order_book_memory_ask[27];
            tb_reg_29 = order_book_memory_ask[28];
            tb_reg_30 = order_book_memory_ask[29];
            tb_reg_31 = order_book_memory_ask[30]; 
            tb_reg_32 = order_book_memory_ask[31]; 
            tb_reg_33 = order_book_memory_ask[32]; 
            tb_reg_34 = order_book_memory_ask[33]; 
            tb_reg_35 = order_book_memory_ask[34];
            tb_reg_36 = order_book_memory_ask[35];
            tb_reg_37 = order_book_memory_ask[36];
            tb_reg_38 = order_book_memory_ask[37];
            tb_reg_39 = order_book_memory_ask[38];
            tb_reg_40 = order_book_memory_ask[39];
            tb_reg_41 = order_book_memory_ask[40];
            tb_reg_42 = order_book_memory_ask[41];
            tb_reg_43 = order_book_memory_ask[42];
            tb_reg_44 = order_book_memory_ask[43];
            tb_reg_45 = order_book_memory_ask[44];
            tb_reg_46 = order_book_memory_ask[45];
            tb_reg_47 = order_book_memory_ask[46];
            tb_reg_48 = order_book_memory_ask[47];
            tb_reg_49 = order_book_memory_ask[48];
            tb_reg_50 = order_book_memory_ask[49];
            tb_reg_51 = order_book_memory_ask[50];
            tb_reg_52 = order_book_memory_ask[51];
            tb_reg_53 = order_book_memory_ask[52];
            tb_reg_54 = order_book_memory_ask[53];
            tb_reg_55 = order_book_memory_ask[54];
            tb_reg_56 = order_book_memory_ask[55];
            tb_reg_57 = order_book_memory_ask[56];
            tb_reg_58 = order_book_memory_ask[57];
            tb_reg_59 = order_book_memory_ask[58];
            tb_reg_60 = order_book_memory_ask[59];
            tb_reg_61 = order_book_memory_ask[60];
            tb_reg_62 = order_book_memory_ask[61];
            tb_reg_63 = order_book_memory_ask[62];
            tb_reg_64 = order_book_memory_ask[63];
            tb_reg_65 = order_book_memory_ask[64];
            tb_reg_66 = order_book_memory_ask[65];
            tb_reg_67 = order_book_memory_ask[66];
            tb_reg_68 = order_book_memory_ask[67];
            tb_reg_69 = order_book_memory_ask[68];
            tb_reg_70 = order_book_memory_ask[69];
            tb_reg_71 = order_book_memory_ask[70];
            tb_reg_72 = order_book_memory_ask[71];
            tb_reg_73 = order_book_memory_ask[72];
            tb_reg_74 = order_book_memory_ask[73];
            tb_reg_75 = order_book_memory_ask[74];
            tb_reg_76 = order_book_memory_ask[75];
            tb_reg_77 = order_book_memory_ask[76];
            tb_reg_78 = order_book_memory_ask[77];
            tb_reg_79 = order_book_memory_ask[78];
            tb_reg_80 = order_book_memory_ask[79];
            tb_reg_81 = order_book_memory_ask[80];
            tb_reg_82 = order_book_memory_ask[81];
            tb_reg_83 = order_book_memory_ask[82];
            tb_reg_84 = order_book_memory_ask[83];
            tb_reg_85 = order_book_memory_ask[84];
            tb_reg_86 = order_book_memory_ask[85];
            tb_reg_87 = order_book_memory_ask[86];
            tb_reg_88 = order_book_memory_ask[87];
            tb_reg_89 = order_book_memory_ask[88];
            tb_reg_90 = order_book_memory_ask[89];
            tb_reg_91 = order_book_memory_ask[90];
            tb_reg_92 = order_book_memory_ask[91];
            tb_reg_93 = order_book_memory_ask[92];
            tb_reg_94 = order_book_memory_ask[93];
            tb_reg_95 = order_book_memory_ask[94];
            tb_reg_96 = order_book_memory_ask[95];
            tb_reg_97 = order_book_memory_ask[96];
            tb_reg_98 = order_book_memory_ask[97];
            tb_reg_99 = order_book_memory_ask[98];
            tb_reg_100 = order_book_memory_ask[99];
            tb_reg_101 = order_book_memory_ask[100];
            tb_reg_102 = order_book_memory_ask[101];
            tb_reg_103 = order_book_memory_ask[102];
            tb_reg_104 = order_book_memory_ask[103];
            tb_reg_105 = order_book_memory_ask[104];
            tb_reg_106 = order_book_memory_ask[105];
            tb_reg_107 = order_book_memory_ask[106];
            tb_reg_108 = order_book_memory_ask[107];
            tb_reg_109 = order_book_memory_ask[108];
            tb_reg_110 = order_book_memory_ask[109];
            tb_reg_111 = order_book_memory_ask[110];
            tb_reg_112 = order_book_memory_ask[111];
            tb_reg_113 = order_book_memory_ask[112];
            tb_reg_114 = order_book_memory_ask[113];
            tb_reg_115 = order_book_memory_ask[114];
            tb_reg_116 = order_book_memory_ask[115];
            tb_reg_117 = order_book_memory_ask[116];
            tb_reg_118 = order_book_memory_ask[117];
            tb_reg_119 = order_book_memory_ask[118];
            tb_reg_120 = order_book_memory_ask[119];
        end
    end

    // more testing logic
    always_ff @(posedge i_clk) begin
        if(!tb_test_count_reset_n) tb_test_count <= 1;
        else begin 
            if(i_data_valid) tb_test_count <= tb_test_count + 1;
        end
    end


    always_comb begin 
        if(!i_trade_type) begin
            /* verilator lint_off WIDTH */
            write_pointer_array_bid[i_stock_id] = ((i_stock_id * BOOK_DEPTH) + ((num_trades_bid[i_stock_id])))*3;
            /* verilator lint_on WIDTH */
            write_pointer_array_ask[i_stock_id] = ((i_stock_id * BOOK_DEPTH) + ((num_trades_ask[i_stock_id])))*3 ;
        end
        else begin
            /* verilator lint_off WIDTH */
            write_pointer_array_ask[i_stock_id] = ((i_stock_id * BOOK_DEPTH) + ((num_trades_ask[i_stock_id])))*3 ;
            /* verilator lint_on WIDTH */
            write_pointer_array_bid[i_stock_id] = ((i_stock_id * BOOK_DEPTH) + ((num_trades_bid[i_stock_id])))*3;
        end
    end

    // reset logic 
    always_ff @(posedge i_clk) begin
        reg1 <= {12'b0, {i_stock_id}, {i_order_type}, {i_quantity}};
        if (!i_reset_n) begin
            temp_min_price <= 32'b11111111111111111111111111111111;
            for (int i = 0; i < BOOK_DEPTH*NUM_STOCKS*3; i++) begin
               order_book_memory_bid[i] <= 32'b0;
               order_book_memory_ask[i] <= 32'b0;
            end
            for(int j = 0; j < CACHE_DEPTH*NUM_STOCKS*3; j++) begin
                best_bid_cache[j] <= 32'b0;
                best_ask_cache[j] <= 32'b0;
            end
            for(int l = 0; l < CACHE_DEPTH*NUM_STOCKS; l++) begin
                curr_bid_price_cache[l] <= 32'b0;
                curr_ask_price_cache[l] <= 32'b0;
            end
            for(int k = 0; k < NUM_STOCKS; k++) begin
                // write_pointer_array_bid[k] <= 0;
                // write_pointer_array_ask[k] <= 0;
                num_trades_bid[k] <= 0;
                num_trades_ask[k] <= 0;
            end
            curr_state <= IDLE; 
        end
    end

     always_ff @(posedge i_clk) begin
        o_data_valid <= 0;
        // o_book_is_busy <= 0; 
        o_execute_order <= 0;
        // curr_state <= next_state;
        // curr_state <= curr_state;
        found <= 0;
        which_book <= 0;
        case(curr_state)
            IDLE: begin //0
                if(i_data_valid) begin
                    case (i_order_type)
                    ADD: begin
                        o_book_is_busy <= 1;
                        curr_state <= ADD_ORDER;
                        reg_order_type <= ADD;
                    end
                    CANCEL: begin
                        o_book_is_busy <= 1;
                        curr_state <= CANCEL_ORDER;
                        reg_order_type <= CANCEL;
                    end
                    EXECUTE: begin
                        o_book_is_busy <= 1;
                        curr_state <= EXECUTE_ORDER; 
                        reg_order_type <= EXECUTE;
                    end
                    default: begin
                        o_book_is_busy <= 0;
                        curr_state <= IDLE;   
                    end
                    endcase
                end
                else begin
                    o_book_is_busy <= 0;
                    curr_state <= IDLE;
                end 
            end
            ADD_ORDER: begin //1
                o_book_is_busy <= 1;
                if(!i_trade_type) begin
                    order_book_memory_bid[write_pointer_array_bid[i_stock_id]] <= reg1;
                    order_book_memory_bid[write_pointer_array_bid[i_stock_id] + 1] <= i_price;
                    order_book_memory_bid[write_pointer_array_bid[i_stock_id] + 2] <= i_order_id;
                    // for wrap around
                    num_trades_bid[i_stock_id] <= (num_trades_bid[i_stock_id] + 1) % BOOK_DEPTH;
                    curr_bid_price_cache[i_stock_id] <= i_price;
                    
                end else begin
                    order_book_memory_ask[write_pointer_array_ask[i_stock_id]] <= reg1;
                    order_book_memory_ask[write_pointer_array_ask[i_stock_id] + 1] <= i_price;
                    order_book_memory_ask[write_pointer_array_ask[i_stock_id] + 2] <= i_order_id;

                    num_trades_ask[i_stock_id] <= (num_trades_ask[i_stock_id] + 1) % BOOK_DEPTH;
                    curr_ask_price_cache[i_stock_id] <= i_price;
                    
                end
                
                curr_state <= UPDATE_CACHE;

            end
            CANCEL_ORDER: begin //2
                o_book_is_busy <= 1;
                // test_index <= i_stock_id;
                if (order_book_memory_bid[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer) + 2] == i_order_id) begin
                    /* verilator lint_off WIDTH */
                    cancel_register <= (i_stock_id * BOOK_DEPTH) + ((search_pointer));
                    /* verilator lint_on WIDTH */
                    which_book <= 0;
                    curr_state <= SHIFT_BOOK;
                    search_pointer <= 0;
                    num_trades_bid[i_stock_id] <= (num_trades_bid[i_stock_id] == 0) ? (BOOK_DEPTH - 1) : (num_trades_bid[i_stock_id] - 1);
                end
                if (order_book_memory_ask[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer) + 2] == i_order_id) begin

                    /* verilator lint_off WIDTH */
                    cancel_register <= (i_stock_id * BOOK_DEPTH) + ((search_pointer));
                    /* verilator lint_on WIDTH */
                    which_book <= 1;
                    curr_state <= SHIFT_BOOK;
                    search_pointer <= 0;
                    num_trades_ask[i_stock_id] <= (num_trades_ask[i_stock_id] == 0) ? (BOOK_DEPTH - 1) : (num_trades_ask[i_stock_id] - 1);
                end
                search_pointer <= search_pointer + 1;

                // Not found means that we looked through all the orders but can't cancel, check if this is in the cache, if its the cached order, then we want to cancel it, if it isn't then we are attempting to cancel an "expired" order, in which case, do nothing?
                if (search_pointer == BOOK_DEPTH - 1) begin
                    if(best_bid_cache[(3*(i_stock_id*CACHE_DEPTH))+2] == i_order_id) begin
                        // execute has cancelled this order from the order book, but we have still kept it in cache, so now we need to find next best
                        found <= 1;
                        curr_state <= UPDATE_CACHE; 
                        search_pointer <= 0;
                    end 
                    else if (best_ask_cache[(3*(i_stock_id*CACHE_DEPTH))+2] == i_order_id) begin
                        curr_state <= UPDATE_CACHE; 
                        search_pointer <= 0;
                    end
                    else begin
                        // trying to cancel expired order, do nothing
                        curr_state <= FINISH;
                    end
                end

                
            end 
            EXECUTE_ORDER: begin //3
                o_book_is_busy <= 1;
                test_index <= (3*i_stock_id * BOOK_DEPTH) + (3*search_pointer) + 2;
                if (order_book_memory_bid[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer) + 2] == i_order_id) begin
                    order_book_memory_bid[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer)] <= order_book_memory_bid[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer)] - i_quantity;                    
                    if(order_book_memory_bid[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer)][15:0] == i_quantity) begin
                        which_book <= 0;
                        /* verilator lint_off WIDTH */
                        cancel_register <= (i_stock_id * BOOK_DEPTH) + search_pointer;
                        /* verilator lint_on WIDTH */
                        curr_state <= SHIFT_BOOK;
                        num_trades_bid[i_stock_id] <= (num_trades_bid[i_stock_id] == 0) ? (BOOK_DEPTH - 1) : (num_trades_bid[i_stock_id] - 1);
                    end 
                    else begin
                        curr_state <= UPDATE_CACHE;
                    end

                end
                if (order_book_memory_ask[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer) + 2] == i_order_id) begin
                    order_book_memory_ask[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer)] <= order_book_memory_ask[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer)] - i_quantity;
                    if(order_book_memory_ask[(i_stock_id * BOOK_DEPTH) + (3*search_pointer)][15:0] == i_quantity) begin
                        which_book <= 1;
                        /* verilator lint_off WIDTH */
                        cancel_register <= (i_stock_id * BOOK_DEPTH) + search_pointer;
                        /* verilator lint_on WIDTH */
                        curr_state <= SHIFT_BOOK;
                        num_trades_ask[i_stock_id] <= (num_trades_ask[i_stock_id] == 0) ? (BOOK_DEPTH - 1) : (num_trades_ask[i_stock_id] - 1);
                    end
                    else begin
                        curr_state <= UPDATE_CACHE;
                    end
                end

                search_pointer <= search_pointer + 1;

                if (i_order_id[31] == 0) begin
                    reg_execute_order <= 1;
                end
                else begin
                    reg_execute_order <= 0;
                end

                if (search_pointer == BOOK_DEPTH - 1) begin
                    curr_state <= UPDATE_CACHE;
                end

            end
            SHIFT_BOOK: begin //4
                o_book_is_busy <= 1;
                if(~which_book) begin
                    if ((cancel_register-(i_stock_id*BOOK_DEPTH)) < BOOK_DEPTH-1) begin // counter = cancelled trade number 
                        order_book_memory_bid[3*cancel_register] <= order_book_memory_bid[(3*cancel_register)+3];
                        order_book_memory_bid[(3*cancel_register)+1] <= order_book_memory_bid[(3*cancel_register)+4];
                        order_book_memory_bid[(3*cancel_register)+2] <= order_book_memory_bid[(3*cancel_register)+5];
                        if((cancel_register-(i_stock_id*BOOK_DEPTH)) ==  (BOOK_DEPTH - 2)) begin
                            order_book_memory_bid[3*i_stock_id*BOOK_DEPTH+((3*BOOK_DEPTH)-1)] <= 0;
                            order_book_memory_bid[3*i_stock_id*BOOK_DEPTH+((3*BOOK_DEPTH)-1)-2] <= 0;
                            order_book_memory_bid[3*i_stock_id*BOOK_DEPTH+((3*BOOK_DEPTH)-1)-1] <= 0;
                            
                        end
                        cancel_register <= cancel_register + 1;
                        which_book <= which_book;
                        curr_state <= SHIFT_BOOK;
                    end
                    else begin
                        curr_state <= UPDATE_CACHE;
                    end
                end
                else begin
                    if ((cancel_register-(i_stock_id*BOOK_DEPTH)) < BOOK_DEPTH-1) begin // counter = cancelled trade number 
                        order_book_memory_ask[3*cancel_register] <= order_book_memory_ask[(3*cancel_register)+3];
                        order_book_memory_ask[(3*cancel_register)+1] <= order_book_memory_ask[(3*cancel_register)+4];
                        order_book_memory_ask[(3*cancel_register)+2] <= order_book_memory_ask[(3*cancel_register)+5];
                        if((cancel_register-(i_stock_id*BOOK_DEPTH)) ==  (BOOK_DEPTH - 2)) begin
                            tmp <= 1;
                            order_book_memory_ask[3*i_stock_id*BOOK_DEPTH+((3*BOOK_DEPTH)-1)] <= 0;
                            order_book_memory_ask[3*i_stock_id*BOOK_DEPTH+((3*BOOK_DEPTH)-1)-2] <= 0;
                            order_book_memory_ask[3*i_stock_id*BOOK_DEPTH+((3*BOOK_DEPTH)-1)-1] <= 0;
                        end
                        cancel_register <= cancel_register + 1;
                        which_book <= which_book;
                        curr_state <= SHIFT_BOOK;
                    end
                    else begin
                        curr_state <= UPDATE_CACHE;
                    end
                end

                search_pointer <= 0;
            end
            UPDATE_CACHE: begin //5
                o_book_is_busy <= 1;
                case (reg_order_type)
                ADD: begin
                    if(!i_trade_type) begin // 0 = buy, 1 = sell
                        if(i_price >= best_bid_cache[(i_stock_id*3)+1]) begin
                            best_bid_cache[(i_stock_id*3)] <= reg1;
                            best_bid_cache[(i_stock_id*3)+1] <= i_price;
                            best_bid_cache[(i_stock_id*3)+2] <= i_order_id;
                            
                        end
                    end else begin
                        if((i_price <= best_ask_cache[(i_stock_id*3)+1]) || (best_ask_cache[(i_stock_id*3)+1] == 0)) begin
                            best_ask_cache[(i_stock_id*3)] <= reg1;
                            best_ask_cache[(i_stock_id*3)+1] <= i_price;
                            best_ask_cache[(i_stock_id*3)+2] <= i_order_id;
                        end
                    end
                   
                    // o_data_valid <= 1;
                    curr_state <= FINISH;
                    o_book_is_busy <= 0;
                end
                CANCEL: begin

                    if(!i_trade_type && (i_order_id == best_bid_cache[(i_stock_id*3) + 2])) begin 
                        // valid delete - update bid cache
                        if (order_book_memory_bid[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer) + 1] > temp_max_price) begin
                            temp_max_reg1 <= order_book_memory_bid[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer)];
                            temp_max_price <= order_book_memory_bid[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer) + 1];
                            temp_max_order_id <= order_book_memory_bid[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer) + 2];
                            curr_state <= UPDATE_CACHE; 
                        end
                        search_pointer <= search_pointer + 1;
                        if (search_pointer == BOOK_DEPTH - 1)  begin
                            // searched through all of them
                            best_bid_cache[(i_stock_id*3)] <= temp_max_reg1;
                            best_bid_cache[(i_stock_id*3)+1] <= temp_max_price;
                            best_bid_cache[(i_stock_id*3)+2] <= temp_max_order_id;
                            curr_state <= FINISH;
                        end
                    end 
                    // ask
                    else if ((i_trade_type && (i_order_id == best_ask_cache[(i_stock_id*3) + 2]))) begin
                        test_index <= (i_stock_id * BOOK_DEPTH) + (3*search_pointer);
                        if ((order_book_memory_ask[3*((i_stock_id * BOOK_DEPTH) + (3*search_pointer)) + 1] <= temp_min_price) && (order_book_memory_ask[3*((i_stock_id * BOOK_DEPTH) + (3*search_pointer)) + 1] != 0))begin
                            found <= 1;
                            temp_min_reg1 <= order_book_memory_ask[3*((i_stock_id * BOOK_DEPTH) + (3*search_pointer))];
                            temp_min_price <= order_book_memory_ask[3*((i_stock_id * BOOK_DEPTH) + (3*search_pointer)) + 1];
                            temp_min_order_id <= order_book_memory_ask[3*((i_stock_id * BOOK_DEPTH) + (3*search_pointer)) + 2];
                            curr_state <= UPDATE_CACHE;
                        end
                        search_pointer <= search_pointer + 1;
                        if (search_pointer == BOOK_DEPTH - 1)  begin
                            // searched through all of them
                            best_ask_cache[(i_stock_id*3)] <= temp_min_reg1;
                            best_ask_cache[(i_stock_id*3)+1] <= temp_min_price;
                            best_ask_cache[(i_stock_id*3)+2] <= temp_min_order_id;
                            curr_state <= FINISH;

                        end
                    end
                    else begin
                        // cancelled order is not the one in cache
                        curr_state <= FINISH;
                    end
                    
                end
                EXECUTE: 
                    if(!i_trade_type && (i_order_id == best_bid_cache[(i_stock_id*3) + 2])) begin 
                        if  (best_bid_cache[(i_stock_id*3)][15:0] - i_quantity == 0) begin
                            curr_state <= UPDATE_CACHE;
                            reg_order_type <= CANCEL;
                        end 
                        else begin
                            curr_state <= FINISH;
                        end
                    end 
                    // ask
                    else if ((i_trade_type && (i_order_id == best_ask_cache[(i_stock_id*3) + 2]))) begin
                        if  (best_ask_cache[(i_stock_id*3)][15:0] - i_quantity == 0) begin
                            curr_state <= UPDATE_CACHE;
                            reg_order_type <= CANCEL;
                        end 
                        else begin
                            curr_state <= FINISH;
                        end
                    end
                    else begin
                        // cancelled order is not the one in cache
                        curr_state <= FINISH;
                    end
                default: ;
                endcase
                

            end
            FINISH: begin
                o_data_valid <= 1;
                o_book_is_busy <= 0;
                // curr_state <= i_trading_logic_ready ? IDLE : FINISH;
                curr_state <= IDLE;
                search_pointer <= 0;
                temp_max_price <= 0;
                temp_min_price <= 32'b11111111111111111111111111111111;
                temp_max_order_id <= 0;
                temp_min_order_id <= 0;
                temp_max_reg1 <= 0; 
                temp_min_reg1 <= 0;
                o_execute_order <= reg_execute_order ? 1 : 0;
                reg_execute_order <= 0;
                o_curr_time <= i_curr_time;
                o_trade_type <= i_order_id[30];
                o_best_bid <= best_bid_cache[(i_stock_id*3)+1];
                o_best_ask <= best_ask_cache[(i_stock_id*3)+1];
                o_quantity <= i_execute_order_quantity;
            end 
            // default: next_state <= curr_state; 
        endcase
     end

    logic [31:0] tmp;

    always_comb begin 
        // tmp = order_book_memory_bid[(3*i_stock_id * BOOK_DEPTH) + (3*search_pointer)][15:0];
    end
    always_ff @(posedge i_clk) begin
        // o_best_bid <= best_bid_cache[(i_stock_id*3)+1];
        // o_best_ask <= best_ask_cache[(i_stock_id*3)+1];
        // o_quantity <= i_execute_order_quantity;
    end 

endmodule
