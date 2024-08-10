import cocotb
import random
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock
from helpers import make_fixed_point_input, convert_fixed_point_output 

MAX_INVENTORY = 10000
IDEAL_DELTA = 0.000001 # This needs to be high precision since over time, the difference between actual and theoretical values will add up.

inventory = [0, 0, 0, 0]
# Buy orders increase inventory
# Sell orders decrease inventory

def read_inventory(stock_id):
    return inventory[stock_id]



def modify_inventory(stock_id, quantity, side):
    if (not side): # execute buy
        inventory[stock_id] = inventory[stock_id] + (quantity/MAX_INVENTORY)
    else: #sell
        inventory[stock_id] = inventory[stock_id] - (quantity/MAX_INVENTORY)
    return inventory[stock_id]


def reset_inventory():
    for i in range (len(inventory)):
        inventory[i] = 0

@cocotb.test()
async def return_inventory(dut):
    """Read inventory state at the start"""
    cocotb.start_soon(Clock(dut.i_clk, 10, "ns").start())

    # reset to default inputs for test case
    dut.i_reset_n.value = 0
    dut.i_ren.value = 0
    dut.i_stock_id.value = 0
    dut.i_max_inventory_reciprocal.value = make_fixed_point_input(1/MAX_INVENTORY)
    dut.i_execute_order_quantity.value = 0
    dut.i_execute_order.value = 0
    dut.i_execute_order_side.value = 0

    await RisingEdge(dut.i_clk)
    await Timer(0.1, units="ns")

    dut.i_ren.value = 1
    dut.i_stock_id.value = 0
    actual_inventory_0 = read_inventory(0)
    received_inventory_0 = int(dut.o_norm_inventory.value)
    dut._log.info("Actual inventory 0: %s \t", actual_inventory_0)
    dut._log.info("Received inventory 0: %s \t", received_inventory_0)

    await RisingEdge(dut.i_clk)
    await Timer(0.1, units="ns")

    dut.i_ren.value = 1
    dut.i_stock_id.value = 1
    actual_inventory_1 = read_inventory(1)
    received_inventory_1 = int(dut.o_norm_inventory.value)
    dut._log.info("Actual inventory 1: %s \t", actual_inventory_1)
    dut._log.info("Received inventory 1: %s \t", received_inventory_1)

    await RisingEdge(dut.i_clk)
    await Timer(0.1, units="ns")

    dut.i_ren.value = 1
    dut.i_stock_id.value = 1
    actual_inventory_2 = read_inventory(2)
    received_inventory_2 = int(dut.o_norm_inventory.value)
    dut._log.info("Actual inventory 2: %s \t", actual_inventory_2)
    dut._log.info("Received inventory 2: %s \t", received_inventory_2)

    await RisingEdge(dut.i_clk)
    await Timer(0.1, units="ns")

    dut.i_ren.value = 1
    dut.i_stock_id.value = 1
    actual_inventory_3 = read_inventory(3)
    received_inventory_3 = int(dut.o_norm_inventory.value)
    dut._log.info("Actual inventory 3: %s \t", actual_inventory_3)
    dut._log.info("Received inventory 3: %s \t", received_inventory_3)

    await RisingEdge(dut.i_clk)



@cocotb.test()
async def fixed_input_test_1(dut):
    """Execute order on all stocks"""
    cocotb.start_soon(Clock(dut.i_clk, 10, "ns").start())

    dut.i_reset_n.value = 1
    dut.i_ren.value = 0
    dut.i_stock_id.value = 0
    dut.i_max_inventory_reciprocal.value = make_fixed_point_input(1/MAX_INVENTORY)
    dut.i_execute_order_quantity.value = 0
    dut.i_execute_order.value = 0
    dut.i_execute_order_side.value = 0

    await RisingEdge(dut.i_clk)

    # perform execute orders on each stock sequentially:
    quantity_0 = 99
    quantity_1 = 101
    quantity_2 = 202
    quantity_3 = 303
    # stock 0:
    dut.i_stock_id.value = 0
    dut.i_execute_order_quantity.value = quantity_0
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 0 # buy side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)
    #stock 1:
    dut.i_stock_id.value = 1
    dut.i_execute_order_quantity.value = quantity_1
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 0 # buy side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)
    #stock 2:
    dut.i_stock_id.value = 2
    dut.i_execute_order_quantity.value = quantity_2
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 0 # buy side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)
    #stock 3:
    dut.i_stock_id.value = 3
    dut.i_execute_order_quantity.value = quantity_3
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 0 # buy side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)

    # determine expected values:
    actual_0 = modify_inventory(0, quantity_0, 0)
    actual_1 = modify_inventory(1, quantity_1, 0)
    actual_2 = modify_inventory(2, quantity_2, 0)
    actual_3 = modify_inventory(3, quantity_3, 0)


    # perform reads:
    dut.i_ren.value = 1
    dut.i_stock_id.value = 0
    await Timer (0.1, units="ns")
    received_0 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)

    dut.i_ren.value = 1
    dut.i_stock_id.value = 1
    await Timer (0.1, units="ns")
    received_1 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)

    dut.i_ren.value = 1
    dut.i_stock_id.value = 2
    await Timer (0.1, units="ns")
    received_2 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)

    dut.i_ren.value = 1
    dut.i_stock_id.value = 3
    await Timer (0.1, units="ns")
    received_3 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)


    #log outputs:
    dut._log.info("Actual inventory for stock 0: %s \t", actual_0)
    dut._log.info("Received inventory for stock 0: %s \t", received_0)
    dut._log.info("Actual inventory for stock 1: %s \t", actual_1)
    dut._log.info("Received inventory for stock 1: %s \t", received_1)
    dut._log.info("Actual inventory for stock 2: %s \t", actual_2)
    dut._log.info("Received inventory for stock 2: %s \t", received_2)
    dut._log.info("Actual inventory for stock 3: %s \t", actual_3)
    dut._log.info("Received inventory for stock 3: %s \t", received_3)


    # verify
    epsilon = actual_0 - received_0
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 0"

    epsilon = actual_1 - received_1
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 1"

    epsilon = actual_2 - received_2
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 2"

    epsilon = actual_3 - received_3
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 3"



@cocotb.test()
async def fixed_input_test_2(dut):
    """Execute another buy order on all stocks"""
    cocotb.start_soon(Clock(dut.i_clk, 10, "ns").start())

    dut.i_reset_n.value = 1
    dut.i_ren.value = 0
    dut.i_stock_id.value = 0
    dut.i_max_inventory_reciprocal.value = make_fixed_point_input(1/MAX_INVENTORY)
    dut.i_execute_order_quantity.value = 0
    dut.i_execute_order.value = 0
    dut.i_execute_order_side.value = 0

    await RisingEdge(dut.i_clk)

    quantity_0 = 191
    quantity_1 = 251
    quantity_2 = 317
    quantity_3 = 443
    # stock 0:
    dut.i_stock_id.value = 0
    dut.i_execute_order_quantity.value = quantity_0
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 0 # buy side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)
    #stock 1:
    dut.i_stock_id.value = 1
    dut.i_execute_order_quantity.value = quantity_1
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 0 # buy side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)
    #stock 2:
    dut.i_stock_id.value = 2
    dut.i_execute_order_quantity.value = quantity_2
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 0 # buy side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)
    #stock 3:
    dut.i_stock_id.value = 3
    dut.i_execute_order_quantity.value = quantity_3
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 0 # buy side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)

    # determine expected values:
    actual_0 = modify_inventory(0, quantity_0, 0)
    actual_1 = modify_inventory(1, quantity_1, 0)
    actual_2 = modify_inventory(2, quantity_2, 0)
    actual_3 = modify_inventory(3, quantity_3, 0)


    # perform reads:
    dut.i_ren.value = 1
    dut.i_stock_id.value = 0
    await Timer (0.1, units="ns")
    received_0 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)

    dut.i_ren.value = 1
    dut.i_stock_id.value = 1
    await Timer (0.1, units="ns")
    received_1 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)

    dut.i_ren.value = 1
    dut.i_stock_id.value = 2
    await Timer (0.1, units="ns")
    received_2 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)

    dut.i_ren.value = 1
    dut.i_stock_id.value = 3
    await Timer (0.1, units="ns")
    received_3 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)


    #log outputs:
    dut._log.info("Actual inventory for stock 0: %s \t", actual_0)
    dut._log.info("Received inventory for stock 0: %s \t", received_0)
    dut._log.info("Actual inventory for stock 1: %s \t", actual_1)
    dut._log.info("Received inventory for stock 1: %s \t", received_1)
    dut._log.info("Actual inventory for stock 2: %s \t", actual_2)
    dut._log.info("Received inventory for stock 2: %s \t", received_2)
    dut._log.info("Actual inventory for stock 3: %s \t", actual_3)
    dut._log.info("Received inventory for stock 3: %s \t", received_3)


    # verify
    epsilon = actual_0 - received_0
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 0"

    epsilon = actual_1 - received_1
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 1"

    epsilon = actual_2 - received_2
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 2"

    epsilon = actual_3 - received_3
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 3"



@cocotb.test()
async def fixed_input_test_3(dut):
    """Execute a sell order on all stocks"""
    cocotb.start_soon(Clock(dut.i_clk, 10, "ns").start())

    dut.i_reset_n.value = 1
    dut.i_ren.value = 0
    dut.i_stock_id.value = 0
    dut.i_max_inventory_reciprocal.value = make_fixed_point_input(1/MAX_INVENTORY)
    dut.i_execute_order_quantity.value = 0
    dut.i_execute_order.value = 0
    dut.i_execute_order_side.value = 0

    await RisingEdge(dut.i_clk)

    quantity_0 = 89
    quantity_1 = 91
    quantity_2 = 113
    quantity_3 = 213
    # stock 0:
    dut.i_stock_id.value = 0
    dut.i_execute_order_quantity.value = quantity_0
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 1 # sell side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)
    #stock 1:
    dut.i_stock_id.value = 1
    dut.i_execute_order_quantity.value = quantity_1
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 1 # sell side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)
    #stock 2:
    dut.i_stock_id.value = 2
    dut.i_execute_order_quantity.value = quantity_2
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 1 # sell side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)
    #stock 3:
    dut.i_stock_id.value = 3
    dut.i_execute_order_quantity.value = quantity_3
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 1 # sell side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)

    # determine expected values:
    actual_0 = modify_inventory(0, quantity_0, 1)
    actual_1 = modify_inventory(1, quantity_1, 1)
    actual_2 = modify_inventory(2, quantity_2, 1)
    actual_3 = modify_inventory(3, quantity_3, 1)


    # perform reads:
    dut.i_ren.value = 1
    dut.i_stock_id.value = 0
    await Timer (0.1, units="ns")
    received_0 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)

    dut.i_ren.value = 1
    dut.i_stock_id.value = 1
    await Timer (0.1, units="ns")
    received_1 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)

    dut.i_ren.value = 1
    dut.i_stock_id.value = 2
    await Timer (0.1, units="ns")
    received_2 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)

    dut.i_ren.value = 1
    dut.i_stock_id.value = 3
    await Timer (0.1, units="ns")
    received_3 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)


    #log outputs:
    dut._log.info("Actual inventory for stock 0: %s \t", actual_0)
    dut._log.info("Received inventory for stock 0: %s \t", received_0)
    dut._log.info("Actual inventory for stock 1: %s \t", actual_1)
    dut._log.info("Received inventory for stock 1: %s \t", received_1)
    dut._log.info("Actual inventory for stock 2: %s \t", actual_2)
    dut._log.info("Received inventory for stock 2: %s \t", received_2)
    dut._log.info("Actual inventory for stock 3: %s \t", actual_3)
    dut._log.info("Received inventory for stock 3: %s \t", received_3)


    # verify
    epsilon = actual_0 - received_0
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 0"

    epsilon = actual_1 - received_1
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 1"

    epsilon = actual_2 - received_2
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 2"

    epsilon = actual_3 - received_3
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 3"


@cocotb.test()
async def fixed_input_test_4(dut):
    """Execute another sell order on all stocks"""
    cocotb.start_soon(Clock(dut.i_clk, 10, "ns").start())

    dut.i_reset_n.value = 1
    dut.i_ren.value = 0
    dut.i_stock_id.value = 0
    dut.i_max_inventory_reciprocal.value = make_fixed_point_input(1/MAX_INVENTORY)
    dut.i_execute_order_quantity.value = 0
    dut.i_execute_order.value = 0
    dut.i_execute_order_side.value = 0

    await RisingEdge(dut.i_clk)

    quantity_0 = 389
    quantity_1 = 291
    quantity_2 = 413
    quantity_3 = 553
    # stock 0:
    dut.i_stock_id.value = 0
    dut.i_execute_order_quantity.value = quantity_0
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 1 # sell side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)
    #stock 1:
    dut.i_stock_id.value = 1
    dut.i_execute_order_quantity.value = quantity_1
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 1 # sell side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)
    #stock 2:
    dut.i_stock_id.value = 2
    dut.i_execute_order_quantity.value = quantity_2
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 1 # sell side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)
    #stock 3:
    dut.i_stock_id.value = 3
    dut.i_execute_order_quantity.value = quantity_3
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 1 # sell side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)

    # determine expected values:
    actual_0 = modify_inventory(0, quantity_0, 1)
    actual_1 = modify_inventory(1, quantity_1, 1)
    actual_2 = modify_inventory(2, quantity_2, 1)
    actual_3 = modify_inventory(3, quantity_3, 1)


    # perform reads:
    dut.i_ren.value = 1
    dut.i_stock_id.value = 0
    await Timer (0.1, units="ns")
    received_0 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)

    dut.i_ren.value = 1
    dut.i_stock_id.value = 1
    await Timer (0.1, units="ns")
    received_1 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)

    dut.i_ren.value = 1
    dut.i_stock_id.value = 2
    await Timer (0.1, units="ns")
    received_2 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)

    dut.i_ren.value = 1
    dut.i_stock_id.value = 3
    await Timer (0.1, units="ns")
    received_3 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)


    #log outputs:
    dut._log.info("Actual inventory for stock 0: %s \t", actual_0)
    dut._log.info("Received inventory for stock 0: %s \t", received_0)
    dut._log.info("Actual inventory for stock 1: %s \t", actual_1)
    dut._log.info("Received inventory for stock 1: %s \t", received_1)
    dut._log.info("Actual inventory for stock 2: %s \t", actual_2)
    dut._log.info("Received inventory for stock 2: %s \t", received_2)
    dut._log.info("Actual inventory for stock 3: %s \t", actual_3)
    dut._log.info("Received inventory for stock 3: %s \t", received_3)


    # verify
    epsilon = actual_0 - received_0
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 0"

    epsilon = actual_1 - received_1
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 1"

    epsilon = actual_2 - received_2
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 2"

    epsilon = actual_3 - received_3
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 3"



@cocotb.test()
async def random_input_test_1(dut):
    """Random buy order test on inventory"""
    cocotb.start_soon(Clock(dut.i_clk, 10, "ns").start())

    dut.i_reset_n.value = 1
    dut.i_ren.value = 0
    dut.i_stock_id.value = 0
    dut.i_max_inventory_reciprocal.value = make_fixed_point_input(1/MAX_INVENTORY)
    dut.i_execute_order_quantity.value = 0
    dut.i_execute_order.value = 0
    dut.i_execute_order_side.value = 0

    await RisingEdge(dut.i_clk)

     # perform execute orders on each stock sequentially:
    quantity_0 = random.randint(100, 1000)
    quantity_1 = random.randint(100, 1000)
    quantity_2 = random.randint(100, 1000)
    quantity_3 = random.randint(100, 1000)
    # stock 0:
    dut.i_stock_id.value = 0
    dut.i_execute_order_quantity.value = quantity_0
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 0 # buy side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)
    #stock 1:
    dut.i_stock_id.value = 1
    dut.i_execute_order_quantity.value = quantity_1
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 0 # buy side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)
    #stock 2:
    dut.i_stock_id.value = 2
    dut.i_execute_order_quantity.value = quantity_2
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 0 # buy side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)
    #stock 3:
    dut.i_stock_id.value = 3
    dut.i_execute_order_quantity.value = quantity_3
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 0 # buy side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)

    # determine expected values:
    actual_0 = modify_inventory(0, quantity_0, 0)
    actual_1 = modify_inventory(1, quantity_1, 0)
    actual_2 = modify_inventory(2, quantity_2, 0)
    actual_3 = modify_inventory(3, quantity_3, 0)


    # perform reads:
    dut.i_ren.value = 1
    dut.i_stock_id.value = 0
    await Timer (0.1, units="ns")
    received_0 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)

    dut.i_ren.value = 1
    dut.i_stock_id.value = 1
    await Timer (0.1, units="ns")
    received_1 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)

    dut.i_ren.value = 1
    dut.i_stock_id.value = 2
    await Timer (0.1, units="ns")
    received_2 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)

    dut.i_ren.value = 1
    dut.i_stock_id.value = 3
    await Timer (0.1, units="ns")
    received_3 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)


    #log outputs:
    dut._log.info("Actual inventory for stock 0: %s \t", actual_0)
    dut._log.info("Received inventory for stock 0: %s \t", received_0)
    dut._log.info("Actual inventory for stock 1: %s \t", actual_1)
    dut._log.info("Received inventory for stock 1: %s \t", received_1)
    dut._log.info("Actual inventory for stock 2: %s \t", actual_2)
    dut._log.info("Received inventory for stock 2: %s \t", received_2)
    dut._log.info("Actual inventory for stock 3: %s \t", actual_3)
    dut._log.info("Received inventory for stock 3: %s \t", received_3)


    # verify
    epsilon = actual_0 - received_0
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 0"

    epsilon = actual_1 - received_1
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 1"

    epsilon = actual_2 - received_2
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 2"

    epsilon = actual_3 - received_3
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 3"



@cocotb.test()
async def random_input_test_2(dut):
    """Random sell order test on inventory"""
    cocotb.start_soon(Clock(dut.i_clk, 10, "ns").start())  

    dut.i_reset_n.value = 1
    dut.i_ren.value = 0
    dut.i_stock_id.value = 0
    dut.i_max_inventory_reciprocal.value = make_fixed_point_input(1/MAX_INVENTORY)
    dut.i_execute_order_quantity.value = 0
    dut.i_execute_order.value = 0
    dut.i_execute_order_side.value = 0

    await RisingEdge(dut.i_clk)

     # perform execute orders on each stock sequentially:
    quantity_0 = random.randint(100, 1000)
    quantity_1 = random.randint(100, 1000)
    quantity_2 = random.randint(100, 1000)
    quantity_3 = random.randint(100, 1000)
    # stock 0:
    dut.i_stock_id.value = 0
    dut.i_execute_order_quantity.value = quantity_0
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 1 # sell side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)
    #stock 1:
    dut.i_stock_id.value = 1
    dut.i_execute_order_quantity.value = quantity_1
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 1 # sell side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)
    #stock 2:
    dut.i_stock_id.value = 2
    dut.i_execute_order_quantity.value = quantity_2
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 1 # sell side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)
    #stock 3:
    dut.i_stock_id.value = 3
    dut.i_execute_order_quantity.value = quantity_3
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 1 # sell side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)

    # determine expected values:
    actual_0 = modify_inventory(0, quantity_0, 1)
    actual_1 = modify_inventory(1, quantity_1, 1)
    actual_2 = modify_inventory(2, quantity_2, 1)
    actual_3 = modify_inventory(3, quantity_3, 1)


    # perform reads:
    dut.i_ren.value = 1
    dut.i_stock_id.value = 0
    await Timer (0.1, units="ns")
    received_0 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)

    dut.i_ren.value = 1
    dut.i_stock_id.value = 1
    await Timer (0.1, units="ns")
    received_1 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)

    dut.i_ren.value = 1
    dut.i_stock_id.value = 2
    await Timer (0.1, units="ns")
    received_2 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)

    dut.i_ren.value = 1
    dut.i_stock_id.value = 3
    await Timer (0.1, units="ns")
    received_3 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)


    #log outputs:
    dut._log.info("Actual inventory for stock 0: %s \t", actual_0)
    dut._log.info("Received inventory for stock 0: %s \t", received_0)
    dut._log.info("Actual inventory for stock 1: %s \t", actual_1)
    dut._log.info("Received inventory for stock 1: %s \t", received_1)
    dut._log.info("Actual inventory for stock 2: %s \t", actual_2)
    dut._log.info("Received inventory for stock 2: %s \t", received_2)
    dut._log.info("Actual inventory for stock 3: %s \t", actual_3)
    dut._log.info("Received inventory for stock 3: %s \t", received_3)


    # verify
    epsilon = actual_0 - received_0
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 0"

    epsilon = actual_1 - received_1
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 1"

    epsilon = actual_2 - received_2
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 2"

    epsilon = actual_3 - received_3
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 3"



@cocotb.test()
async def random_input_random_stock_1(dut):
    """Random sell order test on inventory, with order of inputs switched"""
    cocotb.start_soon(Clock(dut.i_clk, 10, "ns").start())

    dut.i_reset_n.value = 1
    dut.i_ren.value = 0
    dut.i_stock_id.value = 0
    dut.i_max_inventory_reciprocal.value = make_fixed_point_input(1/MAX_INVENTORY)
    dut.i_execute_order_quantity.value = 0
    dut.i_execute_order.value = 0
    dut.i_execute_order_side.value = 0

    await RisingEdge(dut.i_clk)

     # perform execute orders on each stock sequentially:
    quantity_0 = random.randint(100, 1000)
    quantity_1 = random.randint(100, 1000)
    quantity_2 = random.randint(100, 1000)
    quantity_3 = random.randint(100, 1000)
    #stock 3:
    dut.i_stock_id.value = 3
    dut.i_execute_order_quantity.value = quantity_3
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 1 # sell side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)
    #stock 1:
    dut.i_stock_id.value = 1
    dut.i_execute_order_quantity.value = quantity_1
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 1 # sell side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)
    # stock 0:
    dut.i_stock_id.value = 0
    dut.i_execute_order_quantity.value = quantity_0
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 1 # sell side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)
    #stock 2:
    dut.i_stock_id.value = 2
    dut.i_execute_order_quantity.value = quantity_2
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 1 # sell side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)

    # determine expected values:
    actual_0 = modify_inventory(0, quantity_0, 1)
    actual_1 = modify_inventory(1, quantity_1, 1)
    actual_2 = modify_inventory(2, quantity_2, 1)
    actual_3 = modify_inventory(3, quantity_3, 1)


    # perform reads:
    dut.i_ren.value = 1
    dut.i_stock_id.value = 0
    await Timer (0.1, units="ns")
    received_0 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)

    dut.i_ren.value = 1
    dut.i_stock_id.value = 1
    await Timer (0.1, units="ns")
    received_1 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)

    dut.i_ren.value = 1
    dut.i_stock_id.value = 2
    await Timer (0.1, units="ns")
    received_2 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)

    dut.i_ren.value = 1
    dut.i_stock_id.value = 3
    await Timer (0.1, units="ns")
    received_3 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)


    #log outputs:
    dut._log.info("Actual inventory for stock 0: %s \t", actual_0)
    dut._log.info("Received inventory for stock 0: %s \t", received_0)
    dut._log.info("Actual inventory for stock 1: %s \t", actual_1)
    dut._log.info("Received inventory for stock 1: %s \t", received_1)
    dut._log.info("Actual inventory for stock 2: %s \t", actual_2)
    dut._log.info("Received inventory for stock 2: %s \t", received_2)
    dut._log.info("Actual inventory for stock 3: %s \t", actual_3)
    dut._log.info("Received inventory for stock 3: %s \t", received_3)


    # verify
    epsilon = actual_0 - received_0
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 0"

    epsilon = actual_1 - received_1
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 1"

    epsilon = actual_2 - received_2
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 2"

    epsilon = actual_3 - received_3
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 3"



@cocotb.test()
async def random_input_random_stock_2(dut):
    """Random buy order test on inventory, with order of inputs switched"""
    cocotb.start_soon(Clock(dut.i_clk, 10, "ns").start())

    dut.i_reset_n.value = 1
    dut.i_ren.value = 0
    dut.i_stock_id.value = 0
    dut.i_max_inventory_reciprocal.value = make_fixed_point_input(1/MAX_INVENTORY)
    dut.i_execute_order_quantity.value = 0
    dut.i_execute_order.value = 0
    dut.i_execute_order_side.value = 0

    await RisingEdge(dut.i_clk)

     # perform execute orders on each stock sequentially:
    quantity_0 = random.randint(100, 1000)
    quantity_1 = random.randint(100, 1000)
    quantity_2 = random.randint(100, 1000)
    quantity_3 = random.randint(100, 1000)
    #stock 1:
    dut.i_stock_id.value = 1
    dut.i_execute_order_quantity.value = quantity_1
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 0 # buy side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)
    #stock 3:
    dut.i_stock_id.value = 3
    dut.i_execute_order_quantity.value = quantity_3
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 0 # buy side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)
    # stock 0:
    dut.i_stock_id.value = 0
    dut.i_execute_order_quantity.value = quantity_0
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 0 # buy side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)
    #stock 2:
    dut.i_stock_id.value = 2
    dut.i_execute_order_quantity.value = quantity_2
    dut.i_execute_order.value = 1
    dut.i_execute_order_side.value = 0 # buy side
    await RisingEdge(dut.i_clk)
    dut.i_execute_order.value = 0
    await RisingEdge(dut.i_clk)

    # determine expected values:
    actual_0 = modify_inventory(0, quantity_0, 0)
    actual_1 = modify_inventory(1, quantity_1, 0)
    actual_2 = modify_inventory(2, quantity_2, 0)
    actual_3 = modify_inventory(3, quantity_3, 0)


    # perform reads:
    dut.i_ren.value = 1
    dut.i_stock_id.value = 0
    await Timer (0.1, units="ns")
    received_0 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)

    dut.i_ren.value = 1
    dut.i_stock_id.value = 1
    await Timer (0.1, units="ns")
    received_1 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)

    dut.i_ren.value = 1
    dut.i_stock_id.value = 2
    await Timer (0.1, units="ns")
    received_2 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)

    dut.i_ren.value = 1
    dut.i_stock_id.value = 3
    await Timer (0.1, units="ns")
    received_3 = convert_fixed_point_output(dut.o_norm_inventory.value)
    await RisingEdge(dut.i_clk)


    #log outputs:
    dut._log.info("Actual inventory for stock 0: %s \t", actual_0)
    dut._log.info("Received inventory for stock 0: %s \t", received_0)
    dut._log.info("Actual inventory for stock 1: %s \t", actual_1)
    dut._log.info("Received inventory for stock 1: %s \t", received_1)
    dut._log.info("Actual inventory for stock 2: %s \t", actual_2)
    dut._log.info("Received inventory for stock 2: %s \t", received_2)
    dut._log.info("Actual inventory for stock 3: %s \t", actual_3)
    dut._log.info("Received inventory for stock 3: %s \t", received_3)


    # verify
    epsilon = actual_0 - received_0
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 0"

    epsilon = actual_1 - received_1
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 1"

    epsilon = actual_2 - received_2
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 2"

    epsilon = actual_3 - received_3
    assert abs(epsilon) < IDEAL_DELTA, "Incorrect inventory 3"



@cocotb.test()
async def reset_test(dut):

    """Testing reset functionality"""  
    cocotb.start_soon(Clock(dut.i_clk, 10, "ns").start())

    dut.i_reset_n.value = 1
    dut.i_ren.value = 0
    dut.i_stock_id.value = 0
    dut.i_max_inventory_reciprocal.value = make_fixed_point_input(1/MAX_INVENTORY)
    dut.i_execute_order_quantity.value = 0
    dut.i_execute_order.value = 0
    dut.i_execute_order_side.value = 0

    await RisingEdge(dut.i_clk)

    dut.i_reset_n.value = 1
    reset_inventory()

    await RisingEdge(dut.i_clk)

    await Timer(0.1, units="ns")

    dut.i_ren.value = 1
    dut.i_stock_id.value = 0
    actual_inventory_0 = read_inventory(0)
    received_inventory_0 = int(dut.o_norm_inventory.value)
    dut._log.info("Actual inventory 0: %s \t", actual_inventory_0)
    dut._log.info("Received inventory 0: %s \t", received_inventory_0)

    await RisingEdge(dut.i_clk)
    await Timer(0.1, units="ns")

    dut.i_ren.value = 1
    dut.i_stock_id.value = 1
    actual_inventory_1 = read_inventory(1)
    received_inventory_1 = int(dut.o_norm_inventory.value)
    dut._log.info("Actual inventory 1: %s \t", actual_inventory_1)
    dut._log.info("Received inventory 1: %s \t", received_inventory_1)

    await RisingEdge(dut.i_clk)
    await Timer(0.1, units="ns")

    dut.i_ren.value = 1
    dut.i_stock_id.value = 1
    actual_inventory_2 = read_inventory(2)
    received_inventory_2 = int(dut.o_norm_inventory.value)
    dut._log.info("Actual inventory 2: %s \t", actual_inventory_2)
    dut._log.info("Received inventory 2: %s \t", received_inventory_2)

    await RisingEdge(dut.i_clk)
    await Timer(0.1, units="ns")

    dut.i_ren.value = 1
    dut.i_stock_id.value = 1
    actual_inventory_3 = read_inventory(3)
    received_inventory_3 = int(dut.o_norm_inventory.value)
    dut._log.info("Actual inventory 3: %s \t", actual_inventory_3)
    dut._log.info("Received inventory 3: %s \t", received_inventory_3)

    await RisingEdge(dut.i_clk)