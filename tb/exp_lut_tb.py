import cocotb
import random
import math
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock
from helpers import make_fixed_point_input, convert_fixed_point_output


@cocotb.test()
async def fixed_input_test(dut):
    """Fixed input testing"""

    # Start the clock
    cocotb.fork(Clock(dut.i_clk, 10, "ns").start())

    # Initialize input value
    dut.input_value <= 0  # Start with 0 or a known state
    dut.exp_value <= 0

    await RisingEdge(dut.i_clk)
    # Reset the DUT if applicable
    # dut.i_rst <= 1
    # await Timer(10, units="ns")
    # dut.i_rst <= 0

    # Apply the input
    test_value = 0.3049
    dut.input_value <= make_fixed_point_input(test_value)
    
    # Wait for a few clock cycles for the DUT to process the input
    await RisingEdge(dut.i_clk)
    await RisingEdge(dut.i_clk)

    # Capture and convert the output
    output = convert_fixed_point_output(dut.exp_value.value)
    dut._log.info(f"Input: {test_value} => ExpValue: {output}")

    # Optionally, check the output against the expected value
    expected_output = math.exp(test_value)
    tolerance = 0.01 * expected_output  # Adjust tolerance as needed
    assert abs(output - expected_output) < tolerance, \
        f"Expected {expected_output}, got {output}"

    # Additional clock cycles to observe any delayed responses
    await RisingEdge(dut.i_clk)
