import cocotb
import random
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock
from helpers import make_fixed_point_input, convert_fixed_point_output 

BUFFER_SIZE = 20

# Model functions
write_addresses = [0, 20, 40, 60]

def return_incremented_write_address(stock_id):
    temp = write_addresses[stock_id]
    write_addresses[stock_id] = (BUFFER_SIZE*stock_id)+((write_addresses[stock_id] + 1)%BUFFER_SIZE)
    return temp

def reset_inventory():
    for i in range(len(write_addresses)):
        write_addresses[i] = i * BUFFER_SIZE



# Test cases: 
@cocotb.test()
async def random_increment_test_1(dut):
    """Randomly increment buffer write pointers"""
    # randomly choose a stock and increment its write pointer when we have valid input. 
    # repeat for all stocks, until write pointer for all stocks = 19 (end of buffer)
    cocotb.start_soon(Clock(dut.i_clk, 10, "ns").start())
    # initialise defualts:
    dut.i_reset_n.value = 0
    dut.i_stock_id.value = 0
    dut.i_data_valid.value = 0
    dut.i_buffer_size.value = BUFFER_SIZE

    await RisingEdge(dut.i_clk)

    dut.i_reset_n.value = 1

    await RisingEdge(dut.i_clk)

    NUM_TESTS = 19 # only do 18 here, I want to confirm that overflow actually works in the next test

    test_counts = [0, 0, 0, 0]
    while any(c < NUM_TESTS for c in test_counts):
        num = random.randint(0, 3)
        if test_counts[num] < NUM_TESTS:
            dut.i_stock_id.value = num
            dut.i_data_valid.value = 1
            actual_address = return_incremented_write_address(num)
            await RisingEdge(dut.i_clk)
            await Timer(0.1, units="ns")
            received_address = int(dut.o_write_address.value)
            dut._log.info("Actual address: %s", actual_address)
            dut._log.info("Received address: %s", received_address)
            assert received_address == actual_address, f"Incorrect Address with stock_id: {num}. Expected: {actual_address}, Received: {int(received_address)}"
            assert dut.o_addr_valid.value == 1, "Incorrect valid signal"
            dut.i_data_valid.value = 0
            await RisingEdge(dut.i_clk)
            test_counts[num] += 1



@cocotb.test()
async def overflow_test_1(dut):
    """Testing overflow functionality of buffer"""
    # randomly choose stocks and check that overflow works - go until write pointer is 19 again
    NUM_TESTS = 18
    cocotb.start_soon(Clock(dut.i_clk, 10, "ns").start())
    await RisingEdge(dut.i_clk)
    test_counts = [0, 0, 0, 0]
    while any(c < NUM_TESTS for c in test_counts):
        num = random.randint(0, 3)
        if test_counts[num] < NUM_TESTS:
            dut.i_stock_id.value = num
            dut.i_data_valid.value = 1
            actual_address = return_incremented_write_address(num)
            await RisingEdge(dut.i_clk)
            await Timer(0.1, units="ns")
            received_address = int(dut.o_write_address.value)
            dut._log.info("Actual address: %s", actual_address)
            dut._log.info("Received address: %s", received_address)
            assert received_address == actual_address, f"Incorrect Address with stock_id: {num}. Expected: {actual_address}, Received: {int(received_address)}"
            assert dut.o_addr_valid.value == 1, "Incorrect valid signal"
            dut.i_data_valid.value = 0
            await RisingEdge(dut.i_clk)
            test_counts[num] += 1



@cocotb.test()
async def overflow_test_2(dut):
    """Testing overflow functionality of buffer"""
    # randomly choose stocks and check that overflow works - go until write pointer is 19 again
    # this test checks that multiple overflow works
    NUM_TESTS = 20
    cocotb.start_soon(Clock(dut.i_clk, 10, "ns").start())
    await RisingEdge(dut.i_clk)
    test_counts = [0, 0, 0, 0]
    while any(c < NUM_TESTS for c in test_counts):
        num = random.randint(0, 3)
        if test_counts[num] < NUM_TESTS:
            dut.i_stock_id.value = num
            dut.i_data_valid.value = 1
            actual_address = return_incremented_write_address(num)
            await RisingEdge(dut.i_clk)
            await Timer(0.1, units="ns")
            received_address = int(dut.o_write_address.value)
            dut._log.info("Actual address: %s", actual_address)
            dut._log.info("Received address: %s", received_address)
            assert received_address == actual_address, f"Incorrect Address with stock_id: {num}. Expected: {actual_address}, Received: {int(received_address)}"
            assert dut.o_addr_valid.value == 1, "Incorrect valid signal"
            dut.i_data_valid.value = 0
            await RisingEdge(dut.i_clk)
            test_counts[num] += 1



@cocotb.test()
async def reset_test(dut):
    """Testing reset functionality"""
    # check that the buffer is reset correctly 
    cocotb.start_soon(Clock(dut.i_clk, 10, "ns").start())
    # initialise defualts:
    dut.i_reset_n.value = 0
    dut.i_stock_id.value = 0
    dut.i_data_valid.value = 0
    dut.i_buffer_size.value = BUFFER_SIZE

    reset_inventory()

    await RisingEdge(dut.i_clk)
    dut.i_reset_n.value = 1
    dut.i_stock_id.value = 0
    dut.i_data_valid.value = 1
    actual_address = return_incremented_write_address(0)
    await RisingEdge(dut.i_clk)
    await Timer(0.1, units="ns")
    received_address = int(dut.o_write_address.value)
    dut._log.info("Actual address: %s", actual_address)
    dut._log.info("Received address: %s", received_address)
    assert received_address == actual_address, f"Incorrect Address with stock_id: {0}. Expected: {actual_address}, Received: {int(received_address)}"
    assert dut.o_addr_valid.value == 1, "Incorrect valid signal"
    dut.i_data_valid.value = 0


    await RisingEdge(dut.i_clk)
    dut.i_reset_n.value = 1
    dut.i_stock_id.value = 1
    dut.i_data_valid.value = 1
    actual_address = return_incremented_write_address(1)
    await RisingEdge(dut.i_clk)
    await Timer(0.1, units="ns")
    received_address = int(dut.o_write_address.value)
    dut._log.info("Actual address: %s", actual_address)
    dut._log.info("Received address: %s", received_address)
    assert received_address == actual_address, f"Incorrect Address with stock_id: {1}. Expected: {actual_address}, Received: {int(received_address)}"
    assert dut.o_addr_valid.value == 1, "Incorrect valid signal"
    dut.i_data_valid.value = 0
    await RisingEdge(dut.i_clk)


    await RisingEdge(dut.i_clk)
    dut.i_reset_n.value = 1
    dut.i_stock_id.value = 2
    dut.i_data_valid.value = 1
    actual_address = return_incremented_write_address(2)
    await RisingEdge(dut.i_clk)
    await Timer(0.1, units="ns")
    received_address = int(dut.o_write_address.value)
    dut._log.info("Actual address: %s", actual_address)
    dut._log.info("Received address: %s", received_address)
    assert received_address == actual_address, f"Incorrect Address with stock_id: {2}. Expected: {actual_address}, Received: {int(received_address)}"
    assert dut.o_addr_valid.value == 1, "Incorrect valid signal"
    dut.i_data_valid.value = 0
    await RisingEdge(dut.i_clk)


    await RisingEdge(dut.i_clk)
    dut.i_reset_n.value = 1
    dut.i_stock_id.value = 3
    dut.i_data_valid.value = 1
    actual_address = return_incremented_write_address(3)
    await RisingEdge(dut.i_clk)
    await Timer(0.1, units="ns")
    received_address = int(dut.o_write_address.value)
    dut._log.info("Actual address: %s", actual_address)
    dut._log.info("Received address: %s", received_address)
    assert received_address == actual_address, f"Incorrect Address with stock_id: {3}. Expected: {actual_address}, Received: {int(received_address)}"
    assert dut.o_addr_valid.value == 1, "Incorrect valid signal"
    dut.i_data_valid.value = 0
    await RisingEdge(dut.i_clk)



@cocotb.test()
async def random_increment_test_2(dut):
    """Randomly increment buffer write pointers"""
    # randomly choose a stock and increment its write pointer when we have valid input. 
    # repeat for all stocks, until write pointer for all stocks = 19 (end of buffer)
    cocotb.start_soon(Clock(dut.i_clk, 10, "ns").start())
    # initialise defualts:
    await RisingEdge(dut.i_clk)

    dut.i_reset_n.value = 1

    await RisingEdge(dut.i_clk)

    NUM_TESTS = 19 # only do 18 here, I want to confirm that overflow actually works in the next test

    test_counts = [0, 0, 0, 0]
    while any(c < NUM_TESTS for c in test_counts):
        num = random.randint(0, 3)
        if test_counts[num] < NUM_TESTS:
            dut.i_stock_id.value = num
            dut.i_data_valid.value = 1
            actual_address = return_incremented_write_address(num)
            await RisingEdge(dut.i_clk)
            await Timer(0.1, units="ns")
            received_address = int(dut.o_write_address.value)
            dut._log.info("Actual address: %s", actual_address)
            dut._log.info("Received address: %s", received_address)
            assert received_address == actual_address, f"Incorrect Address with stock_id: {num}. Expected: {actual_address}, Received: {int(received_address)}"
            assert dut.o_addr_valid.value == 1, "Incorrect valid signal"
            dut.i_data_valid.value = 0
            await RisingEdge(dut.i_clk)
            test_counts[num] += 1




