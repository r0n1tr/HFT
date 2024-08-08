import cocotb
import random
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock
from helpers import make_fixed_point_input, convert_fixed_point_output 

# For fixed test
LOGARITHM = 12
RISK_FACTOR = 0.1
TERMINAL_TIME = 22500

# Since fixed point outputs is very rarely exactly equal to the actual output, we need a valid range of values.
IDEAL_DELTA = 0.0001

@cocotb.test()
async def fixed_inputs(dut):
    """Testing spread calculations with fixed inputs"""

    cocotb.fork(Clock(dut.i_clk, 10, "ns").start())

    # Initial values:
    dut.i_curr_time.value = 0
    dut.i_volatility.value = 0
    dut.i_data_valid.value = 0
    dut.i_curr_time.value = 0
    dut.i_logarithm.value = 0
    dut.i_risk_factor.value = 0
    dut.i_terminal_time.value = 0


    for _ in range (3):
        await RisingEdge(dut.i_clk)  # wait for falling edge/"negedge"

    input_volatility = 14
    input_curr_time = 3456

    await RisingEdge(dut.i_clk)
    dut.i_data_valid.value = 1
    dut.i_volatility.value = make_fixed_point_input(input_volatility)
    dut.i_curr_time.value = input_curr_time
    dut.i_logarithm.value = make_fixed_point_input(LOGARITHM)
    dut.i_risk_factor.value = make_fixed_point_input(RISK_FACTOR)
    dut.i_terminal_time.value = TERMINAL_TIME

    await RisingEdge(dut.i_clk)

    await Timer(0.1, units="ns") # analagoues but not equivalent of rise time

    non_fp_expected_value = (RISK_FACTOR * input_volatility*(TERMINAL_TIME - input_curr_time) + LOGARITHM)
    dut._log.info("Spread is: %s", convert_fixed_point_output(dut.o_spread.value))
    epsilon = convert_fixed_point_output(dut.o_spread.value) - non_fp_expected_value
    assert abs(epsilon) < IDEAL_DELTA, "Invalid Spread Result"
    assert dut.o_data_valid.value == 1, "Invalid Valid Signal"

    await RisingEdge(dut.i_clk)




@cocotb.test()
async def random_inputs(dut):
    """Testing spread calculation with random inputs"""

    cocotb.fork(Clock(dut.i_clk, 10, "ns").start())

    # Initial values:
    dut.i_curr_time.value = 0
    dut.i_volatility.value = 0
    dut.i_data_valid.value = 0
    dut.i_curr_time.value = 0
    dut.i_logarithm.value = 0
    dut.i_risk_factor.value = 0
    dut.i_terminal_time.value = 0

    for _ in range (3):
        await RisingEdge(dut.i_clk)  # wait for falling edge/"negedge"

    input_volatility = random.uniform(0.5, 5.5)
    input_curr_time = random.randint(0, 22500)
    input_risk_factor = random.uniform(0.1, 0.5)
    input_logarithm = random.uniform(0.1, 10)

    await RisingEdge(dut.i_clk)
    dut.i_data_valid.value = 1
    dut.i_volatility.value = make_fixed_point_input(input_volatility)
    dut.i_curr_time.value = input_curr_time
    dut.i_logarithm.value = make_fixed_point_input(input_logarithm)
    dut.i_risk_factor.value = make_fixed_point_input(input_risk_factor)
    dut.i_terminal_time.value = TERMINAL_TIME

    await RisingEdge(dut.i_clk)

    await Timer(0.1, units="ns")

    non_fp_expected_value = (input_risk_factor * input_volatility*(TERMINAL_TIME - input_curr_time) + input_logarithm)
    dut._log.info("Spread is: %s", convert_fixed_point_output(dut.o_spread.value))
    epsilon = convert_fixed_point_output(dut.o_spread.value) - non_fp_expected_value
    assert abs(epsilon) < IDEAL_DELTA, "Invalid Spread Result"
    assert dut.o_data_valid.value == 1, "Invalid Valid Signal"

    await RisingEdge(dut.i_clk)