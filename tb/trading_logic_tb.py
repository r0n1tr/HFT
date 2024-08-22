import cocotb
import random
import numpy as np
import math
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock
from helpers import make_fixed_point_input, convert_fixed_point_output 

BUFFER_SIZE = 32

async def toggle_reset(dut):
    if dut.i_reset_n.value == 0:
        dut.i_reset_n.value =1
    else:
        dut.i_reset_n.value = 0


async def initialise_inputs(dut):
    dut.i_best_ask.value = 0
    dut.i_best_bid.value = 0
    dut.i_curr_time.value = 0
    dut.i_inventory_state.value = 0
    dut.i_data_valid.value = 0
    dut.i_stock_id.value = 0

async def load_test_inputs(dut, best_ask, best_bid, curr_time, inventory_state, stock_id):
    dut.i_best_ask.value = best_ask
    dut.i_best_bid.value = best_bid
    dut.i_curr_time.value = make_fixed_point_input(curr_time)
    dut.i_inventory_state.value = make_fixed_point_input(inventory_state)
    dut.i_data_valid.value = 1
    dut.i_stock_id.value = stock_id

@cocotb.test()
async def test_trading_logic(dut):
    """Testing trading logic"""
    dut.i_reset_n.value = 1
    cocotb.start_soon(Clock(dut.i_clk, 10, "ns").start())
    cocotb.start_soon(toggle_reset(dut))
    cocotb.start_soon(initialise_inputs(dut))

    await RisingEdge(dut.i_clk)
    await RisingEdge(dut.i_clk)
    cocotb.start_soon(toggle_reset(dut))
    await RisingEdge(dut.i_clk)


    NUM_TESTS = BUFFER_SIZE # Populate every term in the buffer, or else, we get very big variances

    test_counts = [0, 0, 0, 0]
    # test_counts = [0]
    curr_time = 15000
    while any(c < NUM_TESTS for c in test_counts):
        num = random.randint(0, 3)
        if test_counts[num] < NUM_TESTS:
            if num == 0:
                best_bid = random.randint(100_0000, 100_0005)
                best_ask = random.randint(100_0000, 100_0005)
            elif num == 1:
                best_bid = random.randint(200_0000, 200_0005)
                best_ask = random.randint(200_0000, 200_0005)
            elif num == 2:
                best_bid = random.randint(300_0000, 300_0005)
                best_ask = random.randint(300_0000, 300_0005)
            else:
                best_bid = random.randint(400_0000, 400_0005)
                best_ask = random.randint(400_0000, 400_0005)
            inventory_state = random.uniform(0, 0.05)
            cocotb.start_soon(load_test_inputs(dut, best_ask, best_bid, curr_time, inventory_state, num))
            await RisingEdge(dut.i_clk)
            dut.i_data_valid.value = 0
            curr_time += 1
            for _ in range(10):
                await RisingEdge(dut.i_clk)
            test_counts[num] += 1

    
    NUM_TESTS = 2*BUFFER_SIZE # Populate every term in the buffer, or else, we get very big variances

    test_counts = [0, 0, 0, 0]
    # test_counts = [0]
    curr_time = 15000
    while any(c < NUM_TESTS for c in test_counts):
        num = random.randint(0, 3)
        if test_counts[num] < NUM_TESTS:
            if num == 0:
                best_bid = random.randint(100_0000, 100_0005)
                best_ask = random.randint(100_0000, 100_0005)
            elif num == 1:
                best_bid = random.randint(200_0000, 200_0005)
                best_ask = random.randint(200_0000, 200_0005)
            elif num == 2:
                best_bid = random.randint(300_0000, 300_0005)
                best_ask = random.randint(300_0000, 300_0005)
            else:
                best_bid = random.randint(400_0000, 400_0005)
                best_ask = random.randint(400_0000, 400_0005)
            inventory_state = random.uniform(0, 0.05)
            cocotb.start_soon(load_test_inputs(dut, best_ask, best_bid, curr_time, inventory_state, num))
            await RisingEdge(dut.i_clk)
            dut.i_data_valid.value = 0
            curr_time += 1
            for _ in range(10):
                await RisingEdge(dut.i_clk)
            test_counts[num] += 1

    for _ in range(20):
        await RisingEdge(dut.i_clk)