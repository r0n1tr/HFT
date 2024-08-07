import cocotb
import random
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock

# For fixed test
LOGARITHM = 12
RISK_FACTOR = 0.1
TERMINAL_TIME = 22500

# Since fixed point outputs is very rarely exactly equal to the actual output, we need a valid range of values.
IDEAL_DELTA = 0.0001

def decimal_input_to_fp(decimal_value):
    # USE THIS TO CONVERT INPUTS FIXED POINT FORMAT, THIS DOES: Decimal -> Fixed Point Binary -> Decimal of Fixed Point Binary.

    # Shift the decimal value by 2^32 (to account for 32 bits fractional part)
    scaled_value = round(decimal_value * (1 << 32))
    
    # Mask to ensure the value fits in a 64-bit signed integer (two's complement)
    if scaled_value >= 0:
        fixed_point_value = scaled_value & ((1 << 64) - 1)
    else:
        fixed_point_value = ((1 << 64) + scaled_value) & ((1 << 64) - 1)
    
    return fixed_point_value


def fp_output_to_decimal(fixed_point):
    # USE THIS TO CONVERT OUTPUTS BACK TO ACTUAL VALUES: THIS DOES THE OPPOSITE OF THE FUNCTION ABOVE: Decimal of Fixed Point Binary -> Fixed Point Binary -> Decimal

    # Mask to extract the integer part (upper 32 bits)
    integer_mask = 0xFFFFFFFF00000000
    # Mask to extract the fractional part (lower 32 bits)
    fractional_mask = 0x00000000FFFFFFFF
    
    # Extract the integer part
    integer_part = (fixed_point & integer_mask) >> 32
    
    # Extract the fractional part
    fractional_part = fixed_point & fractional_mask
    
    # Convert the fractional part to decimal by dividing by 2^32
    fractional_decimal = fractional_part / (1 << 32)
    
    # Combine the integer and fractional parts
    decimal_value = integer_part + fractional_decimal
    
    # Adjust for signed numbers
    if integer_part & 0x80000000:  # Check if the sign bit is set
        decimal_value -= (1 << 32)  # Adjust for negative numbers
    
    return decimal_value


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
    dut.i_volatility.value = decimal_input_to_fp(input_volatility)
    dut.i_curr_time.value = input_curr_time
    dut.i_logarithm.value = decimal_input_to_fp(LOGARITHM)
    dut.i_risk_factor.value = decimal_input_to_fp(RISK_FACTOR)
    dut.i_terminal_time.value = TERMINAL_TIME

    await RisingEdge(dut.i_clk)

    await Timer(0.1, units="ns") # analagoues but not equivalent of rise time

    non_fp_expected_value = (RISK_FACTOR * input_volatility*(TERMINAL_TIME - input_curr_time) + LOGARITHM)
    dut._log.info("Spread is: %s", fp_output_to_decimal(dut.o_spread.value))
    epsilon = fp_output_to_decimal(dut.o_spread.value) - non_fp_expected_value
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
    dut.i_volatility.value = decimal_input_to_fp(input_volatility)
    dut.i_curr_time.value = input_curr_time
    dut.i_logarithm.value = decimal_input_to_fp(input_logarithm)
    dut.i_risk_factor.value = decimal_input_to_fp(input_risk_factor)
    dut.i_terminal_time.value = TERMINAL_TIME

    await RisingEdge(dut.i_clk)

    await Timer(0.1, units="ns")

    non_fp_expected_value = (input_risk_factor * input_volatility*(TERMINAL_TIME - input_curr_time) + input_logarithm)
    dut._log.info("Spread is: %s", fp_output_to_decimal(dut.o_spread.value))
    epsilon = fp_output_to_decimal(dut.o_spread.value) - non_fp_expected_value
    assert abs(epsilon) < IDEAL_DELTA, "Invalid Spread Result"
    assert dut.o_data_valid.value == 1, "Invalid Valid Signal"

    await RisingEdge(dut.i_clk)