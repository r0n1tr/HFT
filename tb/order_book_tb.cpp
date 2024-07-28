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

    std::ifstream file("Order book test cases.csv");
    if (!file.is_open()) {
        std::cerr << "Failed to open the file." << std::endl;
        return 1;
    }

    std::string line;
    std::getline(file, line); // to skip titles
    

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

    std::vector<int> inputs(7);
    std::vector<int> expectedOrderBook(30);
    std::vector<int> expectedOutputs(5);
    std::string testCaseName;

    std::getline(file, line); // to skip titles
    // Read the entire file into a vector of strings
    std::vector<std::string> lines;
    
    while (std::getline(file, line)) {
        lines.push_back(line);
    }

    // Close the file
    file.close();
    int internal_counter = 0;

    for (int i = 0; i < 300000; i++) {
        for (int clk = 0; clk < 2; clk++) {
            tfp->dump(2 * i + clk);
            top->i_clk = !top->i_clk;
            top->eval();
        }
    
        if (i % 40 == 0 && internal_counter < lines.size()) {
            std::stringstream ss(lines[internal_counter]);
            std::getline(ss, testCaseName, ',');

            for (int j = 0; j < 7; ++j) {
                std::string input;
                std::getline(ss, input, ',');
                if (!input.empty()) {
                    try {
                        inputs[j] = std::stoi(input);
                    } catch (const std::invalid_argument& e) {
                        std::cerr << "Invalid input in test case: " << testCaseName << " - " << input << std::endl;
                        return 1;
                    }
                }
            }

            for (int j = 0; j < 30; ++j) {
                std::string output;
                std::getline(ss, output, ',');
                if (!output.empty()) {
                    try {
                        expectedOrderBook[j] = std::stoi(output);
                    } catch (const std::invalid_argument& e) {
                        std::cerr << "Invalid expected order book value in test case: " << testCaseName << " - " << output << std::endl;
                        return 1;
                    }
                }
            }

            for (int j = 0; j < 5; ++j) {
                std::string output;
                std::getline(ss, output, ',');
                if (!output.empty()) {
                    try {
                        expectedOutputs[j] = std::stoi(output);
                    } catch (const std::invalid_argument& e) {
                        std::cerr << "Invalid expected output value in test case: " << testCaseName << " - " << output << std::endl;
                        return 1;
                    }
                }
            }

            initialiseInputs(top, inputs);
            internal_counter++;
        }

        if (((i - 30) % 40 == 0) && (i != 30)) {
            if (verifyOrderBook(top, expectedOrderBook, testCaseName) && verifyOutputs(top, expectedOutputs, testCaseName)) {
                std::cout << GREEN << testCaseName << ": passed" << RESET << std::endl;
                pass_count++;
            } else {
                std::cout << RED << testCaseName << ": failed" << RESET << std::endl;
            }

            test_count++;
            if (test_count == NUM_TEST_CASES) {
                break;
            }
        }
    }

        if (test_count != pass_count) {
            std::cout << BOLD << RED << "Only " << pass_count << " cases out of " << NUM_TEST_CASES << " passed" << RESET << std::endl;
        } else {
            std::cout << BOLD << GREEN << "All tests passed" << RESET << std::endl;
        }
    

    tfp->close();
    delete top;
    return 0;
}

