from exchange import Exchange, generate_timestamp
from market_maker import MarketMakingModel
import random


my_exchange = Exchange()
my_model = MarketMakingModel()

# for _ in range(20):
#     # print(len(my_exchange.generate_ITCH_order(num, hex_output=True, printing=True)))
#     num = random.randint(0,3)
#     (my_exchange.generate_ITCH_order(num, integer_output=True, printing=True))
for _ in range (100):
    num = random.randint(0,3)
    input_vector = my_exchange.generate_ITCH_order(num, printing=True, integer_output=True)
    print(len(input_vector))
    # print(my_exchange.generate_ITCH_order(num, printing=False, integer_output=False))
    sell_order, buy_order = my_model.quote_orders(input_vector)
    # print(f"Exchange: {input_vector}")
    print(f"Market Maker Sell Order: {sell_order}")
    print(f"Market Maker Buy Order: {buy_order}")
    
    temp_vector_b = my_exchange.insert_into_exchange(buy_order)
    temp_vector_s = my_exchange.insert_into_exchange(sell_order)
    print("Orders Inserted")
    print(temp_vector_b)
    # quote_order require -> stock_id, order_id, trade_type, quantity, price, order_type, timestamp

    sell_order, buy_order = my_model.quote_orders(temp_vector_b)
    print(f"Market Maker Sell Order: {sell_order}")
    print(f"Market Maker Buy Order: {buy_order}")
    sell_order, buy_order = my_model.quote_orders(temp_vector_s)
    print(f"Market Maker Sell Order: {sell_order}")
    print(f"Market Maker Buy Order: {buy_order}")

    print("Cycle Complete. \n")
    # generate itch for own order produces stock_id, unique_id, order_quantity, price
    # so we are missing order_type, timestamp, order_side, 

    # normal gen itch produces order_type, timestamp, order_id, order_side, quantity, stock_id, price
    