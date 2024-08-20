import cocotb
import random
import matplotlib.pyplot as plt
import numpy as np
import math
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock
from helpers import make_fixed_point_input, convert_fixed_point_output 

IDEAL_DELTA = 75
BUFFER_SIZE = 32

buffers = [
    [], [], [], []
]

actual = []
received = []

write_addresses = [0, 32, 64, 96]

def init_buffers():
    for i in range(4):
        for j in range(BUFFER_SIZE):
            buffers[i].append(0)

def init_write_address():
    for i in range(4):
        write_addresses[i] = i * BUFFER_SIZE


def return_variance(buffer):
    sum = 0 
    square_sum = 0
    for i in range(len(buffers[buffer])):
        sum = sum + buffers[buffer][i]
        square_sum = square_sum + (buffers[buffer][i]*buffers[buffer][i])
    
    variance = square_sum/BUFFER_SIZE - ((sum/BUFFER_SIZE)*(sum/BUFFER_SIZE))
    return variance

def reset_buffer(buffer):
    for i in range(len(buffer)):
        buffer[i] = 0

def generate_address(stock_id):
    temp = write_addresses[stock_id]
    write_addresses[stock_id] = (stock_id * BUFFER_SIZE) + ((write_addresses[stock_id] + 1)%BUFFER_SIZE)
    return temp

def convert_address(stock_id, address):
    return (address - (stock_id*BUFFER_SIZE))

def percentage_diff(diff, actual):
    return ((diff/actual)*100)


async def toggle_reset(dut):
    if dut.i_reset_n.value == 0:
        dut.i_reset_n.value =1
    else:
        dut.i_reset_n.value = 0


async def initialise_inputs(dut):
    dut.i_write_address.value = 0
    dut.i_best_ask.value = 0
    dut.i_best_bid.value = 0
    dut.i_stock_id.value = 0
    dut.i_valid.value = 0
    dut.i_buffer_size.value = BUFFER_SIZE
    dut.i_buffer_size_reciprocal.value = make_fixed_point_input(1/BUFFER_SIZE)

async def load_test_inputs(dut, stock_id, best_ask, best_bid, write_address):
    dut.i_write_address.value = write_address
    dut.i_best_ask.value = best_ask
    dut.i_best_bid.value = best_bid
    dut.i_stock_id.value = stock_id
    dut.i_valid.value = 1
    dut.i_buffer_size.value = BUFFER_SIZE
    dut.i_buffer_size_reciprocal.value = make_fixed_point_input(1/BUFFER_SIZE)


@cocotb.test()
async def volatility_test(dut):
    init_buffers()
    init_write_address()
    """Testing variane of output is correct until buffer is full"""
    dut.i_reset_n.value = 1
    cocotb.start_soon(Clock(dut.i_clk, 10, "ns").start())
    cocotb.start_soon(toggle_reset(dut))
    cocotb.start_soon(initialise_inputs(dut))

    await RisingEdge(dut.i_clk)
    await RisingEdge(dut.i_clk)
    cocotb.start_soon(toggle_reset(dut))


    NUM_TESTS = BUFFER_SIZE # Populate every term in the buffer, or else, we get very big variances

    # test_counts = [0, 0, 0, 0]
    test_counts = [0, 0, 0, 0]
    while any(c < NUM_TESTS for c in test_counts):
        num = random.randint(0, 3)
        if test_counts[num] < NUM_TESTS:
            if num == 0:
                best_bid = random.randint(100_0000, 100_0050)
                best_ask = random.randint(100_0000, 100_0050)
            elif num == 1:
                best_bid = random.randint(200_0000, 200_0050)
                best_ask = random.randint(200_0000, 200_0050)
            elif num == 2:
                best_bid = random.randint(300_0000, 300_0050)
                best_ask = random.randint(300_0000, 300_0050)
            else:
                best_bid = random.randint(400_0000, 400_0050)
                best_ask = random.randint(400_0000, 400_0050)   
            # best_bid = random.randint(100_0000, 100_0050)
            # best_ask = random.randint(100_0000, 100_0050) 
            write_address = generate_address(num)
            cocotb.start_soon(load_test_inputs(dut, num, best_ask, best_bid, write_address))
            await RisingEdge(dut.i_clk)
            await Timer(0.1, units="ns")
            curr_price = (best_bid+best_ask)/2
            # dut._log.info("converted: %s", convert_address(num, write_address))
            # dut._log.info("regular: %s", write_address)
            buffers[num][convert_address(num, write_address)] = curr_price
            actual_volatility = return_variance(num)
            received_volatility = convert_fixed_point_output(dut.o_volatility.value)
            dut._log.info("Actual volatility of stock no: %s : %s", num, actual_volatility)
            dut._log.info("Received volatility of stock no: %s : %s", num, received_volatility)
            test_counts[num] += 1
            dut.i_valid.value = 0
            # await RisingEdge(dut.i_clk)
            for _ in range(10):
                await RisingEdge(dut.i_clk)

    NUM_TESTS = 2*BUFFER_SIZE
    # test_counts = [0, 0, 0, 0]
    test_counts = [0, 0, 0, 0]
    while any(c < NUM_TESTS for c in test_counts):
        num = random.randint(0, 3)
        if test_counts[num] < NUM_TESTS:
            if num == 0:
                best_bid = random.randint(100_0000, 100_0050)
                best_ask = random.randint(100_0000, 100_0050)
            elif num == 1:
                best_bid = random.randint(200_0000, 200_0050)
                best_ask = random.randint(200_0000, 200_0050)
            elif num == 2:
                best_bid = random.randint(300_0000, 300_0050)
                best_ask = random.randint(300_0000, 300_0050)
            else:
                best_bid = random.randint(400_0000, 400_0050)
                best_ask = random.randint(400_0000, 400_0050) 
            # best_bid = random.randint(100_0000, 100_0050)
            # best_ask = random.randint(100_0000, 100_0050) 
            write_address = generate_address(num)
            cocotb.start_soon(load_test_inputs(dut, num, best_ask, best_bid, write_address))
            await RisingEdge(dut.i_clk)
            await Timer(0.1, units="ns")
            curr_price = (best_bid+best_ask)/2
            buffers[num][convert_address(num,write_address)] = curr_price
            actual_volatility = return_variance(num)
            actual.append(actual_volatility)
            received_volatility = convert_fixed_point_output(dut.o_volatility.value)
            received.append(received_volatility)
            received_curr_price = int(dut.o_curr_price.value)
            difference = actual_volatility - received_volatility
            dut._log.info("Actual volatility of stock no: %s : %s", num, actual_volatility)
            dut._log.info("Received volatility of stock no: %s : %s", num, received_volatility)
            # dut._log.info("Percentage difference:  %s", percentage_diff(abs(difference), actual_volatility))
            # dut._log.info("Received volatility of stock no: %s : %s", num, math.floor(curr_price))
            # dut._log.info("Received curr_price of stock no: %s : %s", num, received_curr_price)
            assert percentage_diff(abs(difference), actual_volatility) < 5, "Invalid variance"
            assert dut.o_data_valid.value == 1, "Invalid valid signal"
            assert received_curr_price == math.floor(curr_price), "Invalid curr_price"
            test_counts[num] += 1
            dut.i_valid.value = 0
            # await RisingEdge(dut.i_clk)
            for _ in range(10):
                await RisingEdge(dut.i_clk)

    for _ in range(10):
        await RisingEdge(dut.i_clk)


