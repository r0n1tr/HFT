import cocotb
from cocotb.triggers import FallingEdge, Timer
from cocotb.clock import Clock


@cocotb.test()
async def my_second_test(dut):
    """Testing spread calculations"""

    cocotb.fork(Clock(dut.i_clk, 10, "ns").start())

    await Timer(100, units="ns")  # wait a bit
    await FallingEdge(dut.i_clk)  # wait for falling edge/"negedge"

    dut._log.info("my_signal_1 is %s", dut.o_spread)
    assert dut.o_data_valid.value == 0, "my_signal_2[0] is not 0!"