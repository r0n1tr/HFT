import numpy as np
from collections import deque
import random
import time
import datetime
from order_book import OrderBook
import struct

SHAPE_PARAMETER = 0.005
stock_symbols = {
    0: "AAPL",
    1: "AMZN",
    2: "GOOGL",
    3: "MSFT"
}

class Model:
    def __init__(self):
        self.order_book = OrderBook()
        self.inventory = [0, 0, 0, 0]
        self.volatility_buffer = [deque(maxlen=32) for _ in range(4)]

    def process_order(self, order_type, stock_id, order_id, price, quantity, timestamp, trade_type):
        if(order_type == "ADD"):
            print("add exectud")
            self.order_book.add_order(stock_id, order_id, trade_type, quantity, price)

        elif(order_type == "CANCEL"):
            self.order_book.cancel_order(stock_id, trade_type, order_id)

        elif(order_type == "EXECUTE"):
            self.order_book.execute_order(stock_id, quantity, order_id)
        else:
            raise ValueError("u fucked up")
        

        best_bid = self.order_book.return_best_bid(stock_id)
        print(f"best_bid = {best_bid}")
        best_ask = self.order_book.return_best_ask(stock_id)
        print(f"best_ask = {best_ask}")

        inventory_state = self.inventory_update(stock_id, trade_type, quantity)
        print(f"inventory_state: {inventory_state}")

        order_quantity, buy_price, sell_price = self.trading_logic(best_ask, best_bid, timestamp, inventory_state, stock_id)
        print(f"order_quantity = {order_quantity}, buy_price: {buy_price}, sell_price: {sell_price}")
        self.reverse_parser(stock_id, buy_price, sell_price, quantity, trade_type)
        print("test complete")
        return stock_id, buy_price, sell_price, quantity, trade_type


    def generate_timestamp(self):
        current_time = time.time()
        now = datetime.datetime.now()

        # Start of trading day
        nine_thirty_am = datetime.datetime(now.year, now.month, now.day, 9, 30)
        nine_thirty_am_timestamp = time.mktime(nine_thirty_am.timetuple())

        # Calculate the seconds since 9:30 AM today
        seconds_since_nine_thirty = current_time - nine_thirty_am_timestamp

        return round(seconds_since_nine_thirty)

    def parser(self, hex_data):
        # Convert hex data to bytes
        message_bytes = bytes.fromhex(hex_data)
        
        # Extract message type (1 byte)
        message_type = message_bytes[0:1].decode('ascii')
        
        # Extract timestamp (4 bytes)
        timestamp = struct.unpack('>I', message_bytes[1:5])[0]
        
        # Extract order ID (4 bytes)
        order_id = struct.unpack('>I', message_bytes[5:9])[0]
        
        # Initialize variables
        stock_id = None
        curr_price = None
        quantity = None
        trade_type = None
        
        if message_type == 'A':  # ADD order
            # Extract side (1 byte)
            side = message_bytes[9:10]
            trade_type = 'buy' if side == b'\x01' else 'sell'
            
            # Extract quantity (4 bytes)
            quantity = struct.unpack('>I', message_bytes[10:14])[0]
            
            # Extract stock symbol (8 bytes, padded with spaces)
            stock_bytes = message_bytes[14:22].strip()
            stock = stock_bytes.decode('ascii')
            
            # Extract price (4 bytes, scaled by 10000)
            price = struct.unpack('>I', message_bytes[22:26])[0] / 10000.0
            
            # Map stock symbol to stock_id
            stock_symbols = ['AAPL', 'GOOGL', 'AMZN', 'MSFT']
            stock_id = stock_symbols.index(stock)
            
            # Return decoded values
            return 'ADD', stock_id, order_id, price, quantity, timestamp, trade_type
        
        elif message_type == 'E':  # EXECUTE order
            # Extract quantity (4 bytes)
            quantity = struct.unpack('>I', message_bytes[9:13])[0]
            
            # Return decoded values
            return 'EXECUTE', stock_id, order_id, None, quantity, timestamp, None
        
        elif message_type == 'X':  # CANCEL order
            # Return decoded values
            return 'CANCEL', stock_id, order_id, None, None, timestamp, None
        
        else:
            raise ValueError("Unknown message type")
        

    def inventory_update(self, stock_id, order_side, quantity):
        temp = int(quantity)
        if(order_side == "buy"):
            self.inventory[stock_id] += temp / 10000
        elif(order_side == "sell"):
            self.inventory[stock_id] -= temp / 10000
        else: 
            raise ValueError("inventory update did not get buy or sell but got {order_side} instead")
        return (temp / 10000)

    def update_buffer(self, stock_id, element):
        if 0 <= stock_id <= 3:
            self.volatility_buffer[stock_id].append(element)
        else:
            print("Index out of range. Please use an index between 0 and 3.")

    def buffer_var(self, stock_id):
        temp = self.volatility_buffer[stock_id]
        mean = np.mean(temp)
        # Calculate the variance
        variance = np.mean([(x - mean) ** 2 for x in temp])
        return variance

    def trading_logic(self, best_ask, best_bid, curr_time, inventory_state, stock_id):
        # Volatility
        curr_price = (best_ask + best_bid) / 2
        self.update_buffer(stock_id, curr_price)
        volatility = self.buffer_var(stock_id)

        # Spread
        spread = 0.125 * volatility * curr_time 

        # Ref Price 
        ref_price = curr_price - (inventory_state * 0.125 * volatility * curr_time)

        # Quote Price
        buy_price = ref_price - spread
        sell_price = ref_price + spread 

        # Order Quantity Estimation
        order_quantity = 100 * (SHAPE_PARAMETER * inventory_state)

        return order_quantity, buy_price, sell_price

    def reverse_parser(self, stock_id, buy_price, sell_price, quantity, trade_type): 
        time_sent = self.generate_timestamp()
        if trade_type:  # If it is a buy
            print(f"Our Buy order of: {stock_symbols[stock_id]} at price: {buy_price} for quantity: {quantity} at time: {time_sent}\n")
        else:  # If it is a sell
            print(f"Our Sell order of: {stock_symbols[stock_id]} at price: {sell_price} for quantity:  {quantity} at time:  {time_sent}\n")


