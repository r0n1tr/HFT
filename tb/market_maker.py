from order_book import OrderBook
import math
from exchange import generate_own_order_id, generate_timestamp
from converter import itch_to_readable
SHAPE_PARAMETER = 0.5 
# Bytes:      Bits:       reg:                                Bitreglength    Message:
#     1       0-7:        reg0[7:0]                           8               "A" for add order 
#     2       8-23:       reg0[23:8]                          16              Locate code identifying the security - a random number associated with a specific stock, new every day
#     2       24-39:      reg1[7:0] reg0[31:24]               16              Internal tracking number
#     6       40-87:      reg2[23:0] reg1[31:8]               48              Timestamp - nanoseconds since midnight - we will just do seconds since start of trading day

#     8       88-151:     reg4[23:0] reg3[31:0] reg2[31:24]   64              Order ID
#     1       152-159:    reg4[31:24]                         8               Buy or sell indicator - 0 or 1
#     4       160-191:    reg5[31:0]                          32              Number of shares / order quantity
#     8       192-255:    reg7[31:0] reg6[31:0]               64              Stock ID
#     4       255-287:    reg8[31:0]                          32              Price


def parse(ITCH_data):
        # return a list of the parsed data
        # print("Parsing...")
        # print(ITCH_data)
        reg_0 = ITCH_data[8]
        reg_1 = ITCH_data[7]
        reg_2 = ITCH_data[6]
        reg_3 = ITCH_data[5]
        reg_4 = ITCH_data[4]
        reg_5 = ITCH_data[3]
        reg_6 = ITCH_data[2]
        reg_7 = ITCH_data[1]
        reg_8 = ITCH_data[0]

        order_book_inputs = []
        
        order_type = reg_0 & 0xff
        order_type_dict = {
            65: "ADD",
            68: "CANCEL",
            69: "EXECUTE"
        }

        # bits 0 to 151 is the same for all

        order_type = order_type_dict[order_type]
        # print(order_type)

        locate_code = (reg_0 >> 8) & 0xFFFF

        internal_tracking_number_half_1 = (reg_0 >> 24) & 0xFF
        internal_tracking_number_half_2 = reg_1 & 0xFF
        internal_tracking_number = (internal_tracking_number_half_1 << 8) | internal_tracking_number_half_2

        timestamp_1 = (reg_1 >> 8) & 0xFFFFFF
        timestamp_2 = (reg_2) & 0xFFFFFF
        final_time = (timestamp_1 << 24 ) +  timestamp_2  
       
        order_id_1 = (reg_2 >> 24) & 0xFF
        order_id_2 = reg_3
        order_id_3 = (reg_4) & 0xFFF
        order_id = (order_id_1 << 56) | (order_id_2 << 24) | order_id_3

        if order_type == "ADD":
            buy_or_sell = (reg_4 >> 24) & 0xFF
            if buy_or_sell == 0:
                buy_or_sell = "buy"
            else:
                buy_or_sell = "sell"
        else:
            buy_or_sell = None
        # print(buy_or_sell)

        if order_type == "ADD":
            shares = reg_5
        elif order_type == "EXECUTE":
            shares = ((reg_4 >> 24) & 0xFF) + ((reg_5 & 0xFFFFFF) << 8)
        else:
            shares = None
        
        if order_type == "ADD":
            stock_id = (reg_7 << 32) + reg_6
        elif order_type == "EXECUTE":
            stock_id = (reg_6 << 8) + ((reg_5 >> 24) & 0xFF) + ((reg_7 & 0xFFFFFF) << 40)
        else:
            stock_id = (reg_5 << 8) + ((reg_4 >> 24) & 0xFF) + ((reg_6 & 0xFFFFFF) << 40) 
        stock_dict = {
            4702127773838221344 : 0, 
            4705516477264961568 : 1, 
            5138412867491471392 : 2, 
            5571874491117608992 : 3
        }
        stock_id = stock_dict[stock_id]

        # print(stock_id)
        if order_type == "ADD":
            price = reg_8
        else:
            price = None

        order_book_inputs.append(stock_id)
        order_book_inputs.append(order_id)
        order_book_inputs.append(buy_or_sell)
        order_book_inputs.append(shares)
        order_book_inputs.append(price)
        order_book_inputs.append(order_type)
        order_book_inputs.append(final_time)
        # print(f"order_id: {bin(order_id)}")

        return order_book_inputs, locate_code, final_time

class MarketMakingModel:

    def __init__(self):
        self.ob = OrderBook()
        self.inventory = [0, 0, 0, 0]
        self.volatility_buffers = [[0]*32  for _ in range(4)]
        self.volatility_indexes = [0, 0, 0, 0]

    
    def quote_orders(self, ITCH_data):
        # parse the order
        order_book_inputs, temp2, temp3= itch_to_readable(ITCH_data)
        # TODO: not complete
        stock_id = order_book_inputs[0]
        order_id = order_book_inputs[1]
        trade_type = order_book_inputs[2]
        quantity = order_book_inputs[3]
        price = order_book_inputs[4]
        order_type = order_book_inputs[5]
        timestamp = order_book_inputs[6] 

        # print(f"timestamp from quote_orders: {timestamp}") 
        # print(f"Arguments received in Market Maker: order_id={order_id}, order_price={price}, order_quantity={quantity}, order_side={trade_type}")
        # print(f"trade_type: {trade_type}")  

        # load it into the order book
        if order_type.upper() == "ADD":
            self.ob.add_order(stock_id, order_id, trade_type, quantity, price)
        elif order_type.upper() == "CANCEL":
            self.ob.cancel_order(stock_id, order_id)
        elif order_type.upper() == "EXECUTE":
            self.ob.execute_order(stock_id, quantity, order_id)
            # in the order book, we need to see what side the execute trade is.
            # inventory stuff - need to pass in order id too to check if the order from the exchange is one of ours that has been executed.
            trade_type = self.ob.execute_order_side
            self.update_inventory(order_id, stock_id, quantity, trade_type)
        else:
             raise ValueError("Invalid order type")

        best_bid = self.ob.return_best_bid(stock_id)
        best_ask = self.ob.return_best_ask(stock_id)

        # trading logic stuff
        quote_bid, quote_ask = self.calculate_bid_and_ask_prices(timestamp, best_bid, best_ask, stock_id, self.inventory[stock_id])


        # Order Quantity Estimation
        # order_quantity = 100 * (SHAPE_PARAMETER * self.update_inventory(order_id, stock_id, quantity, trade_type)) # where do we get inventory_state from?
        order_quantity = math.floor(100 * math.exp(SHAPE_PARAMETER * self.inventory[stock_id]))
        
        timestamp_new = generate_timestamp()
        # output orders
        unique_id = generate_own_order_id(trade_type)
        unique_id_2 = generate_own_order_id(trade_type)
        # print(unique_id)    
        buy_order_info = [ timestamp_new, unique_id, stock_id, "buy", order_quantity, quote_bid] # unique buy order_id
        sell_order_info = [ timestamp_new, unique_id_2, stock_id, "sell",  order_quantity, quote_ask] # unique sell order_id
        return buy_order_info, sell_order_info

    def update_buffer(self, stock_id, element):
        if 0 <= stock_id <= 3:
            # print(f"element: {element}")
            self.volatility_buffers[stock_id][self.volatility_indexes[stock_id]] = element
            self.volatility_indexes[stock_id] = (self.volatility_indexes[stock_id] + 1) % 32
        else:
            raise ValueError("Index out of range. Please use an index between 0 and 3.")

    def buffer_var(self, stock_id):
        BUFFER_SIZE = 32
        sum = 0 
        square_sum = 0
        for i in range(BUFFER_SIZE):
            sum = sum + self.volatility_buffers[stock_id][i]
            square_sum = square_sum + (self.volatility_buffers[stock_id][i]*self.volatility_buffers[stock_id][i])
        
        # print(f"volatility buffer: {self.volatility_buffers[stock_id]}")
        variance = square_sum/BUFFER_SIZE - ((sum/BUFFER_SIZE)*(sum/BUFFER_SIZE))
        
        return max(0, variance)
    
    def calculate_bid_and_ask_prices(self, timestamp, best_bid, best_ask, stock_id, inventory_state):
        if best_ask == 0:
            curr_price = best_bid
        elif best_bid == 0:
            curr_price = best_ask
        else:
            curr_price = (best_ask + best_bid) / 2

        # print(f"curr_price {curr_price}")
        self.update_buffer(stock_id, curr_price)
        volatility = self.buffer_var(stock_id)
        # print(f"VOLATILITY FROM MARKET_MAKER: {volatility}")
        # Spread
        # print(f"timestamp: {timestamp}")
        volatility = volatility * 0.001
        spread = 0.125 * volatility * timestamp
        # print(f"spread: {spread}")
        # print(f"volatilty: {volatility}" ) 

        # Ref Price
        # print(f"current price: {curr_price}")
        # print(f"inventory_state: {inventory_state}")
        ref_price = curr_price - (inventory_state * 0.125 * volatility * timestamp)
        # print(f"ref_price: {ref_price}")
        # print(f"inventory_state: {inventory_state}")
        # print(f"timestamp: {timestamp}")
        # Quote Price
        if self.volatility_buffers[stock_id][-1] == 0:
            # print(f"last element: {self.volatility_buffers[stock_id][-1]}")
            quote_ask = curr_price
            quote_bid = curr_price
        else:
            # print(self.volatility_buffers[stock_id])
            quote_bid = ref_price - (spread/2)
            quote_ask = ref_price + (spread/2)

        return quote_bid, quote_ask

    
    def update_inventory(self, order_id, stock_id, quantity, order_side):
        MAX_INVENTORY_SIZE = 10000
        if order_side == None:
            return
        else:
            if order_side.upper() == "BUY":
                multiplier = 1
            elif order_side.upper() == "SELL":
                multiplier = -1
            else:
                multiplier = 0

        self.inventory[stock_id] = self.inventory[stock_id] + (multiplier*quantity)/MAX_INVENTORY_SIZE

        return self.inventory[stock_id]

    