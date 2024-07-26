#include "Vsquare_root.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <stdio.h>
#include <iostream>

int main(int argc, char **argv, char **env)
{
    int i; // number of clock cycles to simulate
    int clk; // module clock signal
    double o_root = 0;
    double o_rem = 0.0;
    bool valid;

    Verilated::commandArgs(argc, argv);

    // top level instance
    Vsquare_root* top = new Vsquare_root;

    // trace dump initialisation - signal tracing turned on, tell verilator when to dump the waveform to square_root.vcd
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open ("square_root.vcd");

    // simualtion inputs
    top->i_clk = 1;

    for (i = 0; i < 300; i++)
    {
        for(clk = 0; clk < 2; clk++)
        {
            tfp->dump (2*i+clk);
            top->i_clk = !top->i_clk;
            top->eval();

            if (i == 2 && clk == 0) {
                top->i_start = 1; // Set i_start high at the beginning of the clock cycle
            }
            if (i == 2 && clk == 1) {
                top->i_start = 0; // Set i_start low at the end of the clock cycle
            }
            
        }
        

        top->i_rad = 2;
        valid = top->o_valid;

        if(valid){
        
            o_root = top->o_root;
            o_rem = top->o_rem;
            std::cout << "root: " << o_root << std::endl;
            std::cout << "rem: " << o_rem << std::endl;

        }
   
    }

    tfp->close();
    exit(0);
}