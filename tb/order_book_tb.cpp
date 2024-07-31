#include "TestCase.h"
#include "Vorder_book.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <iostream>
#include <vector>
#include <string>
#include <fstream>
#include <sstream>

#define BOLD    "\033[1m"
#define GREEN   "\033[32m"
#define RED     "\033[31m"
#define RESET   "\033[0m"
#define NUM_TEST_CASES 157


std::vector<TestCase> readCSV(const std::string& filename)
{
    std::vector<TestCase> testCases;
    std::ifstream file(filename);
    std::string line;
    while (std::getline(file, line)) {
        std::stringstream ss(line);
        std::string cell;
        TestCase testCase;

        std::getline(ss, cell, ',');
        testCase.name = cell;

        for (int i = 0; i < 7; ++i) {
            std::getline(ss, cell, ',');
            testCase.inputs.push_back(std::stoi(cell));
        }


        for (int i = 0; i < 120; ++i) {
            std::getline(ss, cell, ',');
            testCase.expectedOrderBook.push_back(std::stoi(cell));
        }

        for (int i = 0; i < 5; ++i) {
            std::getline(ss, cell, ',');
            testCase.expectedOutputs.push_back(std::stoi(cell));
        }

        testCases.push_back(testCase);
    }
    return testCases;
}

bool verifyOrderBook(Vorder_book* top, const std::vector<int>& expected_outputs, const std::string& test_name)
{
    // total of 30 outputs for each register on one side of one stock's order book
    std::vector<int> received_outputs;
    received_outputs.push_back(top->tb_reg_1);
    received_outputs.push_back(top->tb_reg_2);
    received_outputs.push_back(top->tb_reg_3);
    received_outputs.push_back(top->tb_reg_4);
    received_outputs.push_back(top->tb_reg_5);
    received_outputs.push_back(top->tb_reg_6);
    received_outputs.push_back(top->tb_reg_7);
    received_outputs.push_back(top->tb_reg_8);
    received_outputs.push_back(top->tb_reg_9);
    received_outputs.push_back(top->tb_reg_10);
    received_outputs.push_back(top->tb_reg_11);
    received_outputs.push_back(top->tb_reg_12);
    received_outputs.push_back(top->tb_reg_13);
    received_outputs.push_back(top->tb_reg_14);
    received_outputs.push_back(top->tb_reg_15);
    received_outputs.push_back(top->tb_reg_16);
    received_outputs.push_back(top->tb_reg_17);
    received_outputs.push_back(top->tb_reg_18);
    received_outputs.push_back(top->tb_reg_19);
    received_outputs.push_back(top->tb_reg_20);
    received_outputs.push_back(top->tb_reg_21);
    received_outputs.push_back(top->tb_reg_22);
    received_outputs.push_back(top->tb_reg_23);
    received_outputs.push_back(top->tb_reg_24);
    received_outputs.push_back(top->tb_reg_25);
    received_outputs.push_back(top->tb_reg_26);
    received_outputs.push_back(top->tb_reg_27);
    received_outputs.push_back(top->tb_reg_28);
    received_outputs.push_back(top->tb_reg_29);
    received_outputs.push_back(top->tb_reg_30);
    received_outputs.push_back(top->tb_reg_31);
    received_outputs.push_back(top->tb_reg_32);
    received_outputs.push_back(top->tb_reg_33);
    received_outputs.push_back(top->tb_reg_34);
    received_outputs.push_back(top->tb_reg_35);
    received_outputs.push_back(top->tb_reg_36);
    received_outputs.push_back(top->tb_reg_37);
    received_outputs.push_back(top->tb_reg_38);
    received_outputs.push_back(top->tb_reg_39);
    received_outputs.push_back(top->tb_reg_40);
    received_outputs.push_back(top->tb_reg_41);
    received_outputs.push_back(top->tb_reg_42);
    received_outputs.push_back(top->tb_reg_43);
    received_outputs.push_back(top->tb_reg_44);
    received_outputs.push_back(top->tb_reg_45);
    received_outputs.push_back(top->tb_reg_46);
    received_outputs.push_back(top->tb_reg_47);
    received_outputs.push_back(top->tb_reg_48);
    received_outputs.push_back(top->tb_reg_49);
    received_outputs.push_back(top->tb_reg_50);
    received_outputs.push_back(top->tb_reg_51);
    received_outputs.push_back(top->tb_reg_52);
    received_outputs.push_back(top->tb_reg_53);
    received_outputs.push_back(top->tb_reg_54);
    received_outputs.push_back(top->tb_reg_55);
    received_outputs.push_back(top->tb_reg_56);
    received_outputs.push_back(top->tb_reg_57);
    received_outputs.push_back(top->tb_reg_58);
    received_outputs.push_back(top->tb_reg_59);
    received_outputs.push_back(top->tb_reg_60);
    received_outputs.push_back(top->tb_reg_61);
    received_outputs.push_back(top->tb_reg_62);
    received_outputs.push_back(top->tb_reg_63);
    received_outputs.push_back(top->tb_reg_64);
    received_outputs.push_back(top->tb_reg_65);
    received_outputs.push_back(top->tb_reg_66);
    received_outputs.push_back(top->tb_reg_67);
    received_outputs.push_back(top->tb_reg_68);
    received_outputs.push_back(top->tb_reg_69);
    received_outputs.push_back(top->tb_reg_70);
    received_outputs.push_back(top->tb_reg_71);
    received_outputs.push_back(top->tb_reg_72);
    received_outputs.push_back(top->tb_reg_73);
    received_outputs.push_back(top->tb_reg_74);
    received_outputs.push_back(top->tb_reg_75);
    received_outputs.push_back(top->tb_reg_76);
    received_outputs.push_back(top->tb_reg_77);
    received_outputs.push_back(top->tb_reg_78);
    received_outputs.push_back(top->tb_reg_79);
    received_outputs.push_back(top->tb_reg_80);
    received_outputs.push_back(top->tb_reg_81);
    received_outputs.push_back(top->tb_reg_82);
    received_outputs.push_back(top->tb_reg_83);
    received_outputs.push_back(top->tb_reg_84);
    received_outputs.push_back(top->tb_reg_85);
    received_outputs.push_back(top->tb_reg_86);
    received_outputs.push_back(top->tb_reg_87);
    received_outputs.push_back(top->tb_reg_88);
    received_outputs.push_back(top->tb_reg_89);
    received_outputs.push_back(top->tb_reg_90);
    received_outputs.push_back(top->tb_reg_91);
    received_outputs.push_back(top->tb_reg_92);
    received_outputs.push_back(top->tb_reg_93);
    received_outputs.push_back(top->tb_reg_94);
    received_outputs.push_back(top->tb_reg_95);
    received_outputs.push_back(top->tb_reg_96);
    received_outputs.push_back(top->tb_reg_97);
    received_outputs.push_back(top->tb_reg_98);
    received_outputs.push_back(top->tb_reg_99);
    received_outputs.push_back(top->tb_reg_100);
    received_outputs.push_back(top->tb_reg_101);
    received_outputs.push_back(top->tb_reg_102);
    received_outputs.push_back(top->tb_reg_103);
    received_outputs.push_back(top->tb_reg_104);
    received_outputs.push_back(top->tb_reg_105);
    received_outputs.push_back(top->tb_reg_106);
    received_outputs.push_back(top->tb_reg_107);
    received_outputs.push_back(top->tb_reg_108);
    received_outputs.push_back(top->tb_reg_109);
    received_outputs.push_back(top->tb_reg_110);
    received_outputs.push_back(top->tb_reg_111);
    received_outputs.push_back(top->tb_reg_112);
    received_outputs.push_back(top->tb_reg_113);
    received_outputs.push_back(top->tb_reg_114);
    received_outputs.push_back(top->tb_reg_115);
    received_outputs.push_back(top->tb_reg_116);
    received_outputs.push_back(top->tb_reg_117);
    received_outputs.push_back(top->tb_reg_118);
    received_outputs.push_back(top->tb_reg_119);
    received_outputs.push_back(top->tb_reg_120);

    int order_book_no = 0;
    for (int i = 0; i < expected_outputs.size(); i++)
    {
        if (received_outputs[i] != expected_outputs[i])
        {
            if (i < 30)
            {
                order_book_no = 0;
            }
            else if ((i > 29) && (i < 60))
            {
                order_book_no = 1; 
            }
            else if ((i > 59) && (i < 90))
            {
                order_book_no = 2;
            }
            else
            {
                order_book_no = 3;
            }

            int trade_number = (i - (order_book_no*30))/3 + 1;

            if (i%3 == 0)
            {
                std::cout << BOLD << RED << test_name << ": Register 1 (stock_id, order_type, quantity) incorrect. Expected: " << expected_outputs[i] << ", got: " << received_outputs[i] << ". Issue in order book: " << order_book_no  << ", Trade Slot: " << trade_number  << " of 10"<< RESET << std::endl;
                return false;
            }
            else if (i%3 == 1)
            {
                std::cout << BOLD << RED << test_name << ": Register 2 (price) incorrect. Expected: " << expected_outputs[i] << ", got: " << received_outputs[i] << ". Issue in order book: " << order_book_no << ", Trade Slot: " << trade_number  << " of 10" << RESET << std::endl;
                return false;
            }
            else
            {
                std::cout << BOLD << RED << test_name << ": Register 3 (order_id) incorrect Expected: " << expected_outputs[i] << ", got: " << received_outputs[i] << ". Issue in order book: " << order_book_no << ", Trade Slot: " << trade_number  << " of 10" << RESET << std::endl;
                return false;
            }
        }
    }
    return true;

}

bool verifyOutputs(Vorder_book* top, const std::vector<int>& expected_outputs, const std::string& test_name)
{
    std::vector<int> received_outputs;

    received_outputs.push_back(top->o_curr_price);
    received_outputs.push_back(top->o_best_bid); 
    received_outputs.push_back(top->o_best_ask);
    received_outputs.push_back(top->o_book_is_busy); 
    received_outputs.push_back(top->o_data_valid);

    for (int i = 0; i < received_outputs.size(); i++)
    {
        if(received_outputs[i] != expected_outputs[i])
        {
            switch (i)
            {
            case(0):
                std::cout << BOLD << RED << test_name << ": curr_price incorrect" << RESET << std::endl;
                break;
            case(1):
                std::cout << BOLD << RED << test_name << ": best_bid incorrect" << RESET << std::endl;
                break;
            case(2):
                std::cout << BOLD << RED << test_name << ": best_ask incorrect" << RESET << std::endl;
                break;
            case(3):
                std::cout << BOLD << RED << test_name << ": book_is_busy incorrect" << RESET << std::endl;
                break;
            case(4):
                std::cout << BOLD << RED << test_name << ": data_valid incorrect" << RESET << std::endl;
                break;
            }
            return false;
        }
    }

    return true; 
}

void initialiseInputs(Vorder_book* top, const std::vector<int>& inputs)
{
    // std::cout << "Inputs initialised" << std::endl;
    top->tb_test_count_reset_n = 1;
    top->i_reset_n = inputs[0];
    top->i_trade_type = inputs[1];
    top->i_stock_id = inputs[2];
    top->i_order_type = inputs[3];
    top->i_quantity = inputs[4];
    top->i_price = inputs[5];
    top->i_order_id = inputs[6];
}

int main(int argc, char **argv, char **env)
{
    int i; // number of clock cycles to simulate
    int clk; // module clock signal

    int test_count = 0;
    int pass_count = 0;

    std::string filename = "order_book_test_cases_new.csv";

    std::vector<TestCase> tests = readCSV(filename);

    Verilated::commandArgs(argc, argv);

    // top level instance
    Vorder_book* top = new Vorder_book;

    // trace dump initialisation - signal tracing turned on, tell verilator when to dump the waveform to order_book.vcd
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open ("order_book.vcd");

    // simualtion inputs
    top->i_clk = 1;

    
    
    // Close the file

    
    for (int i = 0; i < 7000; i++) {
        for (int clk = 0; clk < 2; clk++) {
            tfp->dump(2 * i + clk);
            top->i_clk = !top->i_clk;
            top->eval();
        }
    
        if ((i % 40 == 0) && (i != 0)) {
            initialiseInputs(top, tests[test_count].inputs);
            top->i_data_valid = 1;
        }

        else if (((i-30)%40 == 0) && (i != 30)) {
            top->i_trading_logic_ready = 1;
            if (verifyOrderBook(top, tests[test_count].expectedOrderBook, tests[test_count].name) && verifyOutputs(top, tests[test_count].expectedOutputs, tests[test_count].name)) {
                std::cout << GREEN << tests[test_count].name << ": passed" << RESET << std::endl;
                pass_count++;
            } else {
                // std::cout << RED << tests[test_count].name << ": failed" << RESET << std::endl;
                ;
            }

            test_count++;
            if (test_count == tests.size()) {
                // std::cout << i << std::endl;
                break;
            }
        }
        else
        {
            top->i_trading_logic_ready = 0;
            top->i_data_valid = 0;
        }

        
    }

    if (pass_count != tests.size()) {
        std::cout << BOLD << RED << "Only " << pass_count << " cases out of " << NUM_TEST_CASES << " passed" << RESET << std::endl;
    } else {
        std::cout << BOLD << GREEN << "All tests passed" << RESET << std::endl;
    }
        
    

    tfp->close();
    delete top;
    return 0;
}

