import numpy as np
from collections import deque
import random
import time
import datetime
from order_book import OrderBook
from model import Model
from ITCH_simulator_hex import generate_itch_stream


SHAPE_PARAMETER = 0.005
stock_symbols = {
    0: "AAPL",
    1: "AMZN",
    2: "GOOGL",
    3: "MSFT"
}

def read_orders_from_file(filename="orders.txt"):
    orders = []
    with open(filename, "r") as f:
        for line in f:
            orders.append(line.strip())
    return orders


def main():

    model = Model()
    
    temp = read_orders_from_file()
    buffer = str(temp[1])
    print(buffer)
    order_type, stock_id, order_id, price, quantity, timestamp, trade_type = model.parser(buffer)
    print(model.parser(buffer))
    model.process_order(order_type, stock_id, order_id, price, quantity, timestamp, trade_type)


 
    

if __name__ == "__main__":
    main()