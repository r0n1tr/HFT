#include "TestCase.h"
#include "Vhft_top.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <iostream>
#include <vector>
#include <string>
#include <fstream>
#include <sstream>

int main(int argc, char **argv, char **env)
{
    int i; // number of clock cycles to simulate
    int clk; // module clock signal

    Verilated::commandArgs(argc, argv);

    // top level instance
    Vhft_top* top = new Vhft_top;

    // trace dump initialisation - signal tracing turned on, tell verilator when to dump the waveform to hft_top.vcd
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open ("hft_top.vcd");

    // simualtion inputs
    top->i_clk = 1;

    
    
    // Close the file

    
    for (int i = 0; i < 10000; i++) {
        for (int clk = 0; clk < 2; clk++) {
            tfp->dump(2 * i + clk);
            top->i_clk = !top->i_clk;
            top->eval();
        }
    
        
    }

    tfp->close();
    delete top;
    return 0;
}