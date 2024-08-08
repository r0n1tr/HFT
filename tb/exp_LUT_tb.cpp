#include "Vexp_LUT.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <iostream>
#include <iomanip>
#include <cmath>

int main(int argc, char **argv, char **env)
{
    int i; // number of clock cycles to simulate
    int clk; // module clock signal
    float o_root = 0.0;
    float o_rem = 0.0;
    bool valid;
    double constant = 1.52e-5;

    Verilated::commandArgs(argc, argv);

    // top level instance
    Vexp_LUT* top = new Vexp_LUT;

    // trace dump initialization - signal tracing turned on, tell Verilator when to dump the waveform to exp_LUT.vcd
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("exp_LUT.vcd");

    // simulation inputs
    top->i_clk = 1;

    for (i = 0; i < 40; i++)
    {
        for(clk = 0; clk < 2; clk++)
        {
            tfp->dump(2 * i + clk);
            top->i_clk = !top->i_clk;
            top->eval();
        }

        if (i == 2)
        {
            // 1.0 decimal
            top->i_arg = 0x0100;
            int o_result_fixed = top->o_result;
            float o_result_float = o_result_fixed / static_cast<float>(1 << 8); // assuming Q8.8 fixed-point format

            // Print in hexadecimal
            std::cout << "o_result (hex): " << std::hex << std::setw(4) << std::setfill('0') << o_result_fixed << std::dec << std::endl;

            // Print in decimal
            std::cout << "o_result (float): " << o_result_float << std::endl;
        }
        if (i == 4)
        {
            top->i_arg = 0x0020;
            int o_result_fixed = top->o_result;
            float o_result_float = o_result_fixed / static_cast<float>(1 << 8); // assuming Q8.8 fixed-point format

            // Print in hexadecimal
            std::cout << "o_result (hex): " << std::hex << std::setw(4) << std::setfill('0') << o_result_fixed << std::dec << std::endl;

            // Print in decimal
            std::cout << "o_result (float): " << o_result_float << std::endl;
        }
    }

    tfp->close();
    exit(0);
}
