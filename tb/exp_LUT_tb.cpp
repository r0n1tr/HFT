#include "Vexp_LUT.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <iostream>
#include <iomanip>

int main(int argc, char **argv, char **env)
{
    int i; // number of clock cycles to simulate
    int clk; // module clock signal

    Verilated::commandArgs(argc, argv);

    // top level instance
    Vexp_LUT* top = new Vexp_LUT;

    // trace dump initialisation - signal tracing turned on, tell verilator when to dump the waveform to exp_LUT.vcd
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("exp_LUT.vcd");

    // simulation inputs
    top->i_clk = 1;

    for (i = 0; i < 40; i++)
    {
        for (clk = 0; clk < 2; clk++)
        {
            tfp->dump(2*i+clk);
            top->i_clk = !top->i_clk;
            top->eval();
        }

        // Apply inputs and print the outputs
        if (i == 2)
        {
            top->argument = 1 << 16; // 1.0 in fixed-point (1 << 16)
            top->eval();
            std::cout << "exp(1) = 0x" << std::hex << top->exp_output << std::dec << std::endl;
        }
        if (i == 4)
        {
            top->argument = 5 << 16; // 5.0 in fixed-point (5 << 16)
            top->eval();
            std::cout << "exp(5) = 0x" << std::hex << top->exp_output << std::dec << std::endl;
        }
        if (i == 6)
        {
            top->argument = 10 << 16; // 10.0 in fixed-point (10 << 16)
            top->eval();
            std::cout << "exp(10) = 0x" << std::hex << top->exp_output << std::dec << std::endl;
        }
        if (i == 8)
        {
            top->argument = 100 << 16; // 100.0 in fixed-point (100 << 16)
            top->eval();
            std::cout << "exp(100) = 0x" << std::hex << top->exp_output << std::dec << std::endl;
        }
    }

    tfp->close();
    delete top;
    exit(0);
}
