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
from converter import itch_to_readable, readable_to_ITCH

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

buy_count_map = {}
sell_count_map = {}

def update_order_counts(stock_id, buy_count_map, sell_count_map, buy_state):
    if stock_id not in buy_count_map:
        buy_count_map[stock_id] = 0
    if stock_id not in sell_count_map:
        sell_count_map[stock_id] = 0

    # Update the appropriate count based on buy_state
    if buy_state == 'buy':
        buy_count_map[stock_id] += 1
    elif buy_state == 'sell':
        sell_count_map[stock_id] += 1

    return buy_count_map[stock_id], sell_count_map[stock_id]


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

    for i in range(1000):
        stock = random.randint(0,3)
        input_order = my_exchange.generate_ITCH_order(stock, printing=False, integer_output=True)
        buy_order, sell_order = my_market_maker.quote_orders(input_order)
        order_book, null1, null2 = itch_to_readable(input_order)
        buy_count, sell_count = update_order_counts(order_book[0], buy_count_map, sell_count_map, order_book[2] )
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

        dut._log.info("Input ITCH order: %s", input_order)
        dut._log.info("Converted: %s \n", itch_to_readable(input_order))
        if (buy_count >= 30 and sell_count >= 30):
            dut._log.info("Order number: %s", i)
            # print(f"Exchange: {input_vector}")
            dut._log.info(f"Market Maker Sell Order: {sell_order}")
            dut._log.info(f"Market Maker Buy Order: {buy_order} \n")
            # tem
            # vector_s = my_exchange.insert_into_exchange(sell_order)
            temp_b, void, void2 = itch_to_readable(hardware_outputs[:9])
            temp_s, void1, void4 =  itch_to_readable(hardware_outputs[-9:])
            input_temp_b = [temp_b[6], temp_b[1], temp_b[0], temp_b[2], temp_b[3], temp_b[4]]
            input_temp_s = [temp_s[6], temp_s[1], temp_s[0], temp_s[2], temp_s[3], temp_s[4]]
            
            temp_vector_hardware_b = my_exchange.insert_into_exchange(input_temp_b)
            temp_vector_hardware_s = my_exchange.insert_into_exchange(input_temp_s)
        
            # my_market_maker.quote_orders(buy_order)
            # my_market_maker.quote_orders(sell_order)


            buy_count_map[order_book[0]] = 0
            sell_count_map[order_book[0]] = 0
            # dut._log.info("BUY ORDER RECEIVED: %s", hardware_outputs[:9])
            dut._log.info("BUY ORDER EXPECTED: %s", buy_order)
            dut._log.info(f"Buy Readable: {itch_to_readable(hardware_outputs[:9])}")
            
            # dut._log.info("SELL ORDER RECEIVED: %s", hardware_outputs[-9:])
            dut._log.info("SELL ORDER EXPECTED: %s", sell_order)
            dut._log.info(f"Sell Readable: {itch_to_readable(hardware_outputs[-9:])}\n")
            break
        
        for _ in range(8):
            await RisingEdge(dut.i_clk)


    

