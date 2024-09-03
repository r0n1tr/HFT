from exchange import Exchange, generate_timestamp
from market_maker import MarketMakingModel
import random
# import sys
from converter import itch_to_readable, readable_to_ITCH

# # Function to redirect print statements to a file
# class Logger:
#     def __init__(self, filename):
#         self.terminal = sys.stdout
#         self.log = open(filename, "w")

#     def write(self, message):
#         self.terminal.write(message)
#         self.log.write(message)

#     def flush(self):
#         pass

# # Replace 'output.txt' with your desired output file name
# sys.stdout = Logger("model/output.txt")


my_exchange = Exchange()
my_model = MarketMakingModel()
input_vector = []

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


def gen_order():
    num = random.randint(0,3)
    return (my_exchange.generate_ITCH_order(num, printing=False, integer_output=True))

def test():

    for i in range (15000):
        print(f"\nCounter: {i}")
        
        input_vector = gen_order()
        print(f"{input_vector}")
        
        buy_order, sell_order = my_model.quote_orders(input_vector)
        # print(itch_to_readable(input_vector))
        order_book, null1, null2 = itch_to_readable(input_vector)
        # print(f"order_book trade_Type {order_book[2]}")
        buy_count, sell_count = update_order_counts(order_book[0], buy_count_map, sell_count_map, order_book[2] )
        print(f"buy_count: {buy_count} and sell_count {sell_count} for stock_id: {order_book[0]}")
        # print(buy_count_map)
        if (buy_count >= 30 and sell_count >= 30):
            # print(f"Exchange: {input_vector}")
            print(f"Market Maker Sell Order: {sell_order}")
            print(f"Market Maker Buy Order: {buy_order} \n")
            temp_vector_b = my_exchange.insert_into_exchange(buy_order)
            temp_vector_s = my_exchange.insert_into_exchange(sell_order)
        
            my_model.quote_orders(temp_vector_b)
            my_model.quote_orders(temp_vector_s)
        
            buy_count_map[order_book[0]] = 0
            sell_count_map[order_book[0]] = 0
        
        return readable_to_ITCH(buy_order), readable_to_ITCH(sell_order)

