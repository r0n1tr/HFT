#include "Vparser.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char **argv, char **env)
{
    int i; // number of clock cycles to simulate
    int clk; // module clock signal

    Verilated::commandArgs(argc, argv);

    // top level instance
    Vparser* top = new Vparser;

    // trace dump initialisation - signal tracing turned on, tell verilator when to dump the waveform to parser.vcd
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open ("parser.vcd");

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
        top->i_reg_1 = i;
        top->i_reg_2 = i;
        top->i_reg_3 = i;
        top->i_reg_4 = i;
        top->i_reg_5 = i;
        top->i_reg_6 = i;
        top->i_reg_7 = i;
    }
    tfp->close();
    exit(0);
}