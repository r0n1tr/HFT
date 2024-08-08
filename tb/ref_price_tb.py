import cocotb
import random
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock
from helpers import make_fixed_point_input, convert_fixed_point_output 

RISK_FACTOR = 0.2
TERMINAL_TIME = 22500

IDEAL_DELTA = 0.1 # We can afford to be less strict here than in spread, cos the fractional part for price would be mostly cutoff in the end

@cocotb.test()
async def reset_test(dut):
    """Testing Reset Functionality"""

    cocotb.fork(Clock(dut.i_clk, 10, "ns").start())

    dut.i_reset_n.value = 1
    dut.i_curr_price.value = 0
    dut.i_inventory_state.value = 0
    dut.i_curr_time.value = 0
    dut.i_volatility.value = 0
    dut.i_terminal_time.value = 0 
    dut.i_risk_factor.value = 0
    dut.i_data_valid.value = 0

    for _ in range(3):
        await RisingEdge(dut.i_clk)

    dut.i_data_valid.value = 1
    dut.i_curr_price.value = random.randint(10000, 50000)
    dut.i_inventory_state.value = random.randint(10000, 50000)
    dut.i_curr_time.value = random.randint(0, 22500)
    dut.i_volatility.value = make_fixed_point_input(random.uniform(0.5, 5.5))
    dut.i_terminal_time.value = TERMINAL_TIME
    dut.i_risk_factor.value = make_fixed_point_input(RISK_FACTOR)

    await RisingEdge(dut.i_clk)
    dut.i_reset_n.value = 0

    await RisingEdge(dut.i_clk)
    dut.i_reset_n.value = 1

    await Timer(0.1, units="ns")

    await RisingEdge(dut.i_clk)
    assert dut.o_ref_price.value == 0, "Reset failed"
    assert dut.o_data_valid.value == 0, "Invalid valid signal"

    await RisingEdge(dut.i_clk)

    

@cocotb.test()
async def fixed_inputs(dut):
    """Testing fixed input functionality"""

    cocotb.fork(Clock(dut.i_clk, 10, "ns").start())

    # Initialise test
    dut.i_reset_n.value = 1
    dut.i_curr_price.value = 0
    dut.i_inventory_state.value = 0
    dut.i_curr_time.value = 0
    dut.i_volatility.value = 0
    dut.i_terminal_time.value = 0 
    dut.i_risk_factor.value = 0
    dut.i_data_valid.value = 0

    for _ in range(3):
        await RisingEdge(dut.i_clk)

    input_curr_price = 1234567
    input_inventory_state = 9982
    input_curr_time = 17890
    input_volatility = 1.892

    # Test case inputs
    dut.i_curr_price.value = input_curr_price
    dut.i_inventory_state.value = input_inventory_state
    dut.i_curr_time.value = input_curr_time
    dut.i_volatility.value = make_fixed_point_input(input_volatility)
    dut.i_terminal_time.value = TERMINAL_TIME
    dut.i_risk_factor.value = make_fixed_point_input(RISK_FACTOR)
    dut.i_data_valid.value = 1

    await RisingEdge(dut.i_clk)

    await Timer(0.1, units="ns") # Defo need this

    actual = input_curr_price - (input_inventory_state*RISK_FACTOR*input_volatility*(TERMINAL_TIME - input_curr_time))
    dut._log.info("Actual ref price: %s", actual)
    received = convert_fixed_point_output(dut.o_ref_price.value)
    dut._log.info("Received ref price: %s", received)
    epsilon = actual - received
    assert abs(epsilon) < IDEAL_DELTA, "Invalid reference price result"
    assert dut.o_data_valid.value == 1, "Invalid valid signal"



@cocotb.test()
async def random_inputs(dut):
    """Testing randomised inputs functionality"""

    cocotb.fork(Clock(dut.i_clk, 10, "ns").start())

    dut.i_reset_n.value = 1
    dut.i_curr_price.value = 0
    dut.i_inventory_state.value = 0
    dut.i_curr_time.value = 0
    dut.i_volatility.value = 0
    dut.i_terminal_time.value = 0 
    dut.i_risk_factor.value = 0
    dut.i_data_valid.value = 0

    for _ in range(3):
        await RisingEdge(dut.i_clk)

    input_curr_price = random.randint(10000, 2000000)
    input_inventory_state = random.randint(4000, 10000)
    input_curr_time = random.randint(0, 22500)
    input_volatility = random.uniform(0.5, 5.5)
    input_risk_factor = random.uniform(0.1, 0.5)

    # Test case inputs
    dut.i_curr_price.value = input_curr_price
    dut.i_inventory_state.value = input_inventory_state
    dut.i_curr_time.value = input_curr_time
    dut.i_volatility.value = make_fixed_point_input(input_volatility)
    dut.i_terminal_time.value = TERMINAL_TIME
    dut.i_risk_factor.value = make_fixed_point_input(input_risk_factor)
    dut.i_data_valid.value = 1

    await RisingEdge(dut.i_clk)

    await Timer(0.1, units="ns")

    actual = input_curr_price - (input_inventory_state*input_risk_factor*input_volatility*(TERMINAL_TIME - input_curr_time))
    dut._log.info("Actual ref price: %s", actual)
    received = convert_fixed_point_output(dut.o_ref_price.value)
    dut._log.info("Received ref price: %s", received)
    epsilon = actual - received
    assert abs(epsilon) < IDEAL_DELTA, "Invalid reference price result"
    assert dut.o_data_valid.value == 1, "Invalid valid signal"
