#include "Vsquare_root.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <stdio.h>
#include <iostream>
#include <iomanip>
#include <bitset>

void printFixedPointDecimal(int number, int integerBits, int fractionalBits) {
    // Determine the number of bits in the integer part and fractional part
    int totalBits = integerBits + fractionalBits;
    
    // Mask to extract integer part
    int integerMask = (1 << integerBits) - 1;
    
    // Extract the integer part and fractional part
    int integerPart = (number >> fractionalBits) & integerMask;
    int fractionalPart = number & ((1 << fractionalBits) - 1);
    
    // Convert fractional part to decimal
    double fractionalDecimal = static_cast<double>(fractionalPart) / (1 << fractionalBits);
    
    // Combine integer and fractional parts
    double result = integerPart + fractionalDecimal;

    std::cout << "Fixed-Point Decimal Representation: " << result << std::endl;
}

void printFixedPointBinary(int number, int integerBits, int fractionalBits) {
    int totalBits = integerBits + fractionalBits;
    std::bitset<32> bitset(number); // Assuming the number fits in 32 bits

    // Display integer part
    for (int i = totalBits - 1; i >= fractionalBits; --i) {
        std::cout << bitset[i];
    }

    std::cout << '.';

    // Display fractional part
    for (int i = fractionalBits - 1; i >= 0; --i) {
        std::cout << bitset[i];
    }

    std::cout << std::endl;
}

int main(int argc, char **argv, char **env)
{
    int i; // number of clock cycles to simulate
    int clk; // module clock signal
    // double root = 0.0;
    // double rem = 0.0;
    // bool valid;
    // double constant = 1.52e-5;

    Verilated::commandArgs(argc, argv);

    // top level instance
    Vsquare_root* top = new Vsquare_root;

    // trace dump initialisation - signal tracing turned on, tell verilator when to dump the waveform to square_root.vcd
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open ("square_root.vcd");

    int integerBits = 16; // Number of integer bits
    int fractionalBits = 16; // Number of fractional bits

    // simualtion inputs
    top->i_clk = 1;

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
            case(5):
                std::cout << "Loading inputs..." << std::endl;
                top->i_start = 1;
                // top->rad = 0x00004000;
                top->i_rad = 0x00020000;
                break;
            case(6):
                top->i_start = 0;
            }
        
        if(top->o_valid == 1)
        {
            std::cout << "SQUARE ROOT COMPLETE: " << std::endl; 
            std::cout << i << std::endl;
            std::bitset<32> binary(top->o_root); // Adjust the size (32) if necessary
            // std::cout << binary << std::endl;
            printFixedPointBinary(top->o_root, integerBits, fractionalBits);
            printFixedPointDecimal(top->o_root, integerBits, fractionalBits);
            break;
        }
        
    }

    std::cout << "SIMULATION OVER" << std::endl;

    tfp->close();
    exit(0);
}