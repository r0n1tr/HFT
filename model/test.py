from exchange import Exchange, generate_timestamp
from market_maker import MarketMakingModel
import random
from converter import itch_to_readable, readable_to_ITCH

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


# for _ in range(20):
#     # print(len(my_exchange.generate_ITCH_order(num, hex_output=True, printing=True)))
#     num = random.randint(0,3)
#     (my_exchange.generate_ITCH_order(num, integer_output=True, printing=True))
for i in range (101):
    print(f"Counter: {i}")
    num = random.randint(0,0)
    input_vector = (my_exchange.generate_ITCH_order(num, printing=False, integer_output=True))

    print(f"{input_vector} \n")
    # print(len(input_vector))
    # print(my_exchange.generate_ITCH_order(num, printing=False, integer_output=False))

    # print(f"oldest: {oldest_data} \n")
    # print(itch_to_readable(oldest_data))
    # my_model.quote_orders(input_vector)
    
    buy_order, sell_order = my_model.quote_orders(input_vector)
    print(itch_to_readable(input_vector))
    order_book, null1, null2 = itch_to_readable(input_vector)
    print(f"order_book trade_Type {order_book[2]}")
    buy_count, sell_count = update_order_counts(order_book[0], buy_count_map, sell_count_map, order_book[2] )
    print(f"buy_count: {buy_count} and sell_count {sell_count} for stock_id: {order_book[0]}")
    print(buy_count_map)
    if buy_count >= 30 and sell_count >= 30:
        # print(f"Exchange: {input_vector}")
        print(f"Market Maker Sell Order: {sell_order}")
        print(f"Market Maker Buy Order: {buy_order} \n")
        temp_vector_b = my_exchange.insert_into_exchange(buy_order)
        temp_vector_s = my_exchange.insert_into_exchange(sell_order)
        # print(temp_vector_b)
        # print(temp_vector_s)
        my_model.quote_orders(temp_vector_b)
        my_model.quote_orders(temp_vector_s)
        # input_vector.append(temp_vector_b)
        # input_vector.append(temp_vector_s)

        # print("Orders Inserted")
    
   
    # print(temp_vector_b)
    # quote_order require -> stock_id, order_id, trade_type, quantity, price, order_type, timestamp

    # print("Cycle Complete. \n")
    # generate itch for own order produces stock_id, unique_id, order_quantity, price
    # so we are missing order_type, timestamp, order_side, 

    # normal gen itch produces order_type, timestamp, order_id, order_side, quantity, stock_id, price
    