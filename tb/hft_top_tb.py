import cocotb
import csv
import random
import math
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock

# Helper functions
def read_csv(filename):
    test_cases = []
    with open(filename, 'r') as file:
        reader = csv.reader(file)
        for row in reader:
            test_case = {}
            test_case['name'] = row[0]
            test_case['inputs'] = list(map(int, row[1:8]))
            test_case['expectedOrderBook'] = list(map(int, row[8:128]))
            test_case['expectedOutputs'] = list(map(int, row[128:132]))
            test_cases.append(test_case)
    return test_cases

def verify_order_book(dut, expected_order_book):
    received_outputs = [
        dut.tb_reg_1.value.integer,
        dut.tb_reg_2.value.integer,
        # ... continue for all registers ...
        dut.tb_reg_120.value.integer,
    ]
    
    return received_outputs == expected_order_book

def verify_outputs(dut, expected_outputs):
    received_outputs = [
        dut.o_best_bid.value.integer,
        dut.o_best_ask.value.integer,
        dut.o_book_is_busy.value.integer,
        dut.o_data_valid.value.integer
    ]
    
    return received_outputs == expected_outputs

def initialize_inputs(dut, inputs):
    dut.i_reset_n.value = inputs[0]
    dut.i_trade_type.value = inputs[1]
    dut.i_stock_id.value = inputs[2]
    dut.i_order_type.value = inputs[3]
    dut.i_quantity.value = inputs[4]
    dut.i_price.value = inputs[5]
    dut.i_order_id.value = inputs[6]


@cocotb.test()
async def order_book_test(dut):
    """Order book test from CSV file"""

    # Clock Generation
    cocotb.start_soon(Clock(dut.i_clk, 10, units="ns").start())

    # Read test cases from CSV
    filename = "order_book_test_cases.csv"
    tests = read_csv(filename)
    
    pass_count = 0

    for i, test in enumerate(tests):
        # Initialize Inputs
        initialize_inputs(dut, test['inputs'])

        # Wait for a rising edge to apply inputs
        await RisingEdge(dut.i_clk)
        dut.i_data_valid.value = 1

        # Wait for trading logic to be ready and evaluate
        await RisingEdge(dut.i_clk)
        dut.i_trading_logic_ready.value = 1

        # Verify order book and output
        order_book_correct = verify_order_book(dut, test['expectedOrderBook'])
        outputs_correct = verify_outputs(dut, test['expectedOutputs'])

        if order_book_correct and outputs_correct:
            cocotb.log.info(f"Test {test['name']}: PASSED")
            pass_count += 1
        else:
            cocotb.log.error(f"Test {test['name']}: FAILED")

        # Reset control signals
        dut.i_data_valid.value = 0
        dut.i_trading_logic_ready.value = 0

    total_tests = len(tests)
    if pass_count == total_tests:
        cocotb.log.info(f"All tests passed ({pass_count}/{total_tests})")
    else:
        cocotb.log.error(f"Only {pass_count} tests passed out of {total_tests}")
