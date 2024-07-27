#include "Vsquare_root.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <stdio.h>
#include <iostream>
#include <iomanip>

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
    Vsquare_root* top = new Vsquare_root;

    // trace dump initialisation - signal tracing turned on, tell verilator when to dump the waveform to square_root.vcd
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open ("square_root.vcd");

    // simualtion inputs
    top->i_clk = 1;

    for (i = 0; i < 40; i++)
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
        

        top->i_rad = 2.0;
        valid = top->o_valid;

        // if(valid){
        
        //     o_root = top->o_root;
        //     o_rem = top->o_rem;
        //     std::cout << std::fixed << std::setprecision(10); // Set precision to 10 decimal places
        //     std::cout << "root: " << o_root << std::endl;
        //     std::cout << "rem: " << o_rem << std::endl;
        // }
        if (valid) {
            o_root = top->o_root;
            o_rem = top->o_rem;
            std::cout << std::fixed << std::setprecision(10); // Set precision to 10 decimal places
            std::cout << "\t" << std::setw(8) << (2 * i + clk) << ": "
                      << "sqrt(" << top->i_rad << ") = " << top->o_LHS << "." << top->o_RHS << " "
                      << std::bitset<32>(static_cast<unsigned long>(o_root)) << " ("
                    //   << o_root << ") "
                    //   << "(rem = " << std::bitset<16>(static_cast<unsigned long long>(o_rem)) << ") "
                      << "(V = " << valid << ")" << std::endl;
        }

   
    }

    tfp->close();
    exit(0);
}