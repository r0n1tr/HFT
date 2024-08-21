import cocotb
import random
import math
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock
from helpers import make_fixed_point_input, convert_fixed_point_output 

def calculate_bid(ref_price, spread):
    return ref_price - (spread/2)

def calculate_ask(ref_price, spread):
    return ref_price + (spread/2)

@cocotb.test()
async def fixed_input_test(dut):
    """Fixed input testing"""

    cocotb.fork(Clock(dut.i_clk, 10, "ns").start())

    dut.i_ref_price.value = 0
    dut.i_spread.value = 0
    dut.i_data_valid.value = 0

    await RisingEdge(dut.i_clk)

    input_ref_price = 1234567.89
    input_spread = 1234

    dut.i_ref_price.value = make_fixed_point_input(input_ref_price)
    dut.i_spread.value = make_fixed_point_input(input_spread)
    dut.i_data_valid = 1

    await RisingEdge(dut.i_clk)

    await Timer(0.1, units="ns")

    actual_bid = calculate_bid(input_ref_price, input_spread)
    actual_ask = calculate_ask(input_ref_price, input_spread)
    dut._log.info("Actual bid price: %s", actual_bid)
    dut._log.info("Actual ask price: %s", actual_ask)
    received_bid = int(dut.o_buy_price.value)
    received_ask = int(dut.o_ask_price.value)
    dut._log.info("Received bid price: %s", received_bid)
    dut._log.info("Received ask price: %s", received_ask)
    assert received_bid == math.floor(actual_bid), "Received bid incorrect"
    assert received_ask == math.floor(actual_ask), "Received ask incorrect"
    assert dut.o_data_valid.value == 1, "Valid signal incorrect"

    await RisingEdge(dut.i_clk)


@cocotb.test()
async def random_input_test(dut):
    """Random input testing"""

    cocotb.fork(Clock(dut.i_clk, 10, "ns").start())

    dut.i_ref_price.value = 0
    dut.i_spread.value = 0
    dut.i_data_valid.value = 0

    await RisingEdge(dut.i_clk)

    input_ref_price = random.uniform(1000000.000, 6000000.000)
    input_spread = random.uniform(1000.000, 9000.000)

    dut.i_ref_price.value = make_fixed_point_input(input_ref_price)
    dut.i_spread.value = make_fixed_point_input(input_spread)
    dut.i_data_valid = 1

    await RisingEdge(dut.i_clk)

    await Timer(0.1, units="ns")

    actual_bid = calculate_bid(input_ref_price, input_spread)
    actual_ask = calculate_ask(input_ref_price, input_spread)
    dut._log.info("Actual bid price: %s", actual_bid)
    dut._log.info("Actual ask price: %s", actual_ask)
    received_bid = int(dut.o_buy_price.value)
    received_ask = int(dut.o_ask_price.value)
    dut._log.info("Received bid price: %s", received_bid)
    dut._log.info("Received ask price: %s", received_ask)
    assert received_bid == math.floor(actual_bid), "Received bid incorrect"
    assert received_ask == math.floor(actual_ask), "Received ask incorrect"
    assert dut.o_data_valid.value == 1, "Valid signal incorrect"

    await RisingEdge(dut.i_clk)


