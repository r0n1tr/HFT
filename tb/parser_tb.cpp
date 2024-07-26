#include "Vparser.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <iostream>

#define NUM_TESTS 6

bool check_add_results(bool a, bool b, bool c, bool d, bool e, bool f)
{
    return (a & b & c & d & e & f);
}

bool check_cancel_results(bool a, bool b)
{
    return (a & b);
}

bool check_execute_results(bool a, bool b, bool c)
{
    return (a & b & c);
}

int main(int argc, char **argv, char **env)
{
    int i; // number of clock cycles to simulate
    int clk; // module clock signal

    Verilated::commandArgs(argc, argv);

    // top level instance
    Vparser* top = new Vparser;

    // trace dump initialisation - signal tracing turned on, tell verilator when to dump the waveform to parser.vcd
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open ("parser.vcd");

    // simualtion inputs
    top->i_clk = 1;

    bool o_stock_symbol_check;
    bool o_order_id_check;
    bool o_price_check;
    bool o_quantity_check;
    bool o_order_type_check;
    bool o_trade_type_check;

    const std::string green("\033[32m");
    const std::string reset("\033[0m");
    const std::string red("\033[31m");
    const std::string bold("\033[1m");

    int pass_count = 0;
    int fail_count = 0;
    int test_count = 0;

    for (i = 0; i < 300; i++)
    {
        for(clk = 0; clk < 2; clk++)
        {
            tfp->dump (2*i+clk);
            top->i_clk = !top->i_clk;
            top->eval();
        }
        switch (i)
        {
            case(10): // ADD order 1
                top->i_reg_1 = 0x41c35675;
                top->i_reg_2 = 0x554943cc;
                top->i_reg_3 = 0x3f010000;
                top->i_reg_4 = 0x039c474f;
                top->i_reg_5 = 0x4f474c20;
                top->i_reg_6 = 0x20200010;
                top->i_reg_7 = 0x12d80000;
                break;
            case(11): // ADD order 1 verify
                o_stock_symbol_check = (top->o_stock_symbol == 2);
                o_order_id_check = (top->o_order_id == 1229179967);
                o_price_check = (top->o_price == 1053400);
                o_quantity_check = (top->o_quantity == 924);
                o_order_type_check = (top->o_order_type == 0);
                o_trade_type_check = (top->o_trade_type == 0);
                if(check_add_results(o_stock_symbol_check, o_order_id_check, o_price_check, o_quantity_check, o_order_type_check, o_trade_type_check))
                {
                    std::cout << green << "ADD order test 1 passed" << reset << std::endl;
                    pass_count++;
                }
                else 
                {
                    std::cout << red << "ADD order test 1 failed" << reset << std::endl;
                    fail_count++;
                }
                test_count++;
                break;
            case(15): // ADD order 2 
                top->i_reg_1 = 0x41c3599e;
                top->i_reg_2 = 0xcfe6d557;
                top->i_reg_3 = 0x25000000;
                top->i_reg_4 = 0x011e4141;
                top->i_reg_5 = 0x504c2020;
                top->i_reg_6 = 0x202000c8;
                top->i_reg_7 = 0x5aa00000;
                break;
            case(16): // ADD order 2 verify
                o_stock_symbol_check = (top->o_stock_symbol == 0);
                o_order_id_check = (top->o_order_id == 3872741157);
                o_price_check = (top->o_price == 13130400);
                o_quantity_check = (top->o_quantity == 286);
                o_order_type_check = (top->o_order_type == 0);
                o_trade_type_check = (top->o_trade_type == 1);
                if(check_add_results(o_stock_symbol_check, o_order_id_check, o_price_check, o_quantity_check, o_order_type_check, o_trade_type_check))
                {
                    std::cout << green << "ADD order test 2 passed" << reset << std::endl;
                    pass_count++;
                }
                else 
                {
                    std::cout << red << "ADD order test 2 failed" << reset << std::endl;
                    fail_count++;
                }
                test_count++;
                break;
            case(20): // ADD order 3
                top->i_reg_1 = 0x41c35bf4;
                top->i_reg_2 = 0x2fcfd050;
                top->i_reg_3 = 0x25000000;
                top->i_reg_4 = 0x011a414d;
                top->i_reg_5 = 0x5a4e2020;
                top->i_reg_6 = 0x20200063;
                top->i_reg_7 = 0x75530000;
                break;
            case(21): // ADD order 3 verify
                o_stock_symbol_check = (top->o_stock_symbol == 1);
                o_order_id_check = (top->o_order_id == 3486535717);
                o_price_check = (top->o_price == 6518099);
                o_quantity_check = (top->o_quantity == 282);
                o_order_type_check = (top->o_order_type == 0);
                o_trade_type_check = (top->o_trade_type == 1);
                if(check_add_results(o_stock_symbol_check, o_order_id_check, o_price_check, o_quantity_check, o_order_type_check, o_trade_type_check))
                {
                    std::cout << green << "ADD order test 3 passed" << reset << std::endl;
                    pass_count++;
                }
                else 
                {
                    std::cout << red << "ADD order test 3 failed" << reset << std::endl;
                    fail_count++;
                }
                test_count++;
                break;
            case(25): // ADD order 4
                top->i_reg_1 = 0x41c36a4f;
                top->i_reg_2 = 0xfac8d0b2;
                top->i_reg_3 = 0xe6010000;
                top->i_reg_4 = 0x03824d53;
                top->i_reg_5 = 0x46542020;
                top->i_reg_6 = 0x20200069;
                top->i_reg_7 = 0x47900000;
                break;
            case(26): // ADD order 4 verify
                o_stock_symbol_check = (top->o_stock_symbol == 3);
                o_order_id_check = (top->o_order_id == 3369120486);
                o_price_check = (top->o_price == 6899600);
                o_quantity_check = (top->o_quantity == 898);
                o_order_type_check = (top->o_order_type == 0);
                o_trade_type_check = (top->o_trade_type == 0);
                if(check_add_results(o_stock_symbol_check, o_order_id_check, o_price_check, o_quantity_check, o_order_type_check, o_trade_type_check))
                {
                    std::cout << green << "ADD order test 4 passed" << reset << std::endl;
                    pass_count++;
                }
                else 
                {
                    std::cout << red << "ADD order test 4 failed" << reset << std::endl;
                    fail_count++;
                }
                test_count++;
                break;
            case(30): // CANCEL order
                top->i_reg_1 = 0x58c35894;
                top->i_reg_2 = 0x294943cc;
                top->i_reg_3 = 0x3f000000;
                top->i_reg_4 = 0x00000000;
                top->i_reg_5 = 0x00000000;
                top->i_reg_6 = 0x00000000;
                top->i_reg_7 = 0x00000000;
                break;
            case(31): // CANCEL order verify
                o_order_id_check = (top->o_order_id == 1229179967);
                o_order_type_check = (top->o_order_type == 1);
                if(check_cancel_results(o_order_id_check, o_order_type_check))
                {
                    std::cout << green << "CANCEL order test passed" << reset << std::endl;
                    pass_count++;
                }
                else 
                {
                    std::cout << red << "CANCEL order test failed" << reset << std::endl;
                    fail_count++;
                }
                test_count++;
                break;
            case(35): // EXECUTE order
                top->i_reg_1 = 0x45c359e6;
                top->i_reg_2 = 0x96fa3bfc;
                top->i_reg_3 = 0x1a000000;
                top->i_reg_4 = 0x59000000;
                top->i_reg_5 = 0x00000000;
                top->i_reg_6 = 0x00000000;
                top->i_reg_7 = 0x00000000;
                break;
            case(36): // EXECUTE order verify
                o_order_id_check = (top->o_order_id == 4198235162);
                o_quantity_check = (top->o_quantity == 89);
                o_order_type_check = (top->o_order_type == 2);
                if(check_execute_results(o_order_id_check, o_quantity_check, o_order_type_check))
                {
                    std::cout << green << "EXECUTE order test passed" << reset << std::endl;
                    pass_count++;
                }
                else 
                {
                    std::cout << red << "EXECUTE order test failed" << reset << std::endl;
                    fail_count++;
                }
                test_count++;
                break;        
            }
        
        if(test_count == NUM_TESTS)
        {
            if(pass_count == NUM_TESTS)
            {
                std::cout << bold << green << "All " << NUM_TESTS << " test cases passed" << reset << std::endl;
            }
            else
            {
                std::cout << bold << red << fail_count << " tests out of " << NUM_TESTS << " failed" << std::endl;
            }
            break;
        }

    }
    tfp->close();
    exit(0);
}