import cocotb
import random
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock
from helpers import make_fixed_point_input, convert_fixed_point_output 

BUFFER_SIZE = 20

# Model functions
write_addresses = [0, 0, 0, 0]

def return_incremented_write_address(stock_id):
    write_addresses[stock_id] = (BUFFER_SIZE*stock_id)+((write_addresses[stock_id] + 1)%BUFFER_SIZE)
    return write_addresses[stock_id]



# Test cases: 
@cocotb.test()
async def random_increment_test_1(dut):
    """Randomly increment buffer write pointers"""
    # randomly choose a stock and increment its write pointer when we have valid input. 
    # repeat for all stocks, until write pointer for all stocks = 19 (end of buffer)



@cocotb.test()
async def overflow_test_1(dut):
    """Testing overflow functionality of buffer"""
    # randomly choose stocks and check that overflow works - go until write pointer is 19 again



@cocotb.test()
async def overflow_test_2(dut):
    """Testing overflow functionality of buffer"""
    # randomly choose stocks and check that overflow works - go until write pointer is 19 again
    # this test checks that multiple overflow works



@cocotb.test()
async def reset_test(dut):
    """Testing reset functionality"""
    # check that the buffer is reset correctly 



@cocotb.test()
async def random_increment_test_2(dut):
    """Randomly increment buffer write pointers"""
    # randomly choose a stock and increment its write pointer when we have valid input. 
    # repeat for all stocks, until write pointer for all stocks = 19 (end of buffer)





