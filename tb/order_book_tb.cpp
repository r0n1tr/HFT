#include "Vorder_book.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char **argv, char **env)
{
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

    for (i = 0; i < 300; i++)
    {
        for(clk = 0; clk < 2; clk++)
        {
            tfp->dump (2*i+clk);
            top->i_clk = !top->i_clk;
            top->eval();
        }
        top->tb_order_book_side = i;
        top->tb_order_book_address = i;
        top->i_reset_n = i;
        top->i_trade_type = i;
        top->i_stock_id = i;
        top->i_order_type = i;
        top->i_quantity = i;
        top->i_price = i;
        top->i_order_id = i;
    }
    tfp->close();
    exit(0);
}