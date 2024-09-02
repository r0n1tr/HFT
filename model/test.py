from exchange import Exchange, generate_timestamp
from market_maker import MarketMakingModel
import random
from converter import itch_to_readable

my_exchange = Exchange()
my_model = MarketMakingModel()
input_vector = []
# for _ in range(20):
#     # print(len(my_exchange.generate_ITCH_order(num, hex_output=True, printing=True)))
#     num = random.randint(0,3)
#     (my_exchange.generate_ITCH_order(num, integer_output=True, printing=True))
for i in range (100):
    num = random.randint(0,0)
    input_vector.append(my_exchange.generate_ITCH_order(num, printing=False, integer_output=True))

    print(input_vector)
    # print(len(input_vector))
    # print(my_exchange.generate_ITCH_order(num, printing=False, integer_output=False))
    if i % 50 == 0 and input_vector:
        oldest_data = input_vector.pop(0)
        print(f"oldest: {oldest_data}")
        buy_order, sell_order = my_model.quote_orders(oldest_data)
        # print(f"Exchange: {input_vector}")
        print(f"Market Maker Sell Order: {sell_order}")
        print(f"Market Maker Buy Order: {buy_order}")
        temp_vector_b = my_exchange.insert_into_exchange(buy_order)
        temp_vector_s = my_exchange.insert_into_exchange(sell_order)
        input_vector.append(temp_vector_b)
        input_vector.append(temp_vector_s)
        print("Orders Inserted")
    
    # print(temp_vector_b)
    # quote_order require -> stock_id, order_id, trade_type, quantity, price, order_type, timestamp

    print("Cycle Complete. \n")
    # generate itch for own order produces stock_id, unique_id, order_quantity, price
    # so we are missing order_type, timestamp, order_side, 

    # normal gen itch produces order_type, timestamp, order_id, order_side, quantity, stock_id, price
    