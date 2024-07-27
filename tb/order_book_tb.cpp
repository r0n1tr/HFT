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
#define NUM_TEST_CASES 200

void initialiseInputs(Vorder_book* top, const std::vector<int>& inputs)
{
    top->i_reset_n = ;
    top->i_trade_t = ;
    top->i_stock_id = ;
    top->i_order_type = ;
    top->i_quantity = ;
    top->i_price = ;
    top->i_order_id = ;
}

bool verifyOutputs(Vorder_book* top, const std::vector<int>& expected_outputs, const std::string& test_name)
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
    for (int i = 0; i < expected_outputs.size(); i++)
    {
        if (received_outputs[i] != expected_outputs[i])
        {
            if (i%3 == 0)
            {
                std::cout << BOLD << RED << test_name << ": Register 1 (stock_id, order_type, quantity) incorrect" << RESET << std::endl;
                return false;
            }
            else if (i%3 == 1)
            {
                std::cout << BOLD << RED << test_name << ": Register 2 (price) incorrect" << RESET << std::endl;
                return false;
            }
            else
            {
                std::cout << BOLD << RED << test_name << ": Register 3 (order_id) incorrect" << RESET << std::endl;
                return false;
            }
        }
    }
    return true;

}

int main(int argc, char **argv, char **env)
{

    int test_count = 0;
    int pass_count = 0;

    std::ifstream file("order_book_test_cases.csv");
    std::string line;

    int i; // number of clock cycles to simulate
    int clk; // module clock signal

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

    for (i = 0; i < 300000; i++)
    {
        for(clk = 0; clk < 2; clk++)
        {
            tfp->dump (2*i+clk);
            top->i_clk = !top->i_clk;
            top->eval();
        }

        std::string ss(line);
        std::string testCaseName; 
        std::vector<int> inputs(7);
        std::vector<int> expectedOutputs(30);

        std::getline(ss, testCaseName, ',');

        for (int j = 0; j < 7; ++j) {
            std::string input;
            std::getline(ss, input, ',');
            inputs[j] = std::stoi(input);
        }

        for (int j = 0; j < 30; ++j) {
            std::string output;
            std::getline(ss, output, ',');
            expectedOutputs[j] = std::stoi(output);
        }

        if (i%30 == 0)
        {
            // load inputs every 30 clock cycles
            initialiseInputs(top, inputs);
        }

        if (((i-20)%30 == 0) && (i != 20))
        {
            // read outputs 20 clock cycles after inputs intialised
            if(verifyOutputs(top, expectedOutputs, testCaseName))
            {
                std::cout << GREEN << testCaseName << ": passed" << RESET << std::endl;
                pass_count ++;
            }
        }

        test_count++;

        if(test_count == NUM_TEST_CASES)
        {
            if(test_count != pass_count)
            {
                std::cout << BOLD << RED << "Only " << pass_count << " cases out of " << NUM_TEST_CASES << "passed" << RESET << std::endl;
            }
            else
            {
                std::cout << BOLD << GREEN << "All tests passed" << RESET << std::endl;
            }
            break;
        }
        
    }
    tfp->close();
    exit(0);
}