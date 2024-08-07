import cocotb
import os
from cocotb.triggers import FallingEdge, Timer, RisingEdge
from cocotb.clock import Clock
from pathlib import Path
from cocotb.runner import get_runner


@cocotb.test()
async def test_case_1(dut):
    """Testing spread calculations"""

    cocotb.fork(Clock(dut.i_clk, 10, "ns").start())

    # Initial values:
    dut.i_curr_time.value = 0
    dut.i_volatility.value = 0
    dut.i_data_valid.value = 0

    for _ in range (10):
        await RisingEdge(dut.i_clk)  # wait for falling edge/"negedge"

    await RisingEdge(dut.i_clk)
    dut.i_volatility.value = 14
    dut.i_data_valid.value = 1

    for _ in range (10):
        await RisingEdge(dut.i_clk)

    # await Timer(1000, units="ns")  # wait a bit


    dut._log.info("my_signal_1 is %s", dut.o_spread)
    assert dut.o_data_valid.value == 0, "my_signal_2[0] is not 0!"



@cocotb.test()
async def test_case_2(dut):
    """Testing spread calculation again"""

    cocotb.fork(Clock(dut.i_clk, 10, "ns").start())

    # Initial values:
    dut.i_curr_time.value = 0
    dut.i_volatility.value = 0
    dut.i_data_valid.value = 0

    for _ in range (10):
        await RisingEdge(dut.i_clk)  # wait for falling edge/"negedge"

    await RisingEdge(dut.i_clk)
    dut.i_volatility.value = 1450
    dut.i_data_valid.value = 1

    for _ in range (10):
        await RisingEdge(dut.i_clk)

    # await Timer(1000, units="ns")  # wait a bit

    dut._log.info("my_signal_1 is %s", dut.o_spread)
    assert dut.o_data_valid.value == 0, "test 2 failed"

