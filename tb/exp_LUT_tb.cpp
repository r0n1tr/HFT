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

        top->input_value = 0x   ;

        std::cout << top->exp_value << std::endl;
        


    }

    tfp->close();
    exit(0);
}
