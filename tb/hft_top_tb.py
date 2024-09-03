import cocotb
import os
import sys
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import csv
import random
import math
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock
from exchange import Exchange
from test import test

my_exchange = Exchange()
def generate_orders():
    num = random.randint(0,3)
    input_vector = (my_exchange.generate_ITCH_order(num, printing=False, integer_output=True))
    # print(f"{input_vector}")
    return input_vector

def verify_outputs(dut, hardware_outputs):
    expected_outputs_b, expected_outputs_s = test()
    print(f"Simulated Outputs for Buy: {expected_outputs_b}")
    print(f"Simulated Outputs for Sell: {expected_outputs_s}")
    print(f"Hardware Outputs:  {hardware_outputs}")

async def initialize_inputs(dut, inputs):
    dut.i_reg_0.value = inputs[8]
    dut.i_reg_1.value = inputs[7]
    dut.i_reg_2.value = inputs[6]
    dut.i_reg_3.value = inputs[5]
    dut.i_reg_4.value = inputs[4]
    dut.i_reg_5.value = inputs[3]
    dut.i_reg_6.value = inputs[2]
    dut.i_reg_7.value = inputs[1]
    dut.i_reg_8.value = inputs[0]

async def toggle_reset(dut):
    if dut.i_reset_n.value == 0:
        dut.i_reset_n.value =1
    else:
        dut.i_reset_n.value = 0


@cocotb.test()
async def hft_top_test(dut):
    

    # Clock Generation
    dut.i_reset_n.value = 1
    cocotb.start_soon(Clock(dut.i_clk, 10, "ns").start())
    cocotb.start_soon(toggle_reset(dut))
    input = generate_orders()
    dut._log.info("Input ITCH order:: %s", input)
    cocotb.start_soon(initialize_inputs(dut, input))

    hardware_outputs = [
        dut.o_reg_0_b.value,
        dut.o_reg_1_b.value,
        dut.o_reg_2_b.value,
        dut.o_reg_3_b.value,
        dut.o_reg_4_b.value,
        dut.o_reg_5_b.value,
        dut.o_reg_6_b.value,
        dut.o_reg_7_b.value,
        dut.o_reg_8_b.value,
        dut.o_reg_0_s.value,
        dut.o_reg_1_s.value,
        dut.o_reg_2_s.value,
        dut.o_reg_3_s.value,
        dut.o_reg_4_s.value,
        dut.o_reg_5_s.value,
        dut.o_reg_6_s.value,
        dut.o_reg_7_s.value,
        dut.o_reg_8_s.value,
    ]
    # verify_outputs(dut, hardware_outputs)
    for _ in range(20):
        await RisingEdge(dut.i_clk)

    

