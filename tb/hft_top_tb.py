import cocotb
import os
import sys
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import csv
import random
import math
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock
from exchange import Exchange
from market_maker import MarketMakingModel
from converter import itch_to_readable

my_exchange = Exchange()
my_market_maker = MarketMakingModel()
def generate_orders():
    num = random.randint(0,3)
    input_vector = (my_exchange.generate_ITCH_order(num, printing=False, integer_output=True))
    # print(f"{input_vector}")
    return input_vector




async def initialize_inputs(dut, inputs):
    dut.i_reg_0.value = inputs[8]
    dut.i_reg_1.value = inputs[7]
    dut.i_reg_2.value = inputs[6]
    dut.i_reg_3.value = inputs[5]
    dut.i_reg_4.value = inputs[4]
    dut.i_reg_5.value = inputs[3]
    dut.i_reg_6.value = inputs[2]
    dut.i_reg_7.value = inputs[1]
    dut.i_reg_8.value = inputs[0]

async def toggle_reset(dut):
    if dut.i_reset_n.value == 0:
        dut.i_reset_n.value =1
    else:
        dut.i_reset_n.value = 0


# @cocotb.test()
# async def hft_top_test(dut):

#     dut.i_reset_n.value = 1
#     cocotb.start_soon(Clock(dut.i_clk, 10, "ns").start())
#     cocotb.start_soon(toggle_reset(dut))

#     await RisingEdge(dut.i_clk)
#     await RisingEdge(dut.i_clk)
#     cocotb.start_soon(toggle_reset(dut))
#     await RisingEdge(dut.i_clk)
#     dut._log.info(type(dut.o_valid.value))

#     for i in range(300):
#         stock = random.randint(0,3)
#         input_order = my_exchange.generate_ITCH_order(stock, printing=False, integer_output=True)
#         buy_order, sell_order = my_market_maker.quote_orders(input_order)
        
#         dut._log.info("Order number: %s", i)
#         dut._log.info("Input ITCH order: %s", input_order)
#         dut._log.info("Converted: %s", itch_to_readable(input_order))
#         cocotb.start_soon(initialize_inputs(dut, input_order))
#         for _ in range(8):
#             await RisingEdge(dut.i_clk)

#         await Timer(0.2, units="ns")

#         hardware_outputs = [
#             dut.o_reg_8_b.value,
#             dut.o_reg_7_b.value,
#             dut.o_reg_6_b.value,
#             dut.o_reg_5_b.value,
#             dut.o_reg_4_b.value,
#             dut.o_reg_3_b.value,
#             dut.o_reg_2_b.value,
#             dut.o_reg_1_b.value,
#             dut.o_reg_0_b.value,

#             dut.o_reg_8_s.value,
#             dut.o_reg_7_s.value,
#             dut.o_reg_6_s.value,
#             dut.o_reg_5_s.value,
#             dut.o_reg_4_s.value,
#             dut.o_reg_3_s.value,
#             dut.o_reg_2_s.value,
#             dut.o_reg_1_s.value,
#             dut.o_reg_0_s.value,
#         ]
#         # dut._log.info("BUY ORDER RECEIVED: %s", hardware_outputs[:9])
#         dut._log.info("BUY ORDER EXPECTED: %s", buy_order)
#         dut._log.info("Buy order received: %s", hardware_outputs[:9])
#         dut._log.info(f"Buy Readable: {itch_to_readable(hardware_outputs[:9])}")
        
#         # dut._log.info("SELL ORDER RECEIVED: %s", hardware_outputs[-9:])
#         dut._log.info("SELL ORDER EXPECTED: %s", sell_order)
#         dut._log.info(f"Sell Readable: {itch_to_readable(hardware_outputs[-9:])}\n")


#         for _ in range(20):
#             await RisingEdge(dut.i_clk)
    

    # Clock Generation
    

@cocotb.test()
async def test_1(dut):
    dut.i_reset_n.value = 1
    dut.i_data_valid.value = 0
    cocotb.start_soon(Clock(dut.i_clk, 10, "ns").start())
    cocotb.start_soon(toggle_reset(dut))

    await RisingEdge(dut.i_clk)
    await RisingEdge(dut.i_clk)
    cocotb.start_soon(toggle_reset(dut))
    await RisingEdge(dut.i_clk)

    for _ in range(8):
        await RisingEdge(dut.i_clk)

    for i in range(800):
        stock = random.randint(0,3)
        input_order = my_exchange.generate_ITCH_order(stock, printing=False, integer_output=True)
        buy_order, sell_order = my_market_maker.quote_orders(input_order)
        dut.i_data_valid.value = 1
        cocotb.start_soon(initialize_inputs(dut, input_order))

        await RisingEdge(dut.i_clk)
        dut.i_data_valid.value = 0

        while True:
            await Timer(0.1, units="ns")
            if dut.o_valid.value == 1:
                hardware_outputs = [
                    dut.o_reg_8_b.value,
                    dut.o_reg_7_b.value,
                    dut.o_reg_6_b.value,
                    dut.o_reg_5_b.value,
                    dut.o_reg_4_b.value,
                    dut.o_reg_3_b.value,
                    dut.o_reg_2_b.value,
                    dut.o_reg_1_b.value,
                    dut.o_reg_0_b.value,

                    dut.o_reg_8_s.value,
                    dut.o_reg_7_s.value,
                    dut.o_reg_6_s.value,
                    dut.o_reg_5_s.value,
                    dut.o_reg_4_s.value,
                    dut.o_reg_3_s.value,
                    dut.o_reg_2_s.value,
                    dut.o_reg_1_s.value,
                    dut.o_reg_0_s.value,
                ]
                break
            else:
                await RisingEdge(dut.i_clk)
        
        dut._log.info("Order number: %s", i)
        dut._log.info("Input ITCH order: %s", input_order)
        dut._log.info("Converted: %s", itch_to_readable(input_order))

        
        # dut._log.info("BUY ORDER RECEIVED: %s", hardware_outputs[:9])
        dut._log.info("BUY ORDER EXPECTED: %s", buy_order)
        dut._log.info(f"Buy Readable: {itch_to_readable(hardware_outputs[:9])}")
        
        # dut._log.info("SELL ORDER RECEIVED: %s", hardware_outputs[-9:])
        dut._log.info("SELL ORDER EXPECTED: %s", sell_order)
        dut._log.info(f"Sell Readable: {itch_to_readable(hardware_outputs[-9:])}\n")
    
        await RisingEdge(dut.i_clk)


    

